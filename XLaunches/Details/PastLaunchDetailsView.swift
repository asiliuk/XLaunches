import SwiftUI
import SpaceXAPI

struct PastLaunchDetailsView: View {
    let launch: PastLaunch

    var body: some View {
        Form {
            NavigationLink(value: RocketName(value: launch.rocket)) {
                LabeledContent {
                    Text(launch.rocket)
                } label: {
                    Text("screen.launch-details.rocket.title")
                }
            }

            LabeledContent {
                Text(launch.payload)
            } label: {
                Text("screen.launch-details.payload.title")
            }

            LabeledContent {
                Text(launch.dateUtc, format: .dateTime)
            } label: {
                Text("screen.launch-details.date.title")
            }

            LabeledContent {
                Text(launch.status)
            } label: {
                Text("screen.launch-details.status.title")
            }
        }
        .navigationTitle("screen.launch-details.title")
    }
}

#Preview {
    PastLaunchDetailsView(
        launch: .init(
            name: "Rocket | Payload",
            status: "Status",
            success: true,
            dateUtc: .now
        )
    )
}
