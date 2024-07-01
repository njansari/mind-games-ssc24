import SwiftUI

enum GameState: Equatable {
    case intro
    case select
    case game([GameOption])
    case results(GameResult)
}

struct GameStateEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<GameState> = .constant(.intro)
}

extension EnvironmentValues {
    var gameState: Binding<GameState> {
        get { self[GameStateEnvironmentKey.self] }
        set { self[GameStateEnvironmentKey.self] = newValue }
    }
}
