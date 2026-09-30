import Foundation
import SpaceXAPI

@Observable
final class LaunchesList {
    struct Filters: Equatable {
        var start: Date = .now
        var end: Date = .now
        fileprivate var range: ClosedRange<Date> { start...end }
    }

    typealias LaunchesLoadable = Loadable<(NextLaunch?, [PastLaunch])>

    private var content: LaunchesLoadable

    let client: SpaceXApiClient

    var nextPage: SpaceXApiClient.Page?
    var nextPageFailed: Bool = false

    var filters: Filters?
    var isFiltersPresented: Bool = false
    var draftFilters = Filters()

    var filteredContent: LaunchesLoadable {
        guard let filters else { return content }
        return content.map { upcoming, pastLaunches in
            let filteredUpcoming = upcoming.flatMap { filters.range.contains($0.dateUtc) ? $0 : nil }
            let filteredPastLaunches = pastLaunches.filter { filters.range.contains($0.dateUtc) }
            return (filteredUpcoming, filteredPastLaunches)
        }
    }

    init(content: LaunchesLoadable = .initial, client: SpaceXApiClient, pageSize: Int = 10) {
        self.content = content
        self.client = client
        self.nextPage = .init(offset: 0, limit: pageSize)
    }

    func load() async {
        guard content.canLoad else { return }

        content = .loading
        do {
            async let nextLaunch = try? await client.nextLaunch()
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

    func filterButtonTapped() {
        draftFilters = filters ?? Filters()
        isFiltersPresented = true
    }

    func applyFiltersTapped() {
        filters = draftFilters
        isFiltersPresented = false
    }

    func clearFilterButtonTapped() {
        filters = nil
        isFiltersPresented = false
    }

    func rocketDetails(name: RocketName) -> RocketDetails {
        RocketDetails(name: name, client: client)
    }
}
