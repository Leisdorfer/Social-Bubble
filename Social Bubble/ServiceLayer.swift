import Foundation
import FacebookCore
import RxSugar
import RxSwift

struct Location {
    let city: String
    let state: String
    let latitude: Double
    let longitude: Double
}

struct Event {
    let name: String
    let description: String
    let startTime: String
    let endTime: String
    let location: Location
}

struct ServiceLayer {
    var events: Observable<[Event]> { return _events.asObservable() }
    private let _events = PublishSubject<[Event]>()

    func fetchEvents() {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/search?q=NewYork&type=event")) { response, result in
            switch result {
            case .success(let response):
                guard let _json = response.dictionaryValue, let json = _json["data"] as? [[String: Any]] else { return }
                let events: [Event] = json.map { event in
                    guard let name = event["name"] as? String, let description = event["description"] as? String, let startTime = event["start_time"] as? String, let endTime = event["end_time"] as? String, let place = event["place"] as? [String: Any], let location = place["location"] as? [String: Any], let city = location["city"] as? String, let state = location["state"] as? String, let latitude = location["latitude"] as? Double, let longitude = location["longitude"] as? Double else { return nil }
                    let eventLocation = Location(city: city, state: state, latitude: latitude, longitude: longitude)
                    return Event(name: name, description: description, startTime: startTime, endTime: endTime, location: eventLocation)
                }.flatMap{ $0 }
                self._events.onNext(events)
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
}

