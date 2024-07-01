import SwiftUI

enum GameOption {
    case reactions
    case squares
    case objects
    case numbers
    case colors
    case rotation
    case detection
    case towers
    case definitions
    case maths

    var gameType: GameType.Type {
        switch self {
        case .reactions:
            Reactions.self
        case .squares:
            Squares.self
        case .objects:
            Objects.self
        case .numbers:
            Numbers.self
        case .towers:
            Towers.self
        case .colors:
            Colors.self
        case .rotation:
            Rotation.self
        case .detection:
            Detection.self
        case .definitions:
            Definitions.self
        case .maths:
            Maths.self
        }
    }
}
