import UIKit

struct Animation {
    private let bounds: CGRect
    
    init(bounds: CGRect) {
        self.bounds = bounds
    }
    
    func animateView(_ view: UIView, withinViews views: [UIView]) {
        let duration: TimeInterval = 3
        UIView.animate(withDuration: duration, animations: {
            let diameter: CGFloat = self.bounds.width - (Padding.large * 2)
            view.frame.origin.y = self.bounds.midY - diameter/2
            view.frame.origin.x = self.bounds.midX - diameter/2
            view.frame.size.height = diameter
            view.frame.size.width = diameter
            self.animateCornerRadius(ofView: view, toRadius: view.frame.width/2, forDuration: duration)
            self.animateView(view, toFrontOf: views)
        }, completion: nil)
    }
    
    private func animateView(_ view: UIView, toFrontOf views: [UIView]) {
        let maxZPosition = views.reduce(0) { $0 + $1.layer.zPosition }
        view.layer.zPosition = maxZPosition + 1
    }
    
    private func animateCornerRadius (ofView view: UIView, toRadius radius: CGFloat, forDuration duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = view.layer.cornerRadius
        animation.toValue = radius
        animation.duration = duration
        view.layer.cornerRadius = radius
        view.layer.add(animation, forKey:"cornerRadius")
    }
}
