import UIKit
import RxSugar
import RxSwift

struct Binding {
    static func bind(view: SocialBubbleView, model: SocialBubbleModel, controller: ViewController) {
        view.rxs.disposeBag
            ++ { model.fetchEvents() } <~ view.loggedIn.filter { $0 }.toVoid()
            ++ { view.addEvents($0) } <~ model.events
            ++ { controller.displayDirections($0) } <~ view.selectDirection.asObservable()
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
    
    func displayDirections(_ event: Event) {
        let latitude = event.location.latitude
        let longitude = event.location.longitude
        let location = "\(latitude),\(longitude)"
        let googleMaps = URL(string: "comgooglemaps://?q=cupertino")!
        let waze = URL(string: "waze://")!
        guard let appleMapsURL = URL(string: "maps://?daddr=\(location)"), let googleMapsURL = URL(string: "comgooglemaps://?daddr=\(location)"), let wazeURL = URL(string: "waze://?ll=\(location)&navigate=yes") else { return }

        var enabledDirectionsApps: [String: URL] = [:]
        
        if UIApplication.shared.canOpenURL(appleMapsURL) {
            enabledDirectionsApps["Apple Maps"] = appleMapsURL
        }
        
        if UIApplication.shared.canOpenURL(googleMaps) {
            enabledDirectionsApps["Google Maps"] = googleMapsURL
        }
        
        if UIApplication.shared.canOpenURL(waze) {
            enabledDirectionsApps["Waze"] = wazeURL
        }
        
        if enabledDirectionsApps.values.count > 1 {
            let actionSheet = UIAlertController(title: "Select Navigation App", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            for (title, url) in enabledDirectionsApps {
                actionSheet.addAction(
                    UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { _ in
                        UIApplication.shared.openURL(url)
                    })
                )
            }
            present(actionSheet, animated: true, completion: nil)
            
        } else {
            UIApplication.shared.openURL(appleMapsURL)
        }
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}


