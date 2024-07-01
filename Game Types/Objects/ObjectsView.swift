import SwiftUI

struct ObjectsView: GameTypeView {
    @State private var answerOptionState: AnswerOptionState = .none
    let controller: Objects

    var content: some View {
        switch controller.state {
        case .showing:
            if controller.objects.isEmpty {
                PlaceholderIcon()
            } else {
                Image(systemName: controller.currentObject.icon)
                    .symbolVariant(.fill)
                    .font(.system(size: 156, weight: .bold))
                    .rotation3DEffect(.degrees(controller.currentObject.isFlipped ? 180 : 0), axis: (0, 1, 0))
            }
        case .accepting:
            if controller.answerOptionObjects.isEmpty {
                PlaceholderIcon()
            } else {
                Grid(horizontalSpacing: 30, verticalSpacing: 30) {
                    GridRow {
                        answerOptionButton(for: controller.answerOptionObjects[0])
                        answerOptionButton(for: controller.answerOptionObjects[1])
                        answerOptionButton(for: controller.answerOptionObjects[2])
                    }

                    GridRow {
                        answerOptionButton(for: controller.answerOptionObjects[3])
                        answerOptionButton(for: controller.answerOptionObjects[4])
                        answerOptionButton(for: controller.answerOptionObjects[5])
                    }
                }
            }
        }
    }

    func start() async {
        await controller.startShowingObjects()
    }

    func answerOptionButton(for option: Objects.ObjectIcon) -> some View {
        Button {
            Task { @MainActor in
                answerOptionState = controller.objectSelected(option)
                try await Task.sleep(for: .seconds(1))
                answerOptionState = .none
            }
        } label: {
            Image(systemName: option.icon)
                .symbolVariant(.fill)
                .font(.system(size: 96, weight: .semibold))
                .rotation3DEffect(.degrees(option.isFlipped ? 180 : 0), axis: (0, 1, 0))
        }
        .frame(width: 200, height: 200)
        .buttonStyle(.answerOption(state: answerOptionState))
    }
}

#Preview {
    ObjectsView(Objects())
}
