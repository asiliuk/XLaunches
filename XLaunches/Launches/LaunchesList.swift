import Foundation
import SpaceXAPI

@Observable
final class LaunchesList {
    var content: Loadable<(NextLaunch?, [PastLaunch])>
    let client: SpaceXApiClient

    var nextPage: SpaceXApiClient.Page? = .init(offset: 0, limit: 10)
    var nextPageFailed: Bool = false

    init(content: Loadable<(NextLaunch?, [PastLaunch])> = .initial, client: SpaceXApiClient) {
        self.content = content
        self.client = client
    }

    func load() async {
        guard content.canLoad else { return }

        content = .loading
        do {
            async let nextLaunch = try await client.nextLaunch()
            async let pastLaunches = try await client.pastLaunches(nextPage)
            content = try await .loaded((nextLaunch, pastLaunches))
            try await nextPage.move(loadedCount: pastLaunches.count)
        } catch is CancellationError {
            content = .initial
        } catch {
            content = .failed(error, retry: { [weak self] in await self?.load() })
        }
    }

    func nextPage() async {
        guard case .loaded((let nextLaunch, let previousLaunches)) = content, let nextPage else { return }
        do {
            try await Task.sleep(for: .milliseconds(200))
            let pastLaunches = try await client.pastLaunches(nextPage)
            self.content = .loaded((nextLaunch, previousLaunches + pastLaunches))
            self.nextPage.move(loadedCount: pastLaunches.count)
            self.nextPageFailed = false
        } catch is CancellationError {
            // noop
        } catch {
            nextPageFailed = true
        }
    }
}
