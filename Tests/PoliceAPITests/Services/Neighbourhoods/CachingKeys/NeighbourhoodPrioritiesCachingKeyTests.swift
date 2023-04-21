@testable import PoliceAPI
import XCTest

final class NeighbourhoodPrioritiesCachingKeyTests: XCTestCase {

    func testKeyValue() {
        let neighbourhoodID = "987zyw"
        let policeForceID = "abc123"

        let cacheKey = NeighbourhoodPrioritiesCachingKey(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID)

        XCTAssertEqual(cacheKey.keyValue, "neighbourhood-priorities-\(neighbourhoodID)-\(policeForceID)")
    }

}
