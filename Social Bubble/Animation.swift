import UIKit

struct Animation {
    private let bounds: CGRect
    private let duration: TimeInterval = 1

    init(bounds: CGRect) {
        self.bounds = bounds
    }

    func animateInView(_ bubble: BubbleView, amongstBubbles bubbles: [BubbleView], withinView view: SocialBubbleView) -> Animation {
        let intialBubble = bubble.frame
        UIView.animate(withDuration: duration, animations: {
            let diameter: CGFloat = self.bounds.width - (Padding.large * 2)
            self.animateCornerRadius(ofView: bubble, toRadius: diameter/2, forDuration: self.duration)
            bubble.frame.origin.y = self.bounds.midY - diameter/2
            bubble.frame.origin.x = self.bounds.midX - diameter/2
            bubble.frame.size.height = diameter
            bubble.frame.size.width = diameter
            self.animateView(bubble, toFrontOf: bubbles)
        }, completion: { (finished: Bool) in
            bubble.showEvent()
            view.isUserInteractionEnabled = true
            view.expandedBubble = true
        })
       return Animation(bounds: intialBubble)
    }
    
    func animateOutView(_ bubble: BubbleView, withinView view: SocialBubbleView) -> Animation {
        bubble.hideEvent()
        UIView.animate(withDuration: duration, animations: {
            let diameter: CGFloat = self.bounds.width
            self.animateCornerRadius(ofView: bubble, toRadius: diameter/2, forDuration: self.duration)
            bubble.frame.origin.y = self.bounds.midY - diameter/2
            bubble.frame.origin.x = self.bounds.midX - diameter/2
            bubble.frame.size.height = diameter
            bubble.frame.size.width = diameter
        }, completion: { (finished: Bool) in
            bubble.layer.zPosition = 0
            view.isUserInteractionEnabled = true
            view.expandedBubble = false
        })
        return Animation(bounds: bubble.bounds)
    }
    
    private func animateView(_ view: BubbleView, toFrontOf views: [BubbleView]) {
        view.layer.zPosition  = views.reduce(0) { $0 + $1.layer.zPosition } + 1
    }

    private func animateCornerRadius (ofView view: BubbleView, toRadius radius: CGFloat, forDuration duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = view.layer.cornerRadius
        animation.toValue = radius
        animation.duration = duration
        view.layer.cornerRadius = radius
        view.layer.add(animation, forKey:"cornerRadius")
    }
}
