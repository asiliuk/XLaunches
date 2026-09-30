import SwiftUI

struct RocketsView: View {
    var body: some View {
        NavigationStack {
            Text("Rockets View")
                .navigationTitle("screen.rockets.title")
        }
    }
}

#Preview {
    RocketsView()
}
