import MapKit
@testable import PoliceAPI
import XCTest

final class UKNeighbourhoodRepositoryTests: XCTestCase {

    var repository: UKNeighbourhoodRepository!
    var apiClient: MockAPIClient!
    var cache: MockCache!
    var availableDataRegion: MKCoordinateRegion!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        cache = MockCache()
        availableDataRegion = .test
        repository = UKNeighbourhoodRepository(
            apiClient: apiClient,
            cache: cache,
            availableDataRegion: availableDataRegion
        )
    }

    override func tearDown() {
        repository = nil
        availableDataRegion = nil
        cache = nil
        apiClient = nil
        super.tearDown()
    }

    func testNeighboursWhenNotCachedReturnsNeighbourhoodReferences() async throws {
        let policeForceID = "leicestershire"
        let expectedResult = NeighbourhoodReferenceDataModel.mocks.map(NeighbourhoodReference.init)
        apiClient.response = .success(NeighbourhoodReferenceDataModel.mocks)

        let result = try await repository.neighbourhoods(inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, NeighbourhoodsEndpoint.list(policeForceID: policeForceID).path)
    }

    func testNeighboursWhenCachedReturnsCachedNeighbourhoodReferences() async throws {
        let policeForceID = "leicestershire"
        let cacheKey = NeighbourhoodsInPoliceForceCachingKey(policeForceID: policeForceID)
        let expectedResult = NeighbourhoodReferenceDataModel.mocks.map(NeighbourhoodReference.init)
        await cache.set(expectedResult, for: cacheKey)

        let result = try await repository.neighbourhoods(inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertNil(apiClient.lastPath)
    }

    func testNeighboursWhenNotCachedAndReturnsNeighbourhoodReferencesShouldCacheResult() async throws {
        let policeForceID = "leicestershire"
        let cacheKey = NeighbourhoodsInPoliceForceCachingKey(policeForceID: policeForceID)
        let expectedResult = NeighbourhoodReferenceDataModel.mocks.map(NeighbourhoodReference.init)
        apiClient.response = .success(NeighbourhoodReferenceDataModel.mocks)
        _ = try await repository.neighbourhoods(inPoliceForce: policeForceID)

        let cachedResult = await cache.object(for: cacheKey, type: [NeighbourhoodReference].self)

        XCTAssertEqual(cachedResult, expectedResult)
    }

    func testNeighbourhoodWhenNotCachedReturnsNeighbourhood() async throws {
        let expectedResult = Neighbourhood(dataModel: .mock)
        let id = expectedResult.id
        let policeForceID = "leicestershire"
        apiClient.response = .success(NeighbourhoodDataModel.mock)

        let result = try await repository.neighbourhood(withID: id, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, NeighbourhoodsEndpoint.details(id: id, policeForceID: policeForceID).path)
    }

    func testNeighbourhoodWhenNotCachedAndNotFoundThrowsNotFoundError() async throws {
        let id = "NC04"
        let policeForceID = "leicestershire"
        apiClient.response = .failure(APIClientError.notFound)

        var resultError: NeighbourhoodError?
        do {
            _ = try await repository.neighbourhood(withID: id, inPoliceForce: policeForceID)
        } catch let error as NeighbourhoodError {
            resultError = error
        }

        XCTAssertEqual(resultError, .notFound)
    }

    func testNeighbourhoodWhenCachedReturnsCachedNeighbourhood() async throws {
        let expectedResult = Neighbourhood(dataModel: .mock)
        let id = expectedResult.id
        let policeForceID = "leicestershire"
        let cacheKey = NeighbourhoodCachingKey(id: id, policeForceID: policeForceID)
        await cache.set(expectedResult, for: cacheKey)

        let result = try await repository.neighbourhood(withID: id, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertNil(apiClient.lastPath)
    }

    func testNeighbourhoodWhenNotCachedAndReturnsNeighbourhoodShouldCacheResult() async throws {
        let expectedResult = Neighbourhood(dataModel: .mock)
        let id = expectedResult.id
        let policeForceID = "leicestershire"
        let cacheKey = NeighbourhoodCachingKey(id: id, policeForceID: policeForceID)
        apiClient.response = .success(NeighbourhoodDataModel.mock)
        _ = try await repository.neighbourhood(withID: id, inPoliceForce: policeForceID)

        let cachedResult = await cache.object(for: cacheKey, type: Neighbourhood.self)

        XCTAssertEqual(cachedResult, expectedResult)
    }

    func testBoundaryWhenNotCachedReturnsBoundary() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = [CLLocationCoordinate2D](dataModel: .mock)
        apiClient.response = .success(BoundaryDataModel.mock)

        let result = try await repository.boundary(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(
            apiClient.lastPath,
            NeighbourhoodsEndpoint.boundary(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID).path
        )
    }

    func testBoundaryWhenNotCachedAndNotFoundThrowsNotFoundError() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        apiClient.response = .failure(APIClientError.notFound)

        var resultError: NeighbourhoodError?
        do {
            _ = try await repository.boundary(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)
        } catch let error as NeighbourhoodError {
            resultError = error
        }

        XCTAssertEqual(resultError, .notFound)
    }

    func testBoundaryWhenCachedReturnsCachedBoundary() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = [CLLocationCoordinate2D](dataModel: .mock)
        let cacheKey = NeighbourhoodBoundaryCachingKey(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID)
        await cache.set(expectedResult, for: cacheKey)

        let result = try await repository.boundary(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertNil(apiClient.lastPath)
    }

    func testBoundaryWhenNotCachedAndReturnsBoundaryShouldCacheResult() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = [CLLocationCoordinate2D](dataModel: .mock)
        let cacheKey = NeighbourhoodBoundaryCachingKey(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID)
        apiClient.response = .success(BoundaryDataModel.mock)
        _ = try await repository.boundary(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        let cachedResult = await cache.object(for: cacheKey, type: [CLLocationCoordinate2D].self)

        XCTAssertEqual(cachedResult, expectedResult)
    }

    func testPoliceOfficersWhenNotCachedReturnsPoliceOfficers() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = PoliceOfficerDataModel.mocks.map(PoliceOfficer.init)
        apiClient.response = .success(PoliceOfficerDataModel.mocks)

        let result = try await repository.policeOfficers(forNeighbourhood: neighbourhoodID,
                                                         inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(
            apiClient.lastPath,
            NeighbourhoodsEndpoint.policeOfficers(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID).path
        )
    }

    func testPoliceOfficersWhenCachedReturnsCachedPoliceOfficers() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = PoliceOfficerDataModel.mocks.map(PoliceOfficer.init)
        let cacheKey = NeighbourhoodPoliceOfficersCachingKey(
            neighbourhoodID: neighbourhoodID, policeForceID: policeForceID
        )
        await cache.set(expectedResult, for: cacheKey)

        let result = try await repository.policeOfficers(forNeighbourhood: neighbourhoodID,
                                                         inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertNil(apiClient.lastPath)
    }

    func testPoliceOfficersWhenNotCachedAndReturnsPoliceOfficersShouldCacheResult() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = PoliceOfficerDataModel.mocks.map(PoliceOfficer.init)
        let cacheKey = NeighbourhoodPoliceOfficersCachingKey(
            neighbourhoodID: neighbourhoodID, policeForceID: policeForceID
        )
        apiClient.response = .success(PoliceOfficerDataModel.mocks)
        _ = try await repository.policeOfficers(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        let cachedResult = await cache.object(for: cacheKey, type: [PoliceOfficer].self)

        XCTAssertEqual(cachedResult, expectedResult)
    }

    func testPrioritiesWhenNotCachedReturnsNeighbourhoodPriorities() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = NeighbourhoodPriorityDataModel.mocks.map(NeighbourhoodPriority.init)
        apiClient.response = .success(NeighbourhoodPriorityDataModel.mocks)

        let result = try await repository.priorities(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(
            apiClient.lastPath,
            NeighbourhoodsEndpoint.priorities(neighbourhoodID: neighbourhoodID, policeForceID: policeForceID).path
        )
    }

    func testPrioritiesWhenCachedReturnsCachedNeighbourhoodPriorities() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = NeighbourhoodPriorityDataModel.mocks.map(NeighbourhoodPriority.init)
        let cacheKey = NeighbourhoodPrioritiesCachingKey(
            neighbourhoodID: neighbourhoodID, policeForceID: policeForceID
        )
        await cache.set(expectedResult, for: cacheKey)

        let result = try await repository.priorities(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertNil(apiClient.lastPath)
    }

    func testPrioritiesWhenNotCachedAndReturnsNeighbourhoodPrioritiesShouldCacheResult() async throws {
        let neighbourhoodID = "NC04"
        let policeForceID = "leicestershire"
        let expectedResult = NeighbourhoodPriorityDataModel.mocks.map(NeighbourhoodPriority.init)
        let cacheKey = NeighbourhoodPrioritiesCachingKey(
            neighbourhoodID: neighbourhoodID, policeForceID: policeForceID
        )
        apiClient.response = .success(NeighbourhoodPriorityDataModel.mocks)
        _ = try await repository.priorities(forNeighbourhood: neighbourhoodID, inPoliceForce: policeForceID)

        let cachedResult = await cache.object(for: cacheKey, type: [NeighbourhoodPriority].self)

        XCTAssertEqual(cachedResult, expectedResult)
    }

    func testNeighbourhoodPolicingTeamAtCoordinateReturnsNeighbourhoodPolicingTeam() async throws {
        let coordinate = CLLocationCoordinate2D.mock
        let expectedResult = NeighbourhoodPolicingTeam(dataModel: .mock)
        apiClient.response = .success(NeighbourhoodPolicingTeamDataModel.mock)

        let result = try await repository.neighbourhoodPolicingTeam(at: coordinate)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, NeighbourhoodsEndpoint.locateNeighbourhood(coordinate: coordinate).path)
    }

    func testNeighbourhoodPolicingTeamAtCoordinateWhenNotFoundThrowsNotFoundError() async throws {
        let coordinate = CLLocationCoordinate2D.mock
        apiClient.response = .failure(APIClientError.notFound)

        var resultError: NeighbourhoodError?
        do {
            _ = try await repository.neighbourhoodPolicingTeam(at: coordinate)
        } catch let error as NeighbourhoodError {
            resultError = error
        }

        XCTAssertEqual(resultError, .notFound)
    }

    func testNeighbourhoodPolicingTeamAtCoordsWhenNotInAvailableDataRegionThrowsError() async throws {
        let coordinate = CLLocationCoordinate2D(dataModel: .outsideAvailableDataRegion)
        let expectedResult = NeighbourhoodPolicingTeamDataModel.mock
        apiClient.response = .success(expectedResult)

        var resultError: NeighbourhoodError?
        do {
            _ = try await repository.neighbourhoodPolicingTeam(at: coordinate)
        } catch let error as NeighbourhoodError {
            resultError = error
        }

        XCTAssertEqual(resultError, .locationOutsideOfDataSetRegion)
        XCTAssertNil(apiClient.lastPath)
    }

}
