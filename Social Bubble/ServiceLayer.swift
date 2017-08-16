import Foundation
import FacebookCore
import RxSugar
import RxSwift

struct Event {
    let name: String
    let description: String
    let startTime: String
    let endTime: String
}

struct ServiceLayer {
    
    var events: Observable<[Event]> { return _events.asObservable() }
    private let _events = PublishSubject<[Event]>()

    func fetchEvents() {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/search?q=St.Louis,STL&type=event")) { response, result in
            switch result {
            case .success(let response):
                guard let _json = response.dictionaryValue, let json = _json["data"] as? [[String: Any]] else { return }
                let events: [Event] = json.map { event in
                    guard let name = event["name"] as? String, let description = event["description"] as? String, let startTime = event["start_time"] as? String, let endTime = event["end_time"] as? String else { return nil }
                    return Event(name: name, description: description, startTime: startTime, endTime: endTime)
                }.flatMap{ $0 }
                self._events.onNext(events)
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
}

