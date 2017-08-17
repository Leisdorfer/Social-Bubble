import UIKit
import FacebookLogin
import FacebookCore
import RxSugar
import RxSwift

class SocialBubbleView: UIView, LoginButtonDelegate  {
    private let title = UILabel()
    private let login = LoginButton(readPermissions: [.publicProfile])
    private var bubbles: [UIButton] = []
    private var visibleBubbles: [UIButton] = []
    
    let loggedIn: Observable<Bool>
    private let _loggedIn = Variable<Bool>(AccessToken.current != nil)
    let selection: Observable<Void>
    private let _selection = PublishSubject<Void>()
    
    override init(frame: CGRect) {
        //selection = Observable.of(visibleBubbles.map { $0.rxs.tap })
        loggedIn = _loggedIn.asObservable()
        selection = _selection.asObservable()
        super.init(frame: frame)
        backgroundColor = .black
        addShadow(toView: title, withRadius: 4)
        title.textColor = .white
        title.text = "Social Bubble"
        title.font = UIFont.systemFont(ofSize: 54)
        login.delegate = self
        addSubview(login)
        addBubbles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        defer { addSubview(title) }
        let contentArea = bounds.insetBy(dx: Padding.large, dy: Padding.large)
        let titleSize = title.sizeThatFits(contentArea.size)
        title.frame = CGRect(x: contentArea.midX - titleSize.width/2, y: contentArea.minY, size: titleSize)
        let loginSize = CGSize(width: 88, height: 44)
        login.frame = CGRect(x: contentArea.midX - loginSize.width/2, y: title.frame.maxY, size: loginSize)
        layoutBubbles()
    }
    
    @objc private func addContent(_ bubble: UIButton) {
        UIView.animate(withDuration: 3, animations: { [weak self] in
            guard let `self` = self else { return }
            let diameter: CGFloat = self.bounds.width
            bubble.frame.size.height = diameter
            bubble.frame.size.width = diameter
            bubble.layer.cornerRadius = bubble.frame.width/2
            bubble.frame.origin.y = self.bounds.midY - diameter/2
            bubble.frame.origin.x = self.bounds.midX - diameter/2
            bubble.layer.zPosition = 2
            //self.bringSubview(toFront: bubble)
        }, completion: nil)
       // _selection.onNext()
        print("why hello there!")
    }
    
    private func addBubbles() {
        (0...30).forEach { _ in
            let bubble = UIButton()
            addSubview(bubble)
            bubbles.append(bubble)
        }
    }
    
    private func layoutBubbles() {
        defer { visibleBubbles = [] }
        //Need to replace the access token check with an Rx substitute
        _loggedIn.value = AccessToken.current != nil
        bubbles.forEach { bubble in
            let diameter = CGFloat(arc4random_uniform(100) + 50)
            let x = CGFloat(arc4random_uniform(UInt32(bounds.maxX)))
            let y = CGFloat(arc4random_uniform(UInt32(bounds.maxY)) + UInt32(login.frame.maxY))
            bubble.frame = CGRect(x: x - diameter/2, y: y, width: diameter, height: diameter)
            let intersect = visibleBubbles.reduce(false) { $0 || $1.frame.intersects(bubble.frame) }

            if intersect {
               bubble.frame = CGRect.zero
            } else {
                addStyle(toBubble: bubble)
                visibleBubbles.append(bubble)
            }
        }
    }
    
    func addEvents(_ events: [Event]) {
        let bubbleEvents = zip(visibleBubbles, events)
//get rid of bubbles without events
        _ = zip(bubbles, events).map { $0.0.setTitle($0.1.name, for: .normal); $0.0.addTarget(self, action: #selector(addContent(_:)), for: .touchUpInside) }
    }

    private func addStyle(toBubble bubble: UIButton) {
        bubble.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(100))/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        bubble.titleLabel?.numberOfLines = 3
        bubble.titleLabel?.textAlignment = .center
        bubble.titleLabel?.adjustsFontSizeToFitWidth = true
        bubble.titleLabel?.textColor = .white
        bubble.layer.cornerRadius = bubble.frame.width/2//diameter/2
        addShadow(toView: bubble, withRadius: 10)
    }

    
    private func addShadow(toView view: UIView, withRadius radius: CGFloat) {
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.75
        view.layer.shadowRadius = radius
    }
    
    public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error): print(error)
        case .cancelled: print("user cancelled login")
        case .success(_, _, _):_loggedIn.onNext(true)
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("user logged out!")
    }
}
