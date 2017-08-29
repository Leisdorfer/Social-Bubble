import Foundation
import GooglePlaces
import RxSugar
import RxSwift

class SocialBubbleModel: RXSObject {
    let serviceLayer = ServiceLayer()
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
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        let client = GMSPlacesClient()
        client.autocompleteQuery(term, bounds: nil, filter: filter, callback: { [weak self] result, error in
            guard let `self` = self, let _result = result else { return }
            let cities = _result.map { $0.attributedPrimaryText.string }
            let uniqueCities = Set(cities)
            self.autocompleteFields.value = uniqueCities.filter { $0.contains(term) }
        })
    }
}
