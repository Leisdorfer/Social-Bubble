import UIKit
import RxSugar
import RxSwift

struct Binding {
    static func bind(view: SocialBubbleView, model: ServiceLayer) {
        view.rxs.disposeBag
            ++ { model.fetchEvents() } <~ view.loggedIn
    }
}

class ViewController: UIViewController {
    
    override func loadView() {
        let socialBubbleView = SocialBubbleView()
        view = socialBubbleView
        let serviceLayer = ServiceLayer()
        Binding.bind(view: socialBubbleView, model: serviceLayer)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}


