import UIKit
import FacebookLogin
import FacebookCore
import RxSugar
import RxSwift

class SocialBubbleView: UIView, LoginButtonDelegate {
    private let title = UILabel()
    private let login = LoginButton(readPermissions: [.publicProfile])
    private var bubbles: [BubbleView] = []
    private var visibleBubbles: [BubbleView] = []
    
    let loggedIn: Observable<Bool>
    private let _loggedIn = Variable<Bool>(AccessToken.current != nil)
    let selectDirection = PublishSubject<Void>()

    override init(frame: CGRect) {
        loggedIn = _loggedIn.asObservable()
        super.init(frame: frame)
        backgroundColor = .black
        title.textColor = .white
        title.text = "Social Bubble"
        title.font = UIFont.systemFont(ofSize: 54)
        addSubview(title)
        login.delegate = self
        addSubview(login)
        addBubbles()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let contentArea = bounds.insetBy(dx: Padding.large, dy: Padding.large)
        let titleSize = title.sizeThatFits(contentArea.size)
        title.frame = CGRect(x: contentArea.midX - titleSize.width/2, y: contentArea.minY, size: titleSize)
        let loginSize = CGSize(width: 88, height: 44)
        login.frame = CGRect(x: contentArea.midX - loginSize.width/2, y: title.frame.maxY, size: loginSize)
        layoutBubbles()
    }

    private func addBubbles() {
        (0...30).forEach { _ in
            let bubble = BubbleView()
            addSubview(bubble)
            bubbles.append(bubble)
            
            rxs.disposeBag
                ++ { [weak self] in self?.viewSelection(bubble) } <~ bubble.rxs.tap
                ++ selectDirection.asObserver() <~ bubble.selectDirection
        }
    }
    
   private func viewSelection(_ bubble: BubbleView) {
        let animation = Animation(bounds: bounds)
        animation.animateView(bubble, withinViews: bubbles)
        bubble.updateEvent()
    }
    
    private func layoutBubbles() {
//TODO: replace the access token check with an Rx substitute
        defer { visibleBubbles = []; _loggedIn.value = AccessToken.current != nil }
        bubbles.forEach { [weak self] bubble in
            guard let `self` = self else { return }
            let diameter = CGFloat(arc4random_uniform(100) + 50)
            var x = CGFloat(arc4random_uniform(UInt32(self.bounds.maxX)))
            var y = CGFloat(arc4random_uniform(UInt32(self.bounds.maxY)) + UInt32(self.login.frame.maxY))
            x = (x + diameter) > self.bounds.maxX || x == self.bounds.maxX ? x - diameter : x
            y = (y + diameter) > self.bounds.maxY ? y - diameter : y
            bubble.frame = CGRect(x: x, y: y, width: diameter, height: diameter)
            let intersect = self.visibleBubbles.reduce(false) { $0 || $1.frame.intersects(bubble.frame) }
            let visible = bubble.frame.intersects(self.bounds)
            if !intersect && visible {
                self.visibleBubbles.append(bubble)
            } else {
                bubble.frame = CGRect.zero
            }
        }
    }
    
    func addEvents(_ events: [Event]) {
//TODO: get rid of bubbles without events
        _ = zip(bubbles, events).map { $0.event = $1 }
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
        _ = bubbles.map { $0.event = nil }
    }
}


