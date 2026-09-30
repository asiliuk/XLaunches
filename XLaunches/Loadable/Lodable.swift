import Foundation

enum Loadable<Content> {
    case initial
    case loading
    case loaded(Content)
    case failed(Error, retry: () async -> Void)
}

extension Loadable {
    func map<NewContent>(_ transform: (Content) -> NewContent) -> Loadable<NewContent> {
        switch self {
        case .loaded(let content): .loaded(transform(content))
        case .initial: .initial
        case .loading: .loading
        case .failed(let error, let retry): .failed(error, retry: retry)
        }
    }
}

extension Loadable {
    var canLoad: Bool {
        if case .initial = self { return true }
        if case .failed = self { return true }
        return false
    }
}
