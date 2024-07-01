import SwiftUI

struct SquaresView: GameTypeView {
    @State private var squaresGridState: AnswerOptionState = .none

    let controller: Squares

    var selectedSquare: Int? {
        if case .showing = controller.state, !controller.squares.isEmpty {
            controller.currentSquare
        } else {
            nil
        }
    }

    var content: some View {
        SquaresGrid(selectedSquare: selectedSquare, state: squaresGridState, isShowing: controller.state == .showing) { num in
            Task { @MainActor in
                squaresGridState = controller.squareEntered(num)
                try await Task.sleep(for: .seconds(1))
                squaresGridState = .none
            }
        }
    }

    func start() async {
        await controller.startShowingNewSquares()
    }
}

#Preview {
    SquaresView(Squares())
}
