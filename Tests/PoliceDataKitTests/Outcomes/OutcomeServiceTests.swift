//
//  OutcomeServiceTests.swift
//  PoliceDataKit
//
//  Copyright © 2024 Adam Young.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an AS IS BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Combine
import MapKit
@testable import PoliceDataKit
import XCTest

final class OutcomeServiceTests: XCTestCase {

    var service: OutcomeService!
    var apiClient: MockAPIClient!
    var cache: OutcomeMockCache!
    var availableDataRegion: MKCoordinateRegion!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        cache = OutcomeMockCache()
        availableDataRegion = .test
        cancellables = Set<AnyCancellable>()
        service = OutcomeService(apiClient: apiClient, cache: cache, availableDataRegion: availableDataRegion)
    }

    override func tearDown() {
        service = nil
        cancellables = nil
        availableDataRegion = nil
        cache = nil
        apiClient = nil
        super.tearDown()
    }

    func testStreetLevelOutcomesForStreetWhenNotCachedReturnsOutcomes() async throws {
        let expectedResult = Outcome.mocks
        let streetID = expectedResult[0].crime.location.street.id
        let date = Date()
        apiClient.add(response: .success(Outcome.mocks))

        let result = try await service.streetLevelOutcomes(forStreet: streetID, date: date)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.requestedURLs.count, 1)
        XCTAssertEqual(
            apiClient.requestedURLs.last,
            OutcomesEndpoint.streetLevelOutcomesForStreet(streetID: streetID, date: date).path
        )
    }

    func testStreetLevelOutcomesForStreetWhenCachedReturnsCachedOutcomes() async throws {
        let expectedResult = Outcome.mocks
        let streetID = expectedResult[0].crime.location.street.id
        let date = Date()
        await cache.setStreetLevelOutcomes(expectedResult, forStreet: streetID, date: date)

        let result = try await service.streetLevelOutcomes(forStreet: streetID, date: date)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.requestedURLs.count, 0)
    }

    func testStreetLevelOutcomesForStreetWhenNotCachedAndReturnsOutcomesShouldCacheResult() async throws {
        let expectedResult = Outcome.mocks
        let streetID = expectedResult[0].crime.location.street.id
        let date = Date()
        apiClient.add(response: .success(Outcome.mocks))
        _ = try await service.streetLevelOutcomes(forStreet: streetID, date: date)

        let cachedResult = await cache.streetLevelOutcomes(forStreet: streetID, date: date)

        XCTAssertEqual(cachedResult, expectedResult)
    }

    func testStreetLevelOutcomesAtCoordinateReturnsOutcomes() async throws {
        let coordinate = CLLocationCoordinate2D.mock
        let expectedResult = Outcome.mocks
        let date = Date()
        apiClient.add(response: .success(Outcome.mocks))

        let result = try await service.streetLevelOutcomes(at: coordinate, date: date)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.requestedURLs.count, 1)
        XCTAssertEqual(
            apiClient.requestedURLs.last,
            OutcomesEndpoint.streetLevelOutcomesAtSpecificPoint(coordinate: coordinate, date: date).path
        )
    }

    func testStreetLevelOutcomesPublisherAtCoordinateReturnsOutcomes() {
        let coordinate = CLLocationCoordinate2D.mock
        let expectedResult = Outcome.mocks
        let date = Date()
        apiClient.add(response: .success(Outcome.mocks))

        let expectation = expectation(description: "StreetLevelOutcomesPublisher")
        var result: [Outcome]?
        service.streetLevelOutcomesPublisher(at: coordinate)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { outcomes in
                result = outcomes
            }
            .store(in: &cancellables)

        wait(for: [expectation])

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.requestedURLs.count, 1)
        XCTAssertEqual(
            apiClient.requestedURLs.last,
            OutcomesEndpoint.streetLevelOutcomesAtSpecificPoint(coordinate: coordinate, date: date).path
        )
    }

    func testStreetLevelOutcomesAtCoordsWhenNotInAvailableDataRegionThrowsError() async throws {
        let coordinate = CLLocationCoordinate2D.outsideAvailableDataRegion
        let date = Date()
        apiClient.add(response: .success(Outcome.mocks))

        var resultError: OutcomeError?
        do {
            _ = try await service.streetLevelOutcomes(at: coordinate, date: date)
        } catch let error as OutcomeError {
            resultError = error
        }

        XCTAssertEqual(resultError, .locationOutsideOfDataSetRegion)
        XCTAssertEqual(apiClient.requestedURLs.count, 0)
    }

    func testStreetLevelOutcomesInAreaReturnsOutcomes() async throws {
        let boundary = CLLocationCoordinate2D.mocks
        let expectedResult = Outcome.mocks
        let date = Date()
        apiClient.add(response: .success(Outcome.mocks))

        let result = try await service.streetLevelOutcomes(in: boundary, date: date)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.requestedURLs.count, 1)
        XCTAssertEqual(
            apiClient.requestedURLs.last,
            OutcomesEndpoint.streetLevelOutcomesInArea(coordinates: CLLocationCoordinate2D.mocks, date: date).path
        )
    }

    func testStreetLevelOutcomesPublisherInAreaReturnsOutcomes() {
        let boundary = CLLocationCoordinate2D.mocks
        let expectedResult = Outcome.mocks
        let date = Date()
        apiClient.add(response: .success(Outcome.mocks))

        let expectation = expectation(description: "StreetLevelOutcomesPublisher")
        var result: [Outcome]?
        service.streetLevelOutcomesPublisher(in: boundary)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { outcomes in
                result = outcomes
            }
            .store(in: &cancellables)

        wait(for: [expectation])

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.requestedURLs.count, 1)
        XCTAssertEqual(
            apiClient.requestedURLs.last,
            OutcomesEndpoint.streetLevelOutcomesInArea(coordinates: CLLocationCoordinate2D.mocks, date: date).path
        )
    }

    func testFetchCaseHistoryNotCachedReturnsCaseHistory() async throws {
        let expectedResult = CaseHistory.mock
        let crimeID = expectedResult.crime.crimeID
        apiClient.add(response: .success(CaseHistory.mock))

        let result = try await service.caseHistory(forCrime: crimeID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.requestedURLs.count, 1)
        XCTAssertEqual(apiClient.requestedURLs.last, OutcomesEndpoint.caseHistory(crimeID: crimeID).path)
    }

    func testFetchCaseHistoryWhenNotFoundThrowsNotFoundError() async throws {
        let crimeID = "123ABC"
        apiClient.add(response: .failure(APIClientError.notFound))

        var resultError: OutcomeError?
        do {
            _ = try await service.caseHistory(forCrime: crimeID)
        } catch let error as OutcomeError {
            resultError = error
        }

        XCTAssertEqual(resultError, .notFound)
    }

    func testFetchCaseHistoryWhenCachedReturnsCachedCaseHistory() async throws {
        let expectedResult = CaseHistory.mock
        let crimeID = expectedResult.crime.crimeID
        await cache.setCaseHistory(expectedResult, forCrime: crimeID)

        let result = try await service.caseHistory(forCrime: crimeID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.requestedURLs.count, 0)
    }

    func testFetchCaseHistoryWhenNotCachedAndReturnsCaseHistoryShouldCacheResult() async throws {
        let expectedResult = CaseHistory.mock
        let crimeID = expectedResult.crime.crimeID
        apiClient.add(response: .success(CaseHistory.mock))
        _ = try await service.caseHistory(forCrime: crimeID)

        let cachedResult = await cache.caseHistory(forCrime: crimeID)

        XCTAssertEqual(cachedResult, expectedResult)
    }

}
