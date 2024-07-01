import SwiftUI

struct NumberPadButtonStyle: ButtonStyle {
    let state: AnswerOptionState

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 48, weight: .semibold).monospacedDigit())
            .foregroundStyle(configuration.isPressed ? AnyShapeStyle(.white) : state.color)
            .padding()
            .frame(width: 80, height: 80)
            .background(
                configuration.isPressed ? state.color : AnyShapeStyle(state.color.quinary),
                in: .rect(cornerRadius: 10)
            )
            .background(state.color, in: .rect(cornerRadius: 10).stroke(lineWidth: 2))
    }
}

extension ButtonStyle where Self == NumberPadButtonStyle {
    static func numberPad(state: AnswerOptionState = .none) -> NumberPadButtonStyle {
        NumberPadButtonStyle(state: state)
    }
}

struct NumberPad: View {
    let state: AnswerOptionState
    let numberEntered: (Int) -> Void

    var body: some View {
        Grid(horizontalSpacing: 15, verticalSpacing: 15) {
            GridRow {
                numberButton(for: 7)
                numberButton(for: 8)
                numberButton(for: 9)
            }

            GridRow {
                numberButton(for: 4)
                numberButton(for: 5)
                numberButton(for: 6)
            }

            GridRow {
                numberButton(for: 1)
                numberButton(for: 2)
                numberButton(for: 3)
            }

            GridRow {
                numberButton(for: 0)
                    .gridCellColumns(3)
            }
        }
    }

    func numberButton(for number: Int) -> some View {
        Button("\(number)") {
            Sounds.playClickSound()
            numberEntered(number)
        }
        .buttonStyle(.numberPad(state: state))
    }
}

#Preview {
    NumberPad(state: .none, numberEntered: { _ in })
}
