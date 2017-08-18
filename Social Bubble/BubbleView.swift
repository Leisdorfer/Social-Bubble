import UIKit

class BubbleView: UIView {
    private let name = UILabel()
    private let time = UILabel()
    private let eventDescription = UILabel()
    private var contentHidden = true
    
    func updateEvent() {
        contentHidden = false
        setNeedsLayout()
    }
    
    var event: Event? {
        didSet {
            name.text = event?.name
            eventDescription.text = event?.description
            guard let start = event?.startTime, let end = event?.endTime else { return }
            let timeText = "\(start) - \(end)"
            time.text = timeText
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(100))/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        addShadow(withRadius: 8)
        styleLabels(labels: [name, eventDescription, time])
        addSubview(name)
        addSubview(time)
        addSubview(eventDescription)
    }
    
    private func styleLabels(labels: [UILabel]) {
        labels.forEach {
            $0.adjustsFontSizeToFitWidth = true
            $0.textColor = .white
            $0.textAlignment = .center
            $0.numberOfLines = 3
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        time.isHidden = contentHidden
        eventDescription.isHidden = contentHidden
        layer.cornerRadius = bounds.width/2
        let contentArea = bounds.insetBy(dx: Padding.small, dy: Padding.small)
        let nameSize = name.sizeThatFits(contentArea.size)
        let timeSize = time.sizeThatFits(contentArea.size)
        let descriptionSize = eventDescription.sizeThatFits(contentArea.size)
        let totalHeight = contentHidden ? nameSize.height : nameSize.height + Padding.large + timeSize.height + Padding.large + descriptionSize.height
        name.frame = CGRect(x: contentArea.midX - nameSize.width/2, y: contentArea.midY - totalHeight/2, size: nameSize)
        time.frame = CGRect(x: contentArea.midX - timeSize.width/2, y: name.frame.maxY + Padding.large, size: timeSize)
        eventDescription.frame = CGRect(x: contentArea.midX - descriptionSize.width/2, y: time.frame.maxY + Padding.large, size: descriptionSize)
    }
    
    private func addShadow(withRadius radius: CGFloat) {
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.75
        layer.shadowRadius = radius
    }
}
