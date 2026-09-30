// Original API `https://api.spacexdata.com` is archived and returns 525 error
// This is replacement API, more info https://pipeworx.io/blog/spacex-api-revived/

import Foundation

// MARK: - Client

public struct SpaceXApiClient {
    public struct Page {
        public let offset: Int
        public let limit: Int

        public init(offset: Int, limit: Int) {
            self.offset = offset
            self.limit = limit
        }
    }

    public let pastLaunches: (_ page: Page?) async throws -> [PastLaunch]
    public let nextLaunch: () async throws -> NextLaunch?
    public let rockets: (_ page: Page?) async throws -> [Rocket]
}

// MARK: - Models

public struct PastLaunch: Decodable {
    public var name: String
    public var status: String
    public var success: Bool
    public var dateUtc: Date
}

public struct NextLaunch: Decodable {
    public struct Links: Decodable {
        public var article: URL?
        public var webcast: URL?
        public var wikipedia: URL?
    }

    public var pad: String
    public var name: String
    public var links: Links
    public var rocket: String
    public var status: String
    public var details: String
    public var success: Bool?
    public var dateUtc: Date
}

public struct Rocket: Decodable {
    public var name: String
    public var family: String
    public var reusable: Bool
    public var description: String
    public var maidenFlight: Date?

    public var launchCostUsd: Int?
    public var launchCount: Int
    public var successfulLaunches: Int
    public var failedLaunches: Int
    public var successRatePct: Double?
}

// MARK: - Live

extension SpaceXApiClient {
    public enum ResponseValidationError: Error {
        case invalidResponseType
        case badStatusCode(Int)
    }

    public static func live(urlSession: URLSession = .shared) -> SpaceXApiClient {
        SpaceXApiClient(
            pastLaunches: { page in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let request = URLRequest(url: apiURL(path: "/spacex/v4/launches/past"))
                let (data, response) = try await urlSession.data(for: request)
                try validate(response: response)
                let launches = try decoder.decode([PastLaunch].self, from: data)
                return paginate(list: launches, page: page)
            },
            nextLaunch: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let request = URLRequest(url: apiURL(path: "/spacex/v4/launches/next"))
                let (data, response) = try await urlSession.data(for: request)
                try validate(response: response)
                return try decoder.decode(NextLaunch?.self, from: data)
            },
            rockets: { page in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dayDateFormatter)
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let request = URLRequest(url: apiURL(path: "/spacex/v4/rockets"))
                let (data, response) = try await urlSession.data(for: request)
                try validate(response: response)
                let rockets = try decoder.decode([Rocket].self, from: data)
                return paginate(list: rockets, page: page)
            }
        )
    }

    private static func apiURL(path: String) -> URL {
        var components = baseComponents
        components.path = path
        guard let url = components.url else { fatalError("Failed to create URL for path: \(path)") }
        return url
    }

    private static func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResponseValidationError.invalidResponseType
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw ResponseValidationError.badStatusCode(httpResponse.statusCode)
        }

        // All good, nothing to see here
    }

    private static let dayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let baseComponents: URLComponents = URLComponents(string: "https://gateway.pipeworx.io")!
}

// MARK: - Mock

#if DEBUG
extension SpaceXApiClient {
    private struct MockAPIFailure: Error, CustomStringConvertible {
        let description: String
    }

    public static func failure(delay: Duration? = nil, message: String? = nil) -> SpaceXApiClient {
        return SpaceXApiClient(
            pastLaunches: { _ in
                if let delay { try await Task.sleep(for: delay) }
                throw MockAPIFailure(description: message ?? "#pastLaunches failed")
            },
            nextLaunch: {
                if let delay { try await Task.sleep(for: delay) }
                throw MockAPIFailure(description: message ?? "#nextLaunch failed")
            },
            rockets: { _ in
                if let delay { try await Task.sleep(for: delay) }
                throw MockAPIFailure(description: message ?? "#rockets failed")
            }
        )
    }
}
#endif

// MARK: - Pagination

private extension SpaceXApiClient {
    /// API replacement does not support proper pagination, this is workaround to emulate it
    static func paginate<Model>(list: [Model], page: Page?) -> [Model] {
        guard let page else { return list }
        return Array(list.dropFirst(page.offset).prefix(page.limit))
    }
}
