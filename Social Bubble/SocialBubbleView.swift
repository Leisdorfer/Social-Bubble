import UIKit

class SocialBubbleView: UIView {
    private let title = UILabel()
    
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
        addRandomBubbles()
        let contentArea = bounds.insetBy(dx: Padding.large, dy: Padding.large)
        let titleSize = title.sizeThatFits(contentArea.size)
        title.frame = CGRect(x: contentArea.midX - titleSize.width/2, y: contentArea.minY, size: titleSize)
        addSubview(title)
    }
    
    private func addRandomBubbles() {
        (0...5).forEach { _ in
            let diameter = CGFloat(arc4random_uniform(100) + 50)
            let x = CGFloat(arc4random_uniform(UInt32(bounds.maxX)))
            let y = CGFloat(arc4random_uniform(UInt32(bounds.maxY)))
            let bubble = UIView(frame: CGRect(x: x - diameter, y: y - diameter, width: diameter, height: diameter))
            bubble.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(100))/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            bubble.layer.cornerRadius = diameter/2
            bubble.layer.shadowColor = UIColor.white.cgColor
            bubble.layer.shadowOffset = CGSize(width: 0, height: 0)
            bubble.layer.shadowOpacity = 0.75
            bubble.layer.shadowRadius = 10
            addSubview(bubble)
        }
    }
}
