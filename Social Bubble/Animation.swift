import UIKit
import RxSugar
import RxSwift

struct Animation {
    private let bubble: BubbleView
    private let view: SocialBubbleView
    private let bounds: CGRect
    private let duration: TimeInterval = 1
    private let disposeBag = DisposeBag()
    
    private let _showEvent = Variable<Bool>(false)
    private let _expandedBubble = Variable<Bool>(false)

    init(bubble: BubbleView, view: SocialBubbleView, bounds: CGRect) {
        self.bubble = bubble
        self.bounds = bounds
        self.view = view
        disposeBag
            ++ bubble.displayEvent <~ _showEvent.asObservable()
            ++ view.expandedBubble <~ _expandedBubble.asObservable()
    }

    func animateInBubbleView(amongstBubbles bubbles: [BubbleView]) -> Animation {
        let intialBubble = bubble.frame
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: duration, animations: {
            let diameter: CGFloat = self.bounds.width - (Padding.large * 2)
            self.animateBubbleCornerRadius(toRadius: diameter/2, forDuration: self.duration)
            self.animateBubbleFrame(withDiameter: diameter)
            self.animateBubbleView(toFrontOf: bubbles)
        }, completion: { (finished: Bool) in
            self._showEvent.value = true
            self.view.isUserInteractionEnabled = true
            self._expandedBubble.value = true
        })
        return Animation(bubble: bubble, view: view, bounds: intialBubble)
    }
    
    func animateOutBubbleView() {
        self._showEvent.value = false
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: duration, animations: {
            let diameter: CGFloat = self.bounds.width
            self.animateBubbleCornerRadius(toRadius: diameter/2, forDuration: self.duration)
            self.animateBubbleFrame(withDiameter: diameter)
        }, completion: { (finished: Bool) in
            self.bubble.layer.zPosition = 0
            self.view.isUserInteractionEnabled = true
            self._expandedBubble.value = false
        })
    }
    
    private func animateBubbleFrame(withDiameter diameter: CGFloat) {
        bubble.frame.origin.y = self.bounds.midY - diameter/2
        bubble.frame.origin.x = self.bounds.midX - diameter/2
        bubble.frame.size.height = diameter
        bubble.frame.size.width = diameter
    }
    
    private func animateBubbleView(toFrontOf views: [BubbleView]) {
        self.bubble.layer.zPosition  = views.reduce(0) { $0 + $1.layer.zPosition } + 1
    }

    private func animateBubbleCornerRadius (toRadius radius: CGFloat, forDuration duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = self.bubble.layer.cornerRadius
        animation.toValue = radius
        animation.duration = duration
        self.bubble.layer.cornerRadius = radius
        self.bubble.layer.add(animation, forKey:"cornerRadius")
    }
}
