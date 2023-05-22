import CoreLocation
@testable import PoliceDataKit
import XCTest

final class NeighbourhoodDefaultCacheTests: XCTestCase {

    var cache: NeighbourhoodDefaultCache!
    var cacheStore: MockCache!

    override func setUp() {
        super.setUp()
        cacheStore = MockCache()
        cache = NeighbourhoodDefaultCache(cacheStore: cacheStore)
    }

    override func tearDown() {
        cache = nil
        cacheStore = nil
        super.tearDown()
    }

    func testNeighbourhoodsInPoliceForceWhenMissReturnsNil() async {
        let policeForceID = "test-police-force"
        let result = await cache.neighbourhoods(inPoliceForce: policeForceID)

        XCTAssertNil(result)
    }

    func testNeighbourhoodsInPoliceForceWhenHitReturnsNeighbourReferences() async {
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodsInPoliceForceCachingKey(policeForceID: policeForceID)
        let expectedResult = NeighbourhoodReference.mocks
        await cacheStore.set(expectedResult, for: cacheKey)

        let result = await cache.neighbourhoods(inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
    }

    func testNeighbourhoodsInPoliceForceSetsNeighbourhoods() async {
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodsInPoliceForceCachingKey(policeForceID: policeForceID)
        let expectedResult = NeighbourhoodReference.mocks

        await cache.setNeighbourhoods(expectedResult, inPoliceForce: policeForceID)
        let result = await cacheStore.object(for: cacheKey, type: [NeighbourhoodReference].self)

        XCTAssertEqual(result, expectedResult)
    }

    func testNeighbourhoodWhenMissReturnsNil() async {
        let id = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let result = await cache.neighbourhood(withID: id, inPoliceForce: policeForceID)

        XCTAssertNil(result)
    }

    func testNeighbourhoodWhenHitReturnsNeighbour() async {
        let id = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodCachingKey(id: id, policeForceID: policeForceID)
        let expectedResult = Neighbourhood.mock
        await cacheStore.set(expectedResult, for: cacheKey)

        let result = await cache.neighbourhood(withID: id, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
    }

    func testSetNeighbourhoodSetsNeighbourhood() async {
        let id = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodCachingKey(id: id, policeForceID: policeForceID)
        let expectedResult = Neighbourhood.mock

        await cache.setNeighbourhood(expectedResult, withID: id, inPoliceForce: policeForceID)
        let result = await cacheStore.object(for: cacheKey, type: Neighbourhood.self)

        XCTAssertEqual(result, expectedResult)
    }

    func testBoundaryForNeighbourhoodWhenMissReturnsNil() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let result = await cache.boundary(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertNil(result)
    }

    func testBoundaryForNeighbourhoodWhenHitReturnsBoundary() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodBoundaryCachingKey(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID)
        let expectedResult = CLLocationCoordinate2D.mocks
        await cacheStore.set(expectedResult, for: cacheKey)

        let result = await cache.boundary(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
    }

    func testSetBoundaryForNeighbourhoodSetsBoundary() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodBoundaryCachingKey(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID)
        let expectedResult = CLLocationCoordinate2D.mocks

        await cache.setBoundary(expectedResult, forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)
        let result = await cacheStore.object(for: cacheKey, type: [CLLocationCoordinate2D].self)

        XCTAssertEqual(result, expectedResult)
    }

    func testPoliceOfficersForNeighbourhoodWhenMissReturnsNil() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let result = await cache.policeOfficers(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertNil(result)
    }

    func testPoliceOfficersForNeighbourhoodWhenHitReturnsPoliceOfficers() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodPoliceOfficersCachingKey(neighbourhoodID: neighbourhoodID,
                                                             policeForceID: policeForceID)
        let expectedResult = PoliceOfficer.mocks
        await cacheStore.set(expectedResult, for: cacheKey)

        let result = await cache.policeOfficers(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
    }

    func testSetPoliceOfficersForNeighbourhoodSetsPoliceOfficers() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodPoliceOfficersCachingKey(neighbourhoodID: neighbourhoodID,
                                                             policeForceID: policeForceID)
        let expectedResult = PoliceOfficer.mocks

        await cache.setPoliceOfficers(expectedResult, forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)
        let result = await cacheStore.object(for: cacheKey, type: [PoliceOfficer].self)

        XCTAssertEqual(result, expectedResult)
    }

    func testPrioritiesForNeighbourhoodWhenMissReturnsNil() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let result = await cache.priorities(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertNil(result)
    }

    func testPrioritiesForNeighbourhoodWhenHitReturnsPriorities() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodPrioritiesCachingKey(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID)
        let expectedResult = NeighbourhoodPriority.mocks
        await cacheStore.set(expectedResult, for: cacheKey)

        let result = await cache.priorities(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
    }

    func testSetPrioritiesForNeighbourhoodSetsPoliceOfficers() async {
        let neighbourhoodID = "test-neighbourhood"
        let policeForceID = "test-police-force"
        let cacheKey = NeighbourhoodPrioritiesCachingKey(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID)
        let expectedResult = NeighbourhoodPriority.mocks

        await cache.setPriorities(expectedResult, forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)
        let result = await cacheStore.object(for: cacheKey, type: [NeighbourhoodPriority].self)

        XCTAssertEqual(result, expectedResult)
    }

}
