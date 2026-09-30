import Testing
import SpaceXAPI
@testable import XLaunches
internal import Foundation

@MainActor
struct LaunchesListTests {
    struct TestError: Error {}

    @Test func `load requests next launch and passed launches page`() async throws {
        // Given
        var client = SpaceXApiClient.failure()

        var nextLaunchCalled = false
        var pastLaunchesCalls: [SpaceXApiClient.Page?] = []
        client.nextLaunch = { nextLaunchCalled = true; return nil }
        client.pastLaunches = { pastLaunchesCalls.append($0); return [] }

        let sut = LaunchesList(client: client)

        // When
        await sut.load()

        // Then
        #expect(nextLaunchCalled == true)
        #expect(pastLaunchesCalls == [.init(offset: 0, limit: 10)])
    }

    @Test func `load requests does not fail on next launch failure`() async throws {
        // Given
        var client = SpaceXApiClient.failure()

        client.nextLaunch = { throw TestError() }
        client.pastLaunches = { _ in [] }

        let sut = LaunchesList(client: client)

        // When
        await sut.load()

        // Then
        if case .loaded((nil, [])) = sut.filteredContent {
        } else {
            Issue.record("Unexpected state \(sut.filteredContent)")
        }
    }

    @Test func `next page requests next page from API and stops on reaching end`() async {
        // Given
        var client = SpaceXApiClient.failure()

        var pastLaunchesCalls: [SpaceXApiClient.Page?] = []
        var pastLaunchesToReturn: [PastLaunch] = [
            PastLaunch(name: "Name 1", status: "Status", success: true, dateUtc: .now),
            PastLaunch(name: "Name 2", status: "Status", success: true, dateUtc: .now),
            PastLaunch(name: "Name 3", status: "Status", success: true, dateUtc: .now),
            PastLaunch(name: "Name 4", status: "Status", success: true, dateUtc: .now),
        ]

        client.nextLaunch = { nil }
        client.pastLaunches = { pastLaunchesCalls.append($0); return pastLaunchesToReturn }

        let sut = LaunchesList(client: client, pageSize: 4)

        // When
        await sut.load()

        // Then
        #expect(pastLaunchesCalls == [.init(offset: 0, limit: 4)])
        #expect(sut.canLoadMorePages == true)


        // When
        pastLaunchesToReturn = [
            PastLaunch(name: "Name 5", status: "Status", success: true, dateUtc: .now),
            PastLaunch(name: "Name 6", status: "Status", success: true, dateUtc: .now),
        ]
        await sut.nextPage()

        // Then
        #expect(pastLaunchesCalls == [.init(offset: 0, limit: 4), .init(offset: 4, limit: 4)])
        #expect(sut.canLoadMorePages == false)

        // When
        await sut.nextPage()

        // Then
        // Request ignored
        #expect(pastLaunchesCalls.count == 2)
    }

    @Test func `next page requests when filters are applied`() async {
        // Given
        var client = SpaceXApiClient.failure()

        var pastLaunchesCalls: [SpaceXApiClient.Page?] = []
        var pastLaunchesToReturn: [PastLaunch] = [
            PastLaunch(name: "Name 1", status: "Status", success: true, dateUtc: .now),
            PastLaunch(name: "Name 2", status: "Status", success: true, dateUtc: .now.addingTimeInterval(-100)),
        ]

        client.nextLaunch = { nil }
        client.pastLaunches = { pastLaunchesCalls.append($0); return pastLaunchesToReturn }

        let sut = LaunchesList(client: client, pageSize: 2)
        sut.filters = .init(start: .now.addingTimeInterval(-200), end: .now)

        // When
        await sut.load()

        // Then
        if case .loaded((_, let passed)) = sut.filteredContent {
            // Shows data on UI
            #expect(passed.map(\.name) == ["Name 1", "Name 2"])
        } else {
            Issue.record("Unexpected state \(sut.filteredContent)")
        }
        // Can load more pages because last fetch launch does not exceed filter
        #expect(sut.canLoadMorePages == true)

        // When
        pastLaunchesToReturn = [
            PastLaunch(name: "Name 3", status: "Status", success: true, dateUtc: .now.addingTimeInterval(-200)),
            PastLaunch(name: "Name 4", status: "Status", success: true, dateUtc: .now.addingTimeInterval(-300)),
        ]
        await sut.nextPage()

        // Then
        if case .loaded((_, let passed)) = sut.filteredContent {
            // Filters `Name 4` from UI
            #expect(passed.map(\.name) == ["Name 1", "Name 2", "Name 3"])
        } else {
            Issue.record("Unexpected state \(sut.filteredContent)")
        }
        // Does not want to load more pages
        #expect(sut.canLoadMorePages == false)
    }


