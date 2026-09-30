import SwiftUI
import SpaceXAPI

struct UpcomingLaunchDetailsView: View {
    let launch: NextLaunch

    var body: some View {
        Form {
            LabeledContent {
                Text(launch.name)
            } label: {
                Text("screen.launch-details.name.title")
            }

            LabeledContent {
                Text(launch.pad)
            } label: {
                Text("screen.launch-details.pad.title")
            }

            LabeledContent {
                Text(launch.dateUtc, format: .dateTime)
            } label: {
                Text("screen.launch-details.date.title")
            }

            NavigationLink(value: RocketName(value: launch.rocket)) {
                LabeledContent {
                    Text(launch.rocket)
                } label: {
                    Text("screen.launch-details.rocket.title")
                }
            }

            LabeledContent {
                Text(launch.status)
            } label: {
                Text("screen.launch-details.status.title")
            }

            LabeledContent {
                Text(launch.details)
            } label: {
                Text("screen.launch-details.details.title")
            }

            if !launch.links.isEmpty {
                Section("screen.launch-details.links.title") {
                    if let article = launch.links.article {
                        Link("screen.launch-details.article.title", destination: article)
                    }
                    if let webcast = launch.links.webcast {
                        Link("screen.launch-details.webcast.title", destination: webcast)
                    }
                    if let wiki = launch.links.wikipedia {
                        Link("screen.launch-details.wiki.title", destination: wiki)
                    }
                }
            }
        }
        .navigationTitle("screen.launch-details.title")
    }
}

#Preview {
    UpcomingLaunchDetailsView(
        launch: .init(
            pad: "Pad name",
            name: "Launch name",
            links: NextLaunch.Links(
                article: URL(string: "https://article.org"),
                webcast: URL(string: "https://webcast.org"),
                wikipedia: URL(string: "https://wiki.org"),
            ),
            rocket: "Rocket name",
            status: "Success",
            details: """
                This is long an very existing details 
                that could spread to multiple lines
                and even three lines
                maybe even for
                what about five?
                """,
            dateUtc: .now
        )
    )
}
