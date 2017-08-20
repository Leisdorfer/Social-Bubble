import UIKit

struct Animation {
    private let bounds: CGRect

    init(bounds: CGRect) {
        self.bounds = bounds
    }
    
    func animateView(_ view: BubbleView, withinViews views: [BubbleView]) {
        let duration: TimeInterval = 2
        UIView.animate(withDuration: duration, animations: {
            let diameter: CGFloat = self.bounds.width - (Padding.large * 2)
            self.animateCornerRadius(ofView: view, toRadius: diameter/2, forDuration: duration)
            view.frame.origin.y = self.bounds.midY - diameter/2
            view.frame.origin.x = self.bounds.midX - diameter/2
            view.frame.size.height = diameter
            view.frame.size.width = diameter
            self.animateView(view, toFrontOf: views)
        }, completion: { (finished: Bool) in
            view.updateEvent()
        })
    }
    
    private func animateView(_ view: BubbleView, toFrontOf views: [BubbleView]) {
        let maxZPosition = views.reduce(0) { $0 + $1.layer.zPosition }
        view.layer.zPosition = maxZPosition + 1
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
