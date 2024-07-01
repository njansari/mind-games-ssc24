import SwiftUI

struct MathsView: GameTypeView {
    let controller: Maths

    var content: some View {
        if controller.numbersGrid.isEmpty {
            PlaceholderIcon()
        } else {
            HStack {
                Spacer()

                OperationsGrid(controller: controller)
                    .background(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.tint.opacity(0.05))
                            .stroke(.tint.secondary, lineWidth: 2)
                            .frame(width: 420, height: 420)
                            .offset(x: -20, y: -20)
                    }

                Spacer()

                Grid(horizontalSpacing: 20, verticalSpacing: 20) {
                    GridRow {
                        operatorButton(for: .add)
                        operatorButton(for: .subtract)
                    }

                    GridRow {
                        operatorButton(for: .multiply)
                        operatorButton(for: .divide)
                    }
                }

                Spacer()
            }
        }
    }

    func start() async {
        await controller.generateGrid()
    }

    func operatorButton(for operator: Maths.Operator) -> some View {
        Button {
            controller.setSelectorOperator(to: `operator`)
        } label: {
            Image(systemName: `operator`.icon)
        }
        .frame(width: 70, height: 70)
        .buttonStyle(.answerOption())
        .overlay {
            if let location = controller.selectedOperator, controller.operatorsGrid[location.0][location.1][location.2] == `operator` {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 5)
                    .frame(width: 75, height: 75)
            }
        }
    }
}

#Preview {
    MathsView(Maths())
}
