import SwiftUI
import SpaceXAPI

struct RocketDetailsView: View {
    let viewModel: RocketDetails

    var body: some View {
        LoadableView(loadable: viewModel.details) { rocket in
            if let rocket {
                Form {
                    LabeledContent {
                        Text(rocket.name)
                    } label: {
                        Text("screen.rocket-details.name.title")
                    }

                    LabeledContent {
                        Text(rocket.family)
                    } label: {
                        Text("screen.rocket-details.family.title")
                    }

                    LabeledContent {
                        Text(rocket.reusable ? "screen.rocket-details.reusable.yes" : "screen.rocket-details.reusable.no")
                    } label: {
                        Text("screen.rocket-details.reusable.title")
                    }

                    LabeledContent {
                        Text(rocket.description)
                    } label: {
                        Text("screen.rocket-details.description.title")
                    }

                    if let maidenFlight = rocket.maidenFlight {
                        LabeledContent {
                            Text(maidenFlight, format: .dateTime)
                        } label: {
                            Text("screen.rocket-details.maiden-flight.title")
                        }
                    }

                    Section("screen.rocket-details.section.statistics.title") {
                        LabeledContent {
                            Text(rocket.launchCount.description)
                        } label: {
                            Text("screen.rocket-details.launch-count.title")
                        }

                        LabeledContent {
                            Text(rocket.successfulLaunches.description)
                        } label: {
                            Text("screen.rocket-details.successful-launches.title")
                        }

                        LabeledContent {
                            Text(rocket.failedLaunches.description)
                        } label: {
                            Text("screen.rocket-details.failed-launches.title")
                        }

                        if let successRatePct = rocket.successRatePct {
                            LabeledContent {
                                Text((successRatePct / 100).formatted(.percent))
                            } label: {
                                Text("screen.rocket-details.success-rate.title")
                            }
                        }

                        if let launchCostUsd = rocket.launchCostUsd {
                            LabeledContent {
                                Text(launchCostUsd.formatted(.currency(code: "USD")))
                            } label: {
                                Text("screen.rocket-details.launch-cost.title")
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Label {
                        Text("screen.rocket-details.failed-to-find.title")
                    } icon: {
                        Image(systemName: "airplane.path.dotted", variableValue: 0)
                            .symbolEffect(.breathe)
                    }
                } description: {
                    Text("screen.rocket-details.failed-to-find.details.\(viewModel.name)")
                }

            }
        }
        .navigationTitle(viewModel.name)
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack {
        RocketDetailsView(viewModel: RocketDetails(name: .init(value: "Falcon 9 v1.1"), client: .live()))
    }
}
