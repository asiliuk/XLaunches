import Foundation
import SpaceXAPI

@Observable
final class RocketsList {
    private(set) var rockets: Loadable<[Rocket]>
    private let client: SpaceXApiClient

    private(set) var nextPage: SpaceXApiClient.Page? = .init(offset: 0, limit: 10)
    private(set) var nextPageFailed: Bool = false

    init(rockets: Loadable<[Rocket]> = .initial, client: SpaceXApiClient) {
        self.rockets = rockets
        self.client = client
    }

    func load() async {
        guard rockets.canLoad else { return }

        rockets = .loading
        do {
            let loadedRockets = try await client.rockets(nextPage)
            self.rockets = .loaded(loadedRockets)
            nextPage.move(loadedCount: loadedRockets.count)
        } catch is CancellationError {
            rockets = .initial
        } catch {
            rockets = .failed(error, retry: { [weak self] in await self?.load() })
        }
    }

    func nextPage() async {
        guard case .loaded(let rockets) = rockets, let nextPage else { return }
        do {
            try await Task.sleep(for: .milliseconds(200))
            let loadedRockets = try await client.rockets(nextPage)
            self.rockets = .loaded(rockets + loadedRockets)
            self.nextPage.move(loadedCount: loadedRockets.count)
            self.nextPageFailed = false
        } catch is CancellationError {
            // noop
        } catch {
            nextPageFailed = true
        }
    }

    func rocketDetails(name: RocketName) -> RocketDetails {
        RocketDetails(name: name, client: client)
    }
}
