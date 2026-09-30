import Foundation
import SpaceXAPI

final class RootViewModel {
    let launches: LaunchesList
    let rockets: RocketsList

    init(client: SpaceXApiClient) {
        launches = LaunchesList(client: client)
        rockets = RocketsList(client: client)
    }
}
