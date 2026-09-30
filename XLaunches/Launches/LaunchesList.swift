import Foundation
import SpaceXAPI

@Observable
final class LaunchesList {
    var upcoming: NextLaunch?
    var launches: [PastLaunch]
    var isLoading: Bool
    let client: SpaceXApiClient

    init(upcoming: NextLaunch? = nil, launches: [PastLaunch] = [], isLoading: Bool = false, client: SpaceXApiClient = .live()) {
        self.upcoming = upcoming
        self.launches = launches
        self.isLoading = isLoading
        self.client = client
    }

    func load() async {
        isLoading = true
        do {
            async let nextLaunch = try await client.nextLaunch()
            async let pastLaunches = try await client.pastLaunches()
            (upcoming, launches) = try await (nextLaunch, pastLaunches)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        isLoading = false
    }
}
