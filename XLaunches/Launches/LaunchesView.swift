import SwiftUI
import SpaceXAPI

struct LaunchesView: View {
    let viewModel: LaunchesList

    var body: some View {
        NavigationStack {
            LoadableView(loadable: viewModel.content) { upcoming, launches in
                List {
                    if let upcoming {
                        Section("screen.launches.section.upcoming.title") {
                            UpcomingLaunchRow(launch: upcoming)
                        }
                    }

                    if !launches.isEmpty {
                        Section("screen.launches.section.past.title") {
                            ForEach(launches, id: \.name) { launch in
                                PastLaunchRow(launch: launch)
                            }

                            if viewModel.nextPageFailed {
                                LoadMoreFailedRow { await viewModel.nextPage() }
                            } else if viewModel.nextPage != nil {
                                LoadMoreRow { await viewModel.nextPage() }
                            }
                        }
                    }
                }
            }
            .navigationTitle("screen.launches.title")
            .task { await viewModel.load() }
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
