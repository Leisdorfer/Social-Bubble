import UIKit
import FacebookLogin
import FacebookCore
import RxSugar
import RxSwift
import SpriteKit

class SocialBubbleView: UIView, LoginButtonDelegate, UIGestureRecognizerDelegate {
    private let title = UILabel()
    private let login = LoginButton(readPermissions: [.publicProfile])
    private let textField = PlaceholderPaddedTextField()
    private let search = UIButton()
    private let tableView = TableHandler()
    private let screenSaver = SKView()
    private let blurView = UIVisualEffectView()
    private var animation: Animation?
    private var selectedBubble = BubbleView()
    private var bubbles: [BubbleView] = []
    private var visibleBubbles: [BubbleView] = []
    private var loggedIn: Bool { return AccessToken.current != nil }

    let textFieldTerm: Observable<String>
    let autocompleteFields: AnyObserver<[String]>
    private let _autocompleteFields = Variable<[String]>([])
    let autocompleteSelection: Observable<String>
    let searchTerm: Observable<String>
    let selectDirection = PublishSubject<Event>()
    let expandedBubble: AnyObserver<Bool>
    private let _expandedBubble = Variable<Bool>(false)

    override init(frame: CGRect) {
        expandedBubble = _expandedBubble.asObserver()
        textFieldTerm = textField.searchTerm
        autocompleteFields = _autocompleteFields.asObserver()
        autocompleteSelection = tableView.selection
        let searchSelection = search.rxs.tap
        let term = Observable.of(
            textField.rxs.text.map { $0.formatText() }.filter { $0.characters.count > 0 },
            tableView.selection.map { $0.formatText() }
        ).merge()
        searchTerm = searchSelection.withLatestFrom(term)
        super.init(frame: frame)
        backgroundColor = .black
        addBubbles()
        addSubview(screenSaver)
        let scene = BubbleScene(size: CGSize(width: 50, height: 50))
        screenSaver.presentScene(scene)
        blurView.isUserInteractionEnabled = false
        blurView.effect = !loggedIn ? UIBlurEffect(style: .dark) : nil
        addSubview(blurView)
        title.textColor = .white
        title.text = "Social Bubble"
        title.font = UIFont(name: "HelveticaNeue", size: 50)
        addSubview(title)
        login.delegate = self
        addSubview(login)
        textField.placeholder = "Location"
        addSubview(textField)
        addSubview(tableView.view)
        search.setTitle("Search", for: .normal)
        search.setTitleColor(.white, for: .normal)
        search.backgroundColor = UIColor(hue:0.62, saturation:0.57, brightness:0.68, alpha:1.00)
        search.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 13)
        addSubview(search)
        
