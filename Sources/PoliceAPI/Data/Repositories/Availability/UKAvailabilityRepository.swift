import Foundation
import os

final class UKAvailabilityRepository: AvailabilityRepository {

    private static let logger = Logger(subsystem: Logger.dataSubsystem, category: "UKAvailabilityRepository")

    private let apiClient: any APIClient
    private let cache: any Cache

    init(apiClient: some APIClient, cache: some Cache) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func availableDataSets() async throws -> [DataSet] {
        Self.logger.trace("fetching available data sets")

        let cacheKey = AvailableDataSetsCachingKey()
        if let cachedDataSets = await cache.object(for: cacheKey, type: [DataSet].self) {
            return cachedDataSets
        }

        let dataModels: [DataSetDataModel]
        do {
            dataModels = try await apiClient.get(endpoint: AvailabilityEndpoint.dataSets)
        } catch let error {
            Self.logger.error("failed fetching available data sets")
            throw error
        }

        let dataSets = dataModels.map(DataSet.init)

        await cache.set(dataSets, for: cacheKey)

        return dataSets
    }

}