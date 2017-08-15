import UIKit
import FacebookLogin
import FacebookCore

class SocialBubbleView: UIView, LoginButtonDelegate  {

    private let title = UILabel()
    private let login = LoginButton(readPermissions: [.publicProfile])
    private var visibleBubbles = [UIButton]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addShadow(toView: title, withRadius: 4)
        title.textColor = .white
        title.text = "Social Bubble"
        title.font = UIFont.systemFont(ofSize: 54)
        login.delegate = self
        addSubview(login)
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
        addRandomBubbles()
        //addAnimation(toBubbles: visibleBubbles)
    }
   
    public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error): print(error)
        case .cancelled: print("user cancelled login")
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("logged in!")
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("user logged out!")
    }
    
    private func addRandomBubbles() {
        (0...15).forEach { _ in
            let diameter = CGFloat(arc4random_uniform(100) + 50)
            let x = CGFloat(arc4random_uniform(UInt32(bounds.maxX)))
            let y = CGFloat(arc4random_uniform(UInt32(bounds.maxY)) + UInt32(login.frame.maxY))
            let bubble = UIButton(frame: CGRect(x: x - diameter, y: y, width: diameter, height: diameter))
            let intersect = visibleBubbles.reduce(false) { $0 || $1.frame.intersects(bubble.frame) }
            if !intersect {
                addStyle(toBubble: bubble, withDiameter: diameter)
                addSubview(bubble)
                visibleBubbles.append(bubble)
            }
        }
    }
    
    private func addStyle(toBubble bubble: UIButton, withDiameter diameter: CGFloat) {
        bubble.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(100))/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        addShadow(toView: bubble, withRadius: 10)
        bubble.layer.cornerRadius = diameter/2
    }
    
    private func addAnimation(toBubbles bubbles: [UIButton]) {
        UIView.animate(withDuration: 10, animations: {
            bubbles.forEach { [weak self] bubble in
                guard let `self` = self else { return }
                let x = CGFloat(arc4random_uniform(UInt32(self.bounds.maxX)))
                let y = CGFloat(arc4random_uniform(UInt32(self.bounds.maxY)))
                var bubbleFrame = bubble.frame
                if bubbleFrame.maxX < self.bounds.maxX && bubbleFrame.maxY < self.bounds.maxY {
                    bubbleFrame.origin.x += x
                    bubbleFrame.origin.y += y
                    bubble.frame = bubbleFrame
                }
            }
        })
    }
    
    private func addShadow(toView view: UIView, withRadius radius: CGFloat) {
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.75
        view.layer.shadowRadius = radius
    }
}
