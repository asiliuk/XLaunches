import SwiftUI
import SpaceXAPI

struct RootView: View {
    let viewModel: RootViewModel

    var body: some View {
        TabView {
            Tab("screen.launches.title", systemImage: "list.bullet.clipboard") {
                LaunchesView(viewModel: viewModel.launches)
            }

            Tab("screen.rockets.title", systemImage: "airplane.up.forward") {
                RocketsView(viewModel: viewModel.rockets)
            }
        }
    }
}

#Preview {
    RootView(viewModel: RootViewModel(client: .live()))
}
