import UIKit

class SocialBubbleView: UIView {
    private let title = UILabel()
    private var previousBubbles = [UIView]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        title.textColor = .white
        title.text = "Social Bubble"
        title.font = UIFont.systemFont(ofSize: 54)
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
        addRandomBubbles()
    }
    
    private func addRandomBubbles() {
        (0...15).forEach { _ in
            let diameter = CGFloat(arc4random_uniform(100) + 50)
            let x = CGFloat(arc4random_uniform(UInt32(bounds.maxX)))
            let y = CGFloat(arc4random_uniform(UInt32(bounds.maxY)) + UInt32(title.frame.maxY))
            let bubble = UIView(frame: CGRect(x: x - diameter, y: y, width: diameter, height: diameter))
            let intersect = previousBubbles.reduce(false) { $0 || $1.frame.intersects(bubble.frame) }
            if !intersect {
                addStyle(toBubble: bubble, withDiameter: diameter)
                addSubview(bubble)
                previousBubbles.append(bubble)
            }
        }
    }
    
    private func addStyle(toBubble bubble: UIView, withDiameter diameter: CGFloat) {
        bubble.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(100))/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        addShadow(toBubble: bubble)
        bubble.layer.cornerRadius = diameter/2
    }
    
    private func addShadow(toBubble bubble: UIView) {
        bubble.layer.shadowColor = UIColor.white.cgColor
        bubble.layer.shadowOffset = CGSize(width: 0, height: 0)
        bubble.layer.shadowOpacity = 0.75
        bubble.layer.shadowRadius = 10
    }
}
