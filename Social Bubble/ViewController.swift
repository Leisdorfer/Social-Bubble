import UIKit

class ViewController: UIViewController {
    
    override func loadView() {
        view = SocialBubbleView()
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


