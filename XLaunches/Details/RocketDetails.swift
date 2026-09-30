import Foundation
import SpaceXAPI

struct RocketName: Hashable {
    let value: String
}

@Observable
final class RocketDetails {
    let name: String
    var details: Loadable<Rocket?> = .initial
    let client: SpaceXApiClient

    init(name: RocketName, client: SpaceXApiClient) {
        self.name = name.value
        self.client = client
    }

    func load() async {
        guard details.canLoad else { return }

        details = .loading
        do {
            let rocket = try await client.rocket(name)
            details = .loaded(rocket)
        } catch is CancellationError {
            details = .initial
        } catch {
            details = .failed(error, retry: { [weak self] in await self?.load() })
        }
    }
}
