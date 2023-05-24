@testable import PoliceDataKit
import XCTest

final class PoliceOfficerTests: XCTestCase {

    func testDecodeReturnsPoliceOfficer() throws {
        let result = try JSONDecoder.policeDataAPI.decode(PoliceOfficer.self, fromResource: "police-officer")

        XCTAssertEqual(result, .mock)
    }

    func testDecodeWithNullsReturnsPoliceOfficer() throws {
        let result = try JSONDecoder.policeDataAPI
            .decode(PoliceOfficer.self, fromResource: "police-officer-nulls")

        XCTAssertEqual(result, .mockNoBioOrContactDetails)
    }

}
