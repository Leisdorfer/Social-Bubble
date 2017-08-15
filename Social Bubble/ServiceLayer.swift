import Foundation
import FacebookCore

struct ServiceLayer {
    func fetchEvents() {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/search?q=St.Louis,STL&type=event")) { response, result in
            switch result {
            case .success(let response): print("----------------->Graph Request Succeeded: \(response)")
            case .failed(let error): print("---------------------->Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
}

