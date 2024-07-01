import SwiftUI

struct DefinitionsView: GameTypeView {
    @State private var answerOptionState: AnswerOptionState = .none

    let controller: Definitions

    var content: some View {
        if let question = controller.currentQuestion {
            VStack {
                Spacer()

                Text(question.word)
                    .font(.system(size: 96, weight: .bold))

                Spacer()

                Grid(horizontalSpacing: 20, verticalSpacing: 20) {
                    GridRow {
                        answerOptionButton(for: controller.answerOptions[0])
                        answerOptionButton(for: controller.answerOptions[1])
                    }

                    GridRow {
                        answerOptionButton(for: controller.answerOptions[2])
                        answerOptionButton(for: controller.answerOptions[3])
                    }
                }

                Spacer()
            }
        } else {
            PlaceholderIcon()
        }
    }

    func start() async {
        await controller.nextQuestion()
    }

    func answerOptionButton(for option: String) -> some View {
        Button {
            Task { @MainActor in
                answerOptionState = controller.definitionSelected(option)
                try await Task.sleep(for: .seconds(1))
                answerOptionState = .none
            }
        } label: {
            Text(option)
                .font(.title2.weight(.semibold))
                .minimumScaleFactor(0.5)
        }
        .frame(width: 300, height: 125)
        .buttonStyle(.answerOption(state: answerOptionState))
    }
}

#Preview {
    DefinitionsView(Definitions())
}
