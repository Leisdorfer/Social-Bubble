import UIKit
import RxSugar
import RxSwift

struct Binding {
    static func bind(view: SocialBubbleView, model: SocialBubbleModel) {
        view.rxs.disposeBag
            ++ { model.fetchEvents() } <~ view.loggedIn
            ++ { view.addEvents($0) } <~ model.events
    }
}

class ViewController: UIViewController {
    
    override func loadView() {
        let socialBubbleView = SocialBubbleView()
        view = socialBubbleView
        let model = SocialBubbleModel()
        Binding.bind(view: socialBubbleView, model: model)
        
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


