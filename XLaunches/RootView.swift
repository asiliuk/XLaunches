import SwiftUI

import SpaceXAPI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("screen.launches.title", systemImage: "list.bullet.clipboard") {
                LaunchesView(viewModel: LaunchesList())
            }

            Tab("screen.rockets.title", systemImage: "airplane.up.forward") {
                RocketsView()
            }
        }
    }
}

#Preview {
    RootView()
}
