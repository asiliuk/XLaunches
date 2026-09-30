// This is a copy of a workaround from brilliant people from point-free.co
// https://github.com/pointfreeco/swift-navigation/blob/main/Sources/SwiftUINavigation/Binding.swift

import SwiftUI

extension Binding {
    /// Creates a binding by projecting the base value to an unwrapped value.
    ///
    /// Useful for producing non-optional bindings from optional ones.
    ///
    /// > Note: SwiftUI comes with an equivalent failable initializer, `Binding.init(_:)`, but using
    /// > it can lead to crashes at runtime. [Feedback][FB8367784] has been filed, but in the meantime
    /// > this initializer exists as a workaround.
    ///
    /// [FB8367784]: https://gist.github.com/stephencelis/3a232a1b718bab0ae1127ebd5fcf6f97
    ///
    /// - Parameter base: A value to project to an unwrapped value.
    public init?(unwrapping base: Binding<Value?>) {
        guard let value = base.wrappedValue else { return nil }
        self.init(unwrapping: base, default: value)
    }

    public init(unwrapping base: Binding<Value?>, default value: Value) {
        self = base[default: DefaultSubscript(value)]
    }
}

extension Optional {
    fileprivate subscript(default defaultSubscript: DefaultSubscript<Wrapped>) -> Wrapped {
        get {
            defaultSubscript.value = self ?? defaultSubscript.value
            return defaultSubscript.value
        }
        set {
            defaultSubscript.value = newValue
            if self != nil { self = newValue }
        }
    }
}

private final class DefaultSubscript<Value>: Hashable {
    var value: Value
    init(_ value: Value) {
        self.value = value
    }
    static func == (lhs: DefaultSubscript, rhs: DefaultSubscript) -> Bool {
        lhs === rhs
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
