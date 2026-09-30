import Foundation
import SpaceXAPI

@Observable
final class LaunchesList {
    var content: Loadable<(NextLaunch?, [PastLaunch])>
    let client: SpaceXApiClient

    init(content: Loadable<(NextLaunch?, [PastLaunch])> = .initial, client: SpaceXApiClient) {
        self.content = content
        self.client = client
    }

    func load() async {
        guard case .initial = content else { return }

        content = .loading
        do {
            async let nextLaunch = try await client.nextLaunch()
            async let pastLaunches = try await client.pastLaunches()
            content = try await .loaded((nextLaunch, pastLaunches))
        } catch is CancellationError {
            content = .initial
        } catch {
            content = .failed(error, retry: { [weak self] in await self?.load() })
        }
    }
}
