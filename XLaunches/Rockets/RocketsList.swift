import Foundation
import SpaceXAPI

@Observable
final class RocketsList {
    var rockets: Loadable<[Rocket]>
    let client: SpaceXApiClient

    init(rockets: Loadable<[Rocket]> = .initial, client: SpaceXApiClient) {
        self.rockets = rockets
        self.client = client
    }

    func load() async {
        guard case .initial = rockets else { return }

        rockets = .loading
        do {
            rockets = try await .loaded(client.rockets())
        } catch is CancellationError {
            rockets = .initial
        } catch {
            rockets = .failed(error, retry: { [weak self] in await self?.load() })
        }
    }
}
