import SwiftUI

typealias OperatorLocation = (Int, Int, Int)

struct OperationsGrid: View {
    @State private var answerStates: [[AnswerOptionState]] = [[.none, .none, .none], [.none, .none, .none]]

    let controller: Maths

    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                number(controller.numbersGrid[0][0])
                operatorButton(at: (0, 0, 0))
                number(controller.numbersGrid[0][1])
                operatorButton(at: (0, 0, 1))
                number(controller.numbersGrid[0][2])

                AnswerNumber(controller: controller, row: 0, state: answerStates[0][0])
                    .padding(.leading, 20)
            }

            GridRow {
                operatorButton(at: (1, 0, 0))

                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])

                operatorButton(at: (1, 1, 0))

                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])

                operatorButton(at: (1, 2, 0))
            }

            GridRow {
                number(controller.numbersGrid[1][0])
                operatorButton(at: (0, 1, 0))
                number(controller.numbersGrid[1][1])
                operatorButton(at: (0, 1, 1))
                number(controller.numbersGrid[1][2])

                AnswerNumber(controller: controller, row: 1, state: answerStates[0][1])
                    .padding(.leading, 20)
            }

            GridRow {
                operatorButton(at: (1, 0, 1))

                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])

                operatorButton(at: (1, 1, 1))

                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])

                operatorButton(at: (1, 2, 1))
            }

            GridRow {
                number(controller.numbersGrid[2][0])
                operatorButton(at: (0, 2, 0))
                number(controller.numbersGrid[2][1])
                operatorButton(at: (0, 2, 1))
                number(controller.numbersGrid[2][2])

                AnswerNumber(controller: controller, row: 2, state: answerStates[0][2])
                    .padding(.leading, 20)
            }

            GridRow {
                AnswerNumber(controller: controller, col: 0, state: answerStates[1][0])

                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])

                AnswerNumber(controller: controller, col: 1, state: answerStates[1][1])

                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])

                AnswerNumber(controller: controller, col: 2, state: answerStates[1][2])
            }
            .padding(.top, 20)
        }
        .buttonStyle(.numberPad())
        .onAppear {
            controller.onSelect = { location in
                let oldValue = answerStates[location.0][location.1]
                let newValue: AnswerOptionState = {
                    if location.0 == 0, let rowValue = controller.evaluateRow(location.1) {
                        return controller.answerNumbers[0][location.1] == rowValue ? .correct : .incorrect
                    } else if location.0 == 1, let colValue = controller.evaluateColumn(location.1) {
                        return controller.answerNumbers[1][location.1] == colValue ? .correct : .incorrect
                    }

                    return .none
                }()

                answerStates[location.0][location.1] = newValue
                
                return {
                    switch newValue {
                    case .correct:
                        true
                    default:
                        newValue == .incorrect && oldValue != newValue ? false : nil
                    }
                }()
            }
        }
    }

    func operatorButton(at location: OperatorLocation) -> some View {
        Button {
            controller.selectedOperator = location
        } label: {
            Image(systemName: controller.operatorsGrid[location.0][location.1][location.2]?.icon ?? "questionmark")
                .font(.title.bold())
        }
        .frame(width: 70, height: 70)
        .buttonStyle(.answerOption(state: answerStates[location.0][location.1]))
        .overlay {
            if let selectedOperator = controller.selectedOperator, selectedOperator == location {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 5)
            }
        }
        .padding(-5)
        .allowsHitTesting(answerStates[location.0][location.1] != .correct)
    }

    func number(_ number: Int) -> some View {
        Text("\(number)")
            .font(.system(size: 42).bold())
            .frame(width: 60, height: 60)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
                    .frame(width: 80, height: 80)
            }
            .zIndex(1)
    }
}

struct AnswerNumber: View {
    let number: Int
    let state: AnswerOptionState

    init(controller: Maths, row: Int? = nil, col: Int? = nil, state: AnswerOptionState) {
        if let row {
            number = controller.answerNumbers[0][row]
        } else if let col {
            number = controller.answerNumbers[1][col]
        } else {
            number = 0
        }

        self.state = state
    }

    var body: some View {
        Text("\(number)")
            .font(.system(size: 42).bold())
            .foregroundStyle(.background)
            .frame(width: 60, height: 60)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(state.color)
//                    .stroke(.primary, lineWidth: 2)
                    .frame(width: 80, height: 80)
            }
            .zIndex(1)
    }
}

#Preview {
    OperationsGrid(controller: .init())
}
