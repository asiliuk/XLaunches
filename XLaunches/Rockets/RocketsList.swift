import Foundation
import SpaceXAPI

@Observable
final class RocketsList {
    var rockets: [Rocket]
    var isLoading: Bool
    let client: SpaceXApiClient

    init(rockets: [Rocket] = [], isLoading: Bool = false, client: SpaceXApiClient) {
        self.rockets = rockets
        self.isLoading = isLoading
        self.client = client
    }

    func load() async {
        isLoading = true
        do {
            rockets = try await client.rockets()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        isLoading = false
    }
}
