import Foundation

final class PoliceDataKitFactory {

    private init() { }

}

extension PoliceDataKitFactory {

    static let apiClient: some APIClient = {
        PoliceDataAPIClient(
            baseURL: policeDataBaseURL,
            urlSession: urlSession,
            serialiser: serialiser
        )
    }()

    static var availabilityCache: some AvailabilityCache {
        AvailabilityDefaultCache(cacheStore: cacheStore)
    }

    static var crimeCache: some CrimeCache {
        CrimeDefaultCache(cacheStore: cacheStore)
    }

    static var neighbourhoodCache: some NeighbourhoodCache {
        NeighbourhoodDefaultCache(cacheStore: cacheStore)
    }

    static var outcomeCache: some OutcomeCache {
        OutcomeDefaultCache(cacheStore: cacheStore)
    }

    static var policeForceCache: some PoliceForceCache {
        PoliceForceDefaultCache(cacheStore: cacheStore)
    }

    static var stopAndSearchCache: some StopAndSearchCache {
        StopAndSearchDefaultCache(cacheStore: cacheStore)
    }

}

extension PoliceDataKitFactory {

    private static let urlSession = URLSession(configuration: urlSessionConfiguration)

    private static var urlSessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        #if !os(macOS)
        configuration.multipathServiceType = .handover
        #endif

        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30

        return configuration
    }

    static let cacheStore: some Cache = {
        InMemoryCache(name: "PoliceDataKitCache")
    }()

    private static var serialiser: some Serialiser {
        JSONSerialiser(decoder: .policeDataAPI)
    }

}

extension PoliceDataKitFactory {

    private static var policeDataBaseURL: URL {
        URL(string: "https://data.police.uk/api")!
    }

}
