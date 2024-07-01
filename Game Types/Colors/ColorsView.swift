import SwiftUI

struct AnswerOptionButtonStyle: ButtonStyle {
    let state: AnswerOptionState

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle.weight(.semibold))
            .foregroundStyle(configuration.isPressed ? AnyShapeStyle(.white) : state.color)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                configuration.isPressed ? state.color : AnyShapeStyle(state.color.quinary),
                in: .rect(cornerRadius: 10)
            )
            .background(state.color, in: .rect(cornerRadius: 10).stroke(lineWidth: 2))
    }
}

extension ButtonStyle where Self == AnswerOptionButtonStyle {
    static func answerOption(state: AnswerOptionState = .none) -> AnswerOptionButtonStyle {
        AnswerOptionButtonStyle(state: state)
    }
}

struct ColorsView: GameTypeView {
    @State private var answerOptionState: AnswerOptionState = .none

    let controller: Colors

    var content: some View {
        if let color = controller.targetColor {
            VStack {
                Text(color.label)
                    .font(.system(size: 144, weight: .bold))
                    .foregroundStyle(color.color)

                HStack(spacing: 20) {
                    ForEach(0..<controller.labels.count, id: \.self) { i in
                        Button(controller.labels[i]) {
                            Task { @MainActor in
                                answerOptionState = controller.colorOptionSelected(i)
                                try await Task.sleep(for: .seconds(1))
                                answerOptionState = .none
                            }
                        }
                        .frame(width: 150, height: 100)
                        .buttonStyle(.answerOption(state: answerOptionState))
                    }
                }
            }
        } else {
            PlaceholderIcon()
        }
    }

    func start() async {
        await controller.nextColor()
    }
}

#Preview {
    ColorsView(Colors())
        .frame(width: 1000, height: 600)
        .border(.red)
}
