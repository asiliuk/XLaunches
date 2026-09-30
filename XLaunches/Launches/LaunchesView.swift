import SwiftUI
import SpaceXAPI

struct LaunchesView: View {
    @State var viewModel: LaunchesList

    var body: some View {
        NavigationStack {
            LoadableView(loadable: viewModel.filteredContent) { upcoming, launches in
                List {
                    if let upcoming {
                        Section("screen.launches.section.upcoming.title") {
                            NavigationLink(value: upcoming) {
                                UpcomingLaunchRow(launch: upcoming)
                            }
                        }
                    }

                    if !launches.isEmpty {
                        Section("screen.launches.section.past.title") {
                            ForEach(launches, id: \.name) { launch in
                                NavigationLink(value: launch) {
                                    PastLaunchRow(launch: launch)
                                }
                            }

                            if viewModel.nextPageFailed {
                                LoadMoreFailedRow { await viewModel.nextPage() }
                            } else if viewModel.canLoadMorePages {
                                LoadMoreRow { await viewModel.nextPage() }
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        let button = Button("screen.launches.button.filter.title", systemImage: "line.3.horizontal.decrease") {
                            viewModel.filterButtonTapped()
                        }

                        if viewModel.filters != nil {
                            button.buttonStyle(.borderedProminent)
                        } else {
                            button
                        }
                    }
                }
            }
            .navigationDestination(for: NextLaunch.self) { launch in
                UpcomingLaunchDetailsView(launch: launch)
            }
            .navigationDestination(for: PastLaunch.self) { launch in
                PastLaunchDetailsView(launch: launch)
            }
            .navigationDestination(for: RocketName.self) { rocketName in
                RocketDetailsView(viewModel: viewModel.rocketDetails(name: rocketName))
            }
            .navigationTitle("screen.launches.title")
            .task { await viewModel.load() }
            .popover(isPresented: $viewModel.isFiltersPresented) {
                LaunchesFiltersView(
                    filters: $viewModel.draftFilters,
                    hasActiveFilters: viewModel.filters != nil,
                    apply: viewModel.applyFiltersTapped,
                    clear: viewModel.clearFilterButtonTapped
                )
            }
        }
    }
}

private struct UpcomingLaunchRow: View {
    let launch: NextLaunch

    var body: some View {
        VStack(alignment: .leading) {
            Text(launch.name)
                .font(.headline)
            Text(launch.pad)
                .font(.subheadline)
            HStack {
                if let isSuccess = launch.success {
                    LaunchStatus(isSuccess: isSuccess)
                } else {
                    Text(launch.status)
                }
                Text(launch.dateUtc, format: .dateTime)
            }
            .foregroundStyle(.secondary)
        }
    }
}

private struct PastLaunchRow: View {
    let launch: PastLaunch

    var body: some View {
        VStack(alignment: .leading) {
            Text(launch.name)
                .font(.headline)
            HStack {
                LaunchStatus(isSuccess: launch.success)
                Text(launch.dateUtc, format: .dateTime)
            }
            .foregroundStyle(.secondary)
        }
    }
}

private struct LaunchStatus: View {
    let isSuccess: Bool

    var body: some View {
        Text(isSuccess ? "view.launch-status.success" : "view.launch-status.failure")
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .foregroundStyle(.background)
            .font(.callout)
            .background {
                Capsule()
                    .foregroundStyle(isSuccess ? .green : .red)
            }
    }
}

#Preview {
    LaunchesView(
        viewModel: LaunchesList(client: .live())
    )
}