        rxs.disposeBag
            ++ { [weak self] in self?.showAlert() } <~ searchSelection.filter { !self.loggedIn }
            ++ { [weak self] in self?.showBubbles() } <~ searchTerm.toVoid().filter { self.loggedIn }
            ++ { [weak self] in self?.tableView.view.isHidden = false } <~ textField.editingStarted
            ++ tableView.data <~ _autocompleteFields.asObservable()
            ++ rxs.setNeedsLayout <~ _autocompleteFields.asObservable().toVoid()
            ++ textField.rxs.text <~ autocompleteSelection
            ++ { [weak self] in self?.tableView.view.isHidden = true } <~ search.rxs.tap
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        let contentArea = bounds.insetBy(dx: Padding.large, dy: Padding.large)
        let titleSize = title.sizeThatFits(contentArea.size)
        title.frame = CGRect(x: contentArea.midX - titleSize.width/2, y: contentArea.minY, size: titleSize)
        let searchWidth = search.sizeThatFits(contentArea.size).width + Padding.small
        let searchSize = CGSize(width: searchWidth, height: 44)
        let loginTextSize = CGSize(width: titleSize.width/2 - Padding.small, height: 44)
        login.frame = CGRect(x: title.frame.minX, y: title.frame.maxY, size: loginTextSize)
        textField.frame = CGRect(x: login.frame.maxX + Padding.small, y: login.frame.minY, width: loginTextSize.width - searchSize.width, height: loginTextSize.height)
        let tableViewSize = CGSize(width: loginTextSize.width, height: textField.frame.height * CGFloat(_autocompleteFields.value.count))
        tableView.view.frame = CGRect(x: textField.frame.minX, y: textField.frame.maxY, size: tableViewSize)
        addRadius(toCorner: [.topLeft], ofView: textField)
        search.frame = CGRect(x: textField.frame.maxX, y: textField.frame.minY, size: searchSize)
        addRadius(toCorner: [.topRight], ofView: search)
        let height = bounds.height - search.frame.maxY
        screenSaver.frame = CGRect(x: bounds.minX - (bounds.height - bounds.width)/2, y: search.frame.maxY, width: height, height: height)
    }
    
    private func showBubbles() {
        screenSaver.isHidden = true
        layoutBubbles()
        blurView.effect = nil
    }

    private func showAlert() {
        let alert = UIAlertController(title: "Login Required", message: "Please login to your Facebook account", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancel)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    private func addBubbles() {
        (0...10).forEach { _ in
            let bubble = BubbleView()
            addSubview(bubble)
            bubbles.append(bubble)
            bubble.isHidden = true
            
            rxs.disposeBag
                ++ { [weak self] in self?.selectBubble(bubble) } <~ bubble.rxs.tap.filter { [weak self] in
                        guard let `self` = self else { return false }
                        return !self._expandedBubble.value
                   }
                ++ selectDirection.asObserver() <~ bubble.selectDirection.map { bubble.event.value }.ignoreNil()
        }
    }
    
    private func selectBubble(_ bubble: BubbleView) {
        animation = Animation(bubble: bubble, view: self, bounds: bounds).animateInBubbleView(amongstBubbles: bubbles)
        self.selectedBubble = bubble
        blurView.effect = UIBlurEffect(style: .dark)
        bubbles.filter { $0 != bubble }.forEach { $0.isUserInteractionEnabled = false }
        login.isHidden = true
        search.isHidden = true
        textField.isHidden = true
        tableView.view.isHidden = true
        receiveTaps()
    }
    
    private func receiveTaps() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissBubble(_:)))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

//TODO: ensure that dismissBubble is called when an area outside of the selected bubble is tapped
    @objc private func dismissBubble(_ recognizer: UITapGestureRecognizer) {
        guard loggedIn && _expandedBubble.value else { return }
        let pressedPoint = recognizer.location(in: self)
        if !selectedBubble.frame.contains(pressedPoint) {
            blurView.effect = nil
            animation?.animateOutBubbleView()
            bubbles.forEach { $0.isUserInteractionEnabled = true }
            login.isHidden = false
            search.isHidden = false
            textField.isHidden = false
        }
    }
    
    private func layoutBubbles() {
        visibleBubbles = []
        bubbles.forEach { layoutRandomBubble(bubble: $0) }
//        visibleBubbles = []
    }
    
    private func layoutRandomBubble(bubble: BubbleView) {
        let diameter = CGFloat(arc4random_uniform(100) + 75)
        var x = CGFloat(arc4random_uniform(UInt32(self.bounds.maxX)))
        var y = CGFloat(arc4random_uniform(UInt32(self.bounds.maxY)) + UInt32(self.login.frame.maxY))
        x = (x + diameter) > self.bounds.maxX || x == self.bounds.maxX ? x - diameter : x
        y = (y + diameter) > self.bounds.maxY ? y - diameter : y
        bubble.frame = CGRect(x: x, y: y, width: diameter, height: diameter)
        let intersect = self.visibleBubbles.reduce(false) { $0 || $1.frame.intersects(bubble.frame) }
        if intersect {
            bubble.frame = .zero
            layoutRandomBubble(bubble: bubble)
        } else {
            visibleBubbles.append(bubble)
        }
    }
    
    func addEvents(_ events: [Event]) {
        bubbles.forEach { $0.event.value = nil; $0.isHidden = true }
        zip(bubbles, events).forEach { $0.event.value = $1 }
        bubbles.filter { $0.event.value != nil }.forEach { $0.isHidden = false }
    }

    public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error): print(error)
        case .cancelled: print("user cancelled login")
        case .success(_, _, _):
            bubbles.forEach { $0.isHidden = true }
            setNeedsLayout()
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: LoginButton) {
        bubbles.forEach { $0.event.value = nil }
        blurView.effect = UIBlurEffect(style: .dark)
        bubbles.forEach { $0.isUserInteractionEnabled = false }
        screenSaver.isHidden = false
    }
}


