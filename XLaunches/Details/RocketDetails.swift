import Foundation
import SpaceXAPI

struct RocketName: Hashable {
    let value: String
}

@Observable
final class RocketDetails {
    let name: String
    let client: SpaceXApiClient

    init(name: RocketName, client: SpaceXApiClient) {
        self.name = name.value
        self.client = client
    }
}
