import SwiftUI

struct SquaresGridButtonStyle: ButtonStyle {
    let isSelected: Bool
    let state: AnswerOptionState

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected || configuration.isPressed ? state.color : AnyShapeStyle(state.color.quinary))
            .frame(width: 100, height: 100)
            .background(state.color, in: .rect(cornerRadius: 10).stroke(lineWidth: 2))
    }
}

extension ButtonStyle where Self == SquaresGridButtonStyle {
    static func squaresGrid(isSelected: Bool = false, state: AnswerOptionState = .none) -> SquaresGridButtonStyle {
        SquaresGridButtonStyle(isSelected: isSelected, state: state)
    }
}

struct SquaresGrid: View {
    let selectedSquare: Int?
    let state: AnswerOptionState
    let isShowing: Bool
    let squareEntered: (Int) -> Void

    var body: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            GridRow {
                squareButton(for: 1)
                squareButton(for: 2)
                squareButton(for: 3)
                squareButton(for: 4)
            }

            GridRow {
                squareButton(for: 5)
                squareButton(for: 6)
                squareButton(for: 7)
                squareButton(for: 8)
            }

            GridRow {
                squareButton(for: 9)
                squareButton(for: 10)
                squareButton(for: 11)
                squareButton(for: 12)
            }

            GridRow {
                squareButton(for: 13)
                squareButton(for: 14)
                squareButton(for: 15)
                squareButton(for: 16)
            }
        }
    }

    func squareButton(for square: Int) -> some View {
        Button {
            Sounds.playClickSound()
            squareEntered(square)
        } label: {
            RoundedRectangle(cornerRadius: 10)
        }
        .buttonStyle(.squaresGrid(isSelected: selectedSquare == square, state: state))
        .opacity(!isShowing || selectedSquare == square ? 1 : 0.5)
    }
}

#Preview {
    SquaresGrid(selectedSquare: 1, state: .none, isShowing: false, squareEntered: { _ in })
}
