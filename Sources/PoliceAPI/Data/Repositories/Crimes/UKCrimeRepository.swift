import CoreLocation
import Foundation
import os

final class UKCrimeRepository: CrimeRepository {

    private static let logger = Logger(subsystem: Logger.dataSubsystem, category: "UKCrimeRepository")

    private let apiClient: any APIClient
    private let cache: any Cache
    private let availableDataRegion: CoordinateRegionDataModel

    convenience init(apiClient: some APIClient, cache: some Cache) {
        self.init(apiClient: apiClient, cache: cache, availableDataRegion: .availableDataRegion)
    }

    init(apiClient: some APIClient, cache: some Cache, availableDataRegion: CoordinateRegionDataModel) {
        self.apiClient = apiClient
        self.cache = cache
        self.availableDataRegion = availableDataRegion
    }

    func streetLevelCrimes(at coordinate: CLLocationCoordinate2D, date: Date) async throws -> [Crime]? {
        Self.logger.trace("fetching street level Crimes at coordinate \(coordinate, privacy: .public)")

        let coordinate = CoordinateDataModel(coordinate: coordinate)

        guard availableDataRegion.contains(coordinate: coordinate) else {
            return nil
        }

        let dataModels: [CrimeDataModel]
        do {
            dataModels = try await apiClient.get(
                endpoint: CrimesEndpoint.streetLevelCrimesAtSpecificPoint(coordinate: coordinate, date: date)
            )
        } catch let error {
            // swiftlint:disable:next line_length
            Self.logger.error("failed fetching street level Crimes at coordinate \(coordinate, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw error
        }

        let crimes = dataModels.map(Crime.init)

        return crimes
    }

    func streetLevelCrimes(in coordinates: [CLLocationCoordinate2D], date: Date) async throws -> [Crime]? {
        Self.logger.trace("fetching street level Crimes in area")

        let boundary = BoundaryDataModel(coordinates: coordinates)

        let dataModels: [CrimeDataModel]
        do {
            dataModels = try await apiClient.get(
                endpoint: CrimesEndpoint.streetLevelCrimesInArea(boundary: boundary, date: date)
            )
        } catch let error {
            // swiftlint:disable:next line_length
            Self.logger.error("failed fetching street level Crimes in area: \(error.localizedDescription, privacy: .public)")
            throw error
        }

        let crimes = dataModels.map(Crime.init)

        return crimes
    }

    func crimes(forStreet streetID: Int, date: Date) async throws -> [Crime] {
        Self.logger.trace("fetching Crimes for street \(streetID, privacy: .public)")

        let cacheKey = CrimesForStreetCachingKey(streetID: streetID, date: date)
        if let cachedCrimes = await cache.object(for: cacheKey, type: [Crime].self) {
            return cachedCrimes
        }

        let dataModels: [CrimeDataModel]
        do {
            dataModels = try await apiClient.get(
                endpoint: CrimesEndpoint.crimesAtLocationForStreet(streetID: streetID, date: date)
            )
        } catch let error {
            // swiftlint:disable:next line_length
            Self.logger.error("failed fetching Crimes for street \(streetID, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw error
        }

        let crimes = dataModels.map(Crime.init)

        await cache.set(crimes, for: cacheKey)

        return crimes
    }

    func crimes(at coordinate: CLLocationCoordinate2D, date: Date) async throws -> [Crime]? {
        Self.logger.trace("fetching Crimes at coordinate \(coordinate, privacy: .public)")

        let coordinate = CoordinateDataModel(coordinate: coordinate)

        guard availableDataRegion.contains(coordinate: coordinate) else {
            return nil
        }

        let dataModels: [CrimeDataModel]
        do {
            dataModels = try await apiClient.get(
                endpoint: CrimesEndpoint.crimesAtLocationAtSpecificPoint(coordinate: coordinate, date: date)
            )
        } catch let error {
            // swiftlint:disable:next line_length
            Self.logger.error("failed fetching Crimes at coordinate \(coordinate, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw error
        }

        let crimes = dataModels.map(Crime.init)

        return crimes
    }

    func crimesWithNoLocation(forCategory categoryID: CrimeCategory.ID, inPoliceForce policeForceID: PoliceForce.ID,
                              date: Date) async throws -> [Crime] {
        // swiftlint:disable:next line_length
        Self.logger.trace("fetching Crimes with no location for category \(categoryID, privacy: .public) in Police Force \(policeForceID, privacy: .public)")

        let cacheKey = CrimesWithNoLocationForCategoryInPoliceForceCachingKey(categoryID: categoryID,
                                                                              policeForceID: policeForceID, date: date)
        if let cachedCrimes = await cache.object(for: cacheKey, type: [Crime].self) {
            return cachedCrimes
        }

        let dataModels: [CrimeDataModel]
        do {
            dataModels = try await apiClient.get(
                endpoint: CrimesEndpoint.crimesWithNoLocation(
                    categoryID: categoryID, policeForceID: policeForceID, date: date
                )
            )
        } catch let error {
            // swiftlint:disable:next line_length
            Self.logger.error("failed fetching Crimes with no location for category \(categoryID, privacy: .public) in Police Force \(policeForceID, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw error
        }

        let crimes = dataModels.map(Crime.init)

        await cache.set(crimes, for: cacheKey)

        return crimes
    }

    func crimeCategories(forDate date: Date) async throws -> [CrimeCategory] {
        Self.logger.trace("fetching Crime categories for date \(date, privacy: .public)")

        let cacheKey = CrimeCategoriesCachingKey(date: date)
        if let cachedCategories = await cache.object(for: cacheKey, type: [CrimeCategory].self) {
            return cachedCategories
        }

        let dataModels: [CrimeCategoryDataModel]
        do {
            dataModels = try await apiClient.get(endpoint: CrimesEndpoint.categories(date: date))
        } catch let error {
            // swiftlint:disable:next line_length
            Self.logger.error("failed fetching Crime categories for date \(date, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw error
        }

        let categories = dataModels.map(CrimeCategory.init)

        await cache.set(categories, for: cacheKey)

        return categories
    }

}