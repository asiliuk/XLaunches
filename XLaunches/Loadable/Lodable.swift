import Foundation

enum Loadable<Content> {
    case initial
    case loading
    case loaded(Content)
    case failed(Error, retry: () async -> Void)
}

extension Loadable {
    var canLoad: Bool {
        if case .initial = self { return true }
        if case .failed = self { return true }
        return false
    }
}
