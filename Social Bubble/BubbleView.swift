import UIKit
import RxSugar
import RxSwift

class Divider: UIView {
    private let height: CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: height)
    }
}

class BubbleView: UIButton {
    private let name = UILabel()
    private let time = UILabel()
    private let topDivider = Divider()
    private let scrollView = UIScrollView()
    private let eventDescription = UILabel()
    private let bottomDivider = Divider()
    private let directions = UIButton()
    private let details = UIButton()
    private var contentHidden = true
    
    let selectDirection: Observable<Void>
    let selectDetails: Observable<Void>
    let event = Variable<Event?>(nil)
    let displayEvent: AnyObserver<Bool>
    private let _displayEvent = Variable<Bool>(false)

    override init(frame: CGRect) {
        selectDirection = directions.rxs.tap
        selectDetails = details.rxs.tap
        displayEvent = _displayEvent.asObserver()
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(100))/100.0, saturation: 1.0, brightness: 0.75, alpha: 1.0)
        addShadow(withRadius: 10)
        styleLabels(labels: [name, time])
        name.font = UIFont.systemFont(ofSize: 22)
        addSubview(name)
        time.font = UIFont.systemFont(ofSize: 18)
        addSubview(time)
        topDivider.isHidden = true
        addSubview(topDivider)
        scrollView.isHidden = true
        addSubview(scrollView)
        eventDescription.font = UIFont.systemFont(ofSize: 16)
        eventDescription.numberOfLines = 0
        eventDescription.textColor = .white
        eventDescription.textAlignment = .center
        eventDescription.adjustsFontSizeToFitWidth = false
        scrollView.addSubview(eventDescription)
        bottomDivider.isHidden = true
        addSubview(bottomDivider)
        styleButtons(buttons: [directions, details])
        directions.setTitle("Directions", for: .normal)
        addSubview(directions)
        details.setTitle("Details", for: .normal)
        details.isUserInteractionEnabled = true
        addSubview(details)
        
        rxs.disposeBag
            ++ { [weak self] in self?.displayEventContent($0) } <~ event.asObservable()
            ++ { [weak self] in self?.displayDetails() } <~ selectDetails
            ++ { [weak self] in self?.hideOrDisplayEvent($0) } <~ _displayEvent.asObservable()
    }
    
    private func displayEventContent(_ event: Event?) {
        name.text = event?.name
        eventDescription.text = event?.description
        time.text = "Aug 19 at 2pm to Aug 20 at 3pm"
        isUserInteractionEnabled = true
        setNeedsLayout()
    }
    
    private func displayDetails() {
        [topDivider, scrollView, bottomDivider].forEach { $0.isHidden = false }
        details.isUserInteractionEnabled = false
        setNeedsLayout()
    }
    
    private func hideOrDisplayEvent(_ shouldDisplay: Bool) {
        if shouldDisplay {
            contentHidden = false
        } else {
            contentHidden = true
            [topDivider, scrollView, bottomDivider].forEach { $0.isHidden = true }
            details.isUserInteractionEnabled = true
        }
        setNeedsLayout()
    }
    
    private func styleLabels(labels: [UILabel]) {
        labels.forEach {
            $0.adjustsFontSizeToFitWidth = true
            $0.textColor = .white
            $0.textAlignment = .center
            $0.numberOfLines = 3
        }
    }
    
    private func styleButtons(buttons: [UIButton]) {
        buttons.forEach {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
            $0.setTitleColor(.white, for: .normal)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        time.isHidden = contentHidden
        directions.isHidden = contentHidden
        details.isHidden = contentHidden
        layer.cornerRadius = bounds.width/2
        let contentArea = bounds.insetBy(dx: Padding.small, dy: Padding.small)
        let nameSize = name.sizeThatFits(contentArea.size)
        let timeSize = time.sizeThatFits(contentArea.size)
        let descriptionSize = eventDescription.sizeThatFits(scrollView.contentSize)
        let detailsSize = details.sizeThatFits(contentArea.size)
        let directionsSize = directions.sizeThatFits(contentArea.size)
        let buttonSize = directionsSize.width > detailsSize.width ? directionsSize : detailsSize
        let dividerArea = contentArea.insetBy(dx: Padding.small, dy: 0)
        let dividerSize = topDivider.sizeThatFits(dividerArea.size)
        let scrollViewHeight: CGFloat = 75
        var totalHeight = contentHidden ? nameSize.height : nameSize.height + Padding.small + timeSize.height + Padding.small + buttonSize.height
        totalHeight = scrollView.isHidden ? totalHeight : nameSize.height + Padding.small + timeSize.height + Padding.small + dividerSize.height + Padding.small + scrollViewHeight + Padding.small + dividerSize.height + Padding.small + buttonSize.height
        name.frame = CGRect(x: contentArea.midX - nameSize.width/2, y: contentArea.midY - totalHeight/2, size: nameSize)
        time.frame = CGRect(x: contentArea.midX - timeSize.width/2, y: name.frame.maxY + Padding.small, size: timeSize)
        topDivider.frame = CGRect(x: contentArea.midX - dividerSize.width/2, y: time.frame.maxY + Padding.small, size: dividerSize)
        scrollView.frame = CGRect(x: contentArea.minX, y: topDivider.frame.maxY + Padding.small, width: contentArea.width, height: scrollViewHeight)
        scrollView.contentSize = CGSize(width: contentArea.width, height: descriptionSize.height)
        eventDescription.frame = CGRect(x: 0, y: 0, size: descriptionSize)
        bottomDivider.frame = CGRect(x: contentArea.midX - dividerSize.width/2, y: scrollView.frame.maxY + Padding.small, size: dividerSize)
        let buttonWidth = buttonSize.width + Padding.small * 2
        let totalWidth = (buttonWidth * 2) + Padding.small
        let buttonY = scrollView.isHidden ? time.frame.maxY + Padding.small : bottomDivider.frame.maxY + Padding.small
        details.frame = CGRect(x: contentArea.midX - totalWidth/2, y: buttonY, width: buttonWidth, height: buttonSize.height)
        directions.frame = CGRect(x: details.frame.maxX + Padding.small, y: buttonY, width: buttonWidth, height: buttonSize.height)
    }
    
    private func addShadow(withRadius radius: CGFloat) {
        layer.shadowColor = backgroundColor?.cgColor//UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.75
        layer.shadowRadius = radius
    }
}
