import XCTest
import Social_Bubble

class Social_BubbleTests: XCTestCase {

    func testTimeStringConvertibleToDate() {
        let dateString = "2017-09-17T20:00:00-0500"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sszz"
        let date = formatter.date(from: dateString)
        formatter.dateFormat = "MMM d 'at' ha"
        let formattedDateString = formatter.string(from: date!)
        XCTAssertEqual("Sep 17 at 8PM", formattedDateString)
    }
    
    func testFormatterReturnsCorrectString() {
        let startTime = "2017-09-17T20:00:00-0500"
        let endTime = "2017-09-17T22:00:00-0500"
        let time = ServiceLayer().formattedTime(startTime: startTime, endTime: endTime)
        XCTAssertEqual(time, "Sep 17 at 8PM to Sep 17 at 10PM")
    }
}
