import SwiftUI
import SpaceXAPI

@main
struct XLaunchesApp: App {
    @State private var viewModel = RootViewModel(client: .live())

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
        }
    }
}
