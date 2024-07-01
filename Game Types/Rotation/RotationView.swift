import SwiftUI

struct RotationView: GameTypeView {
    @State private var answerOptionState: AnswerOptionState = .none

    let controller: Rotation

    var content: some View {
        if let targetGrid = controller.targetGrid {
            VStack {
                Spacer()

                RotatedGridView(grid: targetGrid, size: 40)

                Spacer()

                HStack(spacing: 20) {
                    ForEach(0..<controller.answerOptions.count, id: \.self) { i in
                        Button {
                            Task { @MainActor in
                                answerOptionState = controller.gridOptionSelected(i)
                                try await Task.sleep(for: .seconds(1))
                                answerOptionState = .none
                            }
                        } label: {
                            RotatedGridView(grid: controller.answerOptions[i].grid, size: 20)
                                .rotationEffect(.degrees(controller.answerOptions[i].rotation))
                        }
                        .frame(width: 150, height: 150)
                        .buttonStyle(.answerOption(state: answerOptionState))
                    }
                }

                Spacer()
            }
        } else {
            PlaceholderIcon()
        }
    }

    func start() async {
        await controller.nextGrid()
    }
}

#Preview {
    RotationView(Rotation())
}
