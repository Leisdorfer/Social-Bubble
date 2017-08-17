import UIKit
import RxSugar
import RxSwift

struct Binding {
    static func bind(view: SocialBubbleView, model: SocialBubbleModel, controller: ViewController) {
        view.rxs.disposeBag
            ++ { model.fetchEvents() } <~ view.loggedIn.filter { $0 == true }.toVoid()
            ++ { view.addEvents($0) } <~ model.events
            ++ { controller.presentEvent() } <~ view.selection
    }
}

class ViewController: UIViewController {
    
    override func loadView() {
        let socialBubbleView = SocialBubbleView()
        view = socialBubbleView
        let model = SocialBubbleModel()
        Binding.bind(view: socialBubbleView, model: model, controller: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func presentEvent() {
        let socialEventView = SocialEventView()
        view = socialEventView
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}


