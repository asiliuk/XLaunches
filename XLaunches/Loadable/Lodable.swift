import Foundation

enum Loadable<Content> {
    case initial
    case loading
    case loaded(Content)
    case failed(Error, retry: () async -> Void)
}
