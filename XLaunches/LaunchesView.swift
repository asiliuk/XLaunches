import SwiftUI

struct LaunchesView: View {
    var body: some View {
        NavigationStack {
            Text("Launches View")
                .navigationTitle("screen.launches.title")
        }
    }
}

#Preview {
    LaunchesView()
}
