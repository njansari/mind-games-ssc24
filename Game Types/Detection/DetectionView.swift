import SwiftUI

struct DetectionView: GameTypeView {
    @Environment(\.gameAreaSize) private var gameAreaSize

    @State private var timer: Timer.TimerPublisher
    @State private var selectedElementState: AnswerOptionState = .none

    let controller: Detection

    init(controller: Detection) {
        self.controller = controller
        let timer = Timer.publish(every: controller.timeInterval, on: .main, in: .common)
        _timer = State(initialValue: timer)
    }

    var content: some View {
        if controller.elementsGrid.isEmpty {
            PlaceholderIcon()
        } else {
            Grid {
                ForEach(0..<controller.rowCount, id: \.self) { i in
                    GridRow {
                        ForEach(0..<controller.columnCount, id: \.self) { j in
                            elementButton(at: (i, j))
                                .frame(width: gameAreaSize.width / 20, height: gameAreaSize.width / 20)
                        }
                    }
                }
            }
            .disabled(!controller.isAcceptingInput)
            .animation(.easeOut, value: controller.elementsGrid)
            .onReceive(timer) { _ in
                guard controller.isAcceptingInput, controller.timeRemaining > 0 else { return }
                controller.updateTime()
            }
        }
    }

    func start() async {
        await controller.generateGrid()
        _ = timer.connect()
    }

    @ViewBuilder func elementButton(at location: Detection.ElementLocation) -> some View {
        if let element = controller.elementsGrid[location.row][location.col] {
            let isSelected = controller.selectedElement ?? (-1, -1) == location

            Button {
                selectedElementState = controller.elementSelected(at: location)
            } label: {
                Image(systemName: element.icon)
                    .font(.system(size: gameAreaSize.width / 32, weight: .semibold))
                    .foregroundStyle(isSelected ? selectedElementState.color : AnyShapeStyle(.primary))
            }
            .buttonStyle(.plain)
            .transition(.asymmetric(insertion: .opacity, removal: .scale.combined(with: .opacity)))
            .offset(element.offset)
        } else {
            Color.clear
        }
    }
}

#Preview {
    DetectionView(Detection())
        .frame(width: 1000, height: 600)
        .environment(\.gameAreaSize, .init(width: 1000, height: 600))
        .border(.red)
}
