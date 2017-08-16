import Foundation
import FacebookCore
import RxSugar
import RxSwift

class SocialBubbleModel: RXSObject {
    let serviceLayer = ServiceLayer()
    
    let events = Variable<[Event]>([])
    
    init() {
        rxs.disposeBag
            ++  events <~ serviceLayer.events
    }
    
    func fetchEvents() {
       serviceLayer.fetchEvents()
    }
}