    @Test func `filter button tapped presents sheet with existing filters`() {
        // Given
        let sut = LaunchesList(client: .failure())
        sut.filters = .init(start: .distantPast, end: .distantFuture)

        // When
        sut.filterButtonTapped()

        // Then
        #expect(sut.isFiltersPresented == true)
        #expect(sut.draftFilters == sut.filters)
    }

    @Test func `clear filter button tapped dismiss sheet and resets filters`() {
        // Given
        let sut = LaunchesList(client: .failure())
        sut.filters = .init(start: .distantPast, end: .distantFuture)
        sut.isFiltersPresented = true

        // When
        sut.clearFilterButtonTapped()

        // Then
        #expect(sut.isFiltersPresented == false)
        #expect(sut.filters == nil)
    }

    @Test func `apply filter button tapped dismiss sheet and updates filters`() {
        // Given
        let sut = LaunchesList(client: .failure())
        sut.draftFilters = .init(start: .distantPast, end: .distantFuture)
        sut.isFiltersPresented = true

        // When
        sut.applyFiltersTapped()

        // Then
        #expect(sut.isFiltersPresented == false)
        #expect(sut.filters == sut.draftFilters)
    }

    @Test func `filters filter content`() {
        // Given
        let sut = LaunchesList(
            content: .loaded((
                NextLaunch(pad: "Pad", name: "Future", links: .init(), rocket: "Rocket", status: "Status", details: "Details", dateUtc: .now.addingTimeInterval(100)),
                [
                    PastLaunch(name: "Past 1", status: "Status", success: false, dateUtc: .now.addingTimeInterval(-1000)),
                    PastLaunch(name: "Past 2", status: "Status", success: false, dateUtc: .now.addingTimeInterval(-2000)),
                    PastLaunch(name: "Super Past 2", status: "Status", success: false, dateUtc: .distantPast),
                ]
            )),
            client: .failure()
        )

        // When
        sut.filters = .init(start: .now.addingTimeInterval(-1500), end: .now.addingTimeInterval(1000))

        // Then
        if case .loaded((let upcoming, let passed)) = sut.filteredContent {
            #expect(upcoming?.name == "Future")
            #expect(passed.map(\.name) == ["Past 1"])
        } else {
            Issue.record("Unexpected state \(sut.filteredContent)")
        }

        // When
        sut.filters = .init(start: .now, end: .now)

        // Then
        if case .loaded((let upcoming, let passed)) = sut.filteredContent {
            #expect(upcoming == nil)
            #expect(passed.map(\.name) == [])
        } else {
            Issue.record("Unexpected state \(sut.filteredContent)")
        }
    }

    @Test func `inverted filters range works as normal`() {
        // Given
        let sut = LaunchesList(
            content: .loaded((
                NextLaunch(pad: "Pad", name: "Future", links: .init(), rocket: "Rocket", status: "Status", details: "Details", dateUtc: .now.addingTimeInterval(100)),
                [
                    PastLaunch(name: "Past 1", status: "Status", success: false, dateUtc: .now.addingTimeInterval(-1000)),
                    PastLaunch(name: "Past 2", status: "Status", success: false, dateUtc: .now.addingTimeInterval(-2000)),
                    PastLaunch(name: "Super Past 2", status: "Status", success: false, dateUtc: .distantPast),
                ]
            )),
            client: .failure()
        )

        // When
        sut.filters = .init(start: .now.addingTimeInterval(1000), end: .now.addingTimeInterval(-1500))

        // Then
        if case .loaded((let upcoming, let passed)) = sut.filteredContent {
            #expect(upcoming?.name == "Future")
            #expect(passed.map(\.name) == ["Past 1"])
        } else {
            Issue.record("Unexpected state \(sut.filteredContent)")
        }
    }
}
