import Foundation
import FacebookCore
import RxSugar
import RxSwift

class SocialBubbleModel: RXSObject {
    let serviceLayer = ServiceLayer()
    let cities = ["STL", "St. Louis", "San Fran", "Chicago"]
    
    let localEvents = Variable<[Event]>([])
    let autocompleteFields = Variable<[String]>([])
    
    init() {
        rxs.disposeBag
            ++ { [weak self] in self?.prioritizeEvents($0) } <~ serviceLayer.events
    }
    
    func fetchEvents(_ searchTerm: String) {
        serviceLayer.fetchEvents(withSearchTerm: searchTerm)
    }
    
    private func prioritizeEvents(_ events: [Event])  {
        let currentDate = Date()
        let sortedEvents = events.sorted { $0.startTime < $1.startTime }
        localEvents.value = sortedEvents.filter { currentDate < $0.startTime }
    }
    
    func fetchLocationSuggestions(_ term: String) {
        autocompleteFields.value = cities.filter { $0.contains(term) }
    }
}
