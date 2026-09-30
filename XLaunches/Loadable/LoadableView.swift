import SwiftUI

struct LoadableView<Content, ContentView: View>: View {
    let loadable: Loadable<Content>
    @ViewBuilder let content: (Content) -> ContentView

    var body: some View {
        ZStack {
            switch loadable {
            case .initial:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let content):
                self.content(content)
            case .failed(let error, let retry):
                ContentUnavailableView {
                    Label {
                        Text("screen.unavailable.title")
                    } icon: {
                        Image(systemName: "wand.and.rays", variableValue: 0)
                            .symbolEffect(.variableColor.reversing)
                    }
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("screen.unavailable.button.retry") { Task { await retry() } }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct LoadMoreRow: View {
    let load: () async -> Void
    var body: some View {
        ProgressView { Text("view.load-more.title") }
            .frame(maxWidth: .infinity)
            .task { await load() }
    }
}

struct LoadMoreFailedRow: View {
    let retry: () async -> Void
    var body: some View {
        VStack {
            Text("view.load-more.failed.title")
            Button("view.load-more.failed.retry.title") { Task { await retry() }}
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LoadableView<String, EmptyView>(
        loadable: .failed(NSError(domain: "com.test", code: 100), retry: {}),
        content: { _ in EmptyView() }
    )
}
