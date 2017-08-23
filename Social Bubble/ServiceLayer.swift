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
    let time: String?
    let location: Location
}

public struct ServiceLayer {
    var events: Observable<[Event]> { return _events.asObservable() }
    private let _events = PublishSubject<[Event]>()
    
    public init() {}

    func fetchEvents(withSearchTerm searchTerm: String) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/search?q=\(searchTerm)&type=event")) { response, result in
            switch result {
            case .success(let response):
                guard let _json = response.dictionaryValue, let json = _json["data"] as? [[String: Any]] else { return }
                let events: [Event] = json.map { event in
                    guard let name = event["name"] as? String, let description = event["description"] as? String, let startTime = event["start_time"] as? String, let endTime = event["end_time"] as? String, let place = event["place"] as? [String: Any], let location = place["location"] as? [String: Any], let city = location["city"] as? String, let state = location["state"] as? String, let latitude = location["latitude"] as? Double, let longitude = location["longitude"] as? Double else { return nil }
                    let eventTime = self.formattedTime(startTime: startTime, endTime: endTime)
                    let eventLocation = Location(city: city, state: state, latitude: latitude, longitude: longitude)
                    return Event(name: name, description: description, time: eventTime, location: eventLocation)
                }.flatMap{ $0 }
                self._events.onNext(events)
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
    public func formattedTime(startTime: String, endTime: String) -> String? {
        guard let startString = formattedString(startTime), let endString = formattedString(endTime) else { return nil }
        return "\(startString) to \(endString)"
    }
    
    private func formattedString(_ time: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sszz"
        guard let date = formatter.date(from: time) else { return nil }
        formatter.dateFormat = "MMM d 'at' ha"
        return formatter.string(from: date)
    }
}

