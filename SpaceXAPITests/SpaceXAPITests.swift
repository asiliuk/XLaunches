import Testing
@testable import SpaceXAPI
internal import Foundation

struct SpaceXAPITests {

    @Test
    func `past launch parses rocket name and payload out of name`() {
        // Given
        let launch = PastLaunch(name: "Rocket | Payload", status: "", success: false, dateUtc: .now)

        // Then
        #expect(launch.rocket == "Rocket")
        #expect(launch.payload == "Payload")
    }

    @Test
    func `past launches requests correct api and pages response`() async throws {
        // Given
        var request: URLRequest?
        let launches = [
            PastLaunch(name: "Name 1", status: "Success", success: true, dateUtc: .now),
            PastLaunch(name: "Name 2", status: "Failure", success: false, dateUtc: .now)
        ]
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(launches)
        let client = SpaceXApiClient.live(data: { request = $0; return (data, HTTPURLResponse())})

        // When
        let response = try await client.pastLaunches(.init(offset: 1, limit: 1))

        // Then
        #expect(request?.url == URL(string: "https://gateway.pipeworx.io/spacex/v4/launches/past"))
        #expect(response.count == 1)
        #expect(response.last?.name == launches.last?.name)
    }

    @Test
    func `next launches requests correct api`() async throws {
        // Given
        var request: URLRequest?
        let data = Data("null".utf8)
        let client = SpaceXApiClient.live(data: { request = $0; return (data, HTTPURLResponse())})

        // When
        _ = try await client.nextLaunch()

        // Then
        #expect(request?.url == URL(string: "https://gateway.pipeworx.io/spacex/v4/launches/next"))
    }

    @Test
    func `rockets requests correct api and pages response`() async throws {
        // Given
        var request: URLRequest?
        let rockets = [
            Rocket(
                name: "Rocket 1",
                family: "Family 1",
                reusable: true,
                description: "Description 2",
                launchCount: 0,
                successfulLaunches: 0,
                failedLaunches: 0
            ),
            Rocket(
                name: "Rocket 2",
                family: "Family 2",
                reusable: false,
                description: "Description 2",
                launchCount: 1,
                successfulLaunches: 1,
                failedLaunches: 1
            )
        ]
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(rockets)
        let client = SpaceXApiClient.live(data: { request = $0; return (data, HTTPURLResponse())})

        // When
        let response = try await client.rockets(.init(offset: 1, limit: 1))

        // Then
        #expect(request?.url == URL(string: "https://gateway.pipeworx.io/spacex/v4/rockets"))
        #expect(response.count == 1)
        #expect(response.last == rockets.last)
    }

    @Test
    func `rocket requests correct api and finds rocket by name`() async throws {
        // Given
        var request: URLRequest?
        let rockets = [
            Rocket(
                name: "Rocket 1",
                family: "Family 1",
                reusable: true,
                description: "Description 2",
                launchCount: 0,
                successfulLaunches: 0,
                failedLaunches: 0
            ),
            Rocket(
                name: "Rocket 2",
                family: "Family 2",
                reusable: false,
                description: "Description 2",
                launchCount: 1,
                successfulLaunches: 1,
                failedLaunches: 1
            )
        ]
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(rockets)
        let client = SpaceXApiClient.live(data: { request = $0; return (data, HTTPURLResponse())})

        // When
        let response = try await client.rocket("Rocket 2")

        // Then
        #expect(request?.url == URL(string: "https://gateway.pipeworx.io/spacex/v4/rockets"))
        #expect(response == rockets.last)
    }

    @Test
    func `rocket requests returns nil when cant find`() async throws {
        // Given
        let data = Data("[]".utf8)
        let client = SpaceXApiClient.live(data: { _ in (data, HTTPURLResponse())})

        // When
        let response = try await client.rocket("Rocket 2")

        // Then
        #expect(response == nil)
    }
}
