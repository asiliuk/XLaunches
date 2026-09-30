import SwiftUI
import SpaceXAPI

struct RocketsView: View {
    let viewModel: RocketsList

    var body: some View {
        NavigationStack {
            LoadableView(loadable: viewModel.rockets) { rockets in
                List(rockets, id: \.name) { rocket in
                    RocketRow(rocket: rocket)

                    if viewModel.nextPageFailed {
                        LoadMoreFailedRow { await viewModel.nextPage() }
                    } else if viewModel.nextPage != nil {
                        LoadMoreRow { await viewModel.nextPage() }
                    }
                }
            }
            .navigationTitle("screen.rockets.title")
            .task { await viewModel.load() }
        }
    }
}

private struct RocketRow: View {
    let rocket: Rocket

    var body: some View {
        VStack(alignment: .leading) {
            Text(rocket.name)
                .font(.headline)
            HStack {
                Text(rocket.family)
                if rocket.reusable {
                    Text("\(Image(systemName: "arrow.3.trianglepath")) view.rocket-row.reusable")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

        }
    }
}

#Preview {
    RocketsView(viewModel: RocketsList(client: .live()))
}
