import SwiftUI

enum AnswerOptionState {
    case correct
    case incorrect
    case none

    var color: AnyShapeStyle {
        switch self {
        case .correct:
            AnyShapeStyle(.green)
        case .incorrect:
            AnyShapeStyle(.red)
        case .none:
            AnyShapeStyle(.tint)
        }
    }
}
