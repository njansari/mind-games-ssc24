import SwiftUI

struct TowersView: GameTypeView {
    @State private var selectedMinimumMoves = 1
    @State private var answerOptionState: AnswerOptionState = .none

    @FocusState private var minMovesFieldFocused: Bool

    let controller: Towers

    var minMovesInput: some View {
        VStack {
            Text("Minimum moves")
                .font(.title2.weight(.medium))

            VStack {
                TextField("Minimum moves", value: $selectedMinimumMoves, format: .number, prompt: Text(""))
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .focused($minMovesFieldFocused)

                Stepper("Minimum moves", value: $selectedMinimumMoves, in: 1...50) { _ in
                    minMovesFieldFocused = false
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(answerOptionState.color.opacity(answerOptionState == .none ? 0.05 : 0.1))
            .background(answerOptionState.color.opacity(0.9), in: .rect(cornerRadius: 10).stroke(lineWidth: 2))

            Button {
                minMovesFieldFocused = false
                Task { @MainActor in
                    answerOptionState = controller.minMovesEntered(selectedMinimumMoves)
                    try await Task.sleep(for: .seconds(1))
                    answerOptionState = .none
                }
            } label: {
                Text("Submit")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .disabled(!controller.isAcceptingInput || !(1...50 ~= selectedMinimumMoves))
        }
        .labelsHidden()
        .controlSize(.regular)
        .frame(width: 180)
    }

    var content: some View {
        if let question = controller.currentQuestion {
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    TowersConfigView(config: question.startConfig)

                    Spacer()

                    Image(systemName: "arrow.forward")
                        .font(.system(size: 56, weight: .black))
                        .foregroundStyle(.secondary)

                    Spacer()

                    TowersConfigView(config: question.endConfig)

                    Spacer()
                }

                Spacer()

                minMovesInput

                Spacer()
            }
            .onAppear {
                selectedMinimumMoves = 1
            }
        } else {
            PlaceholderIcon()
        }
    }

    func start() async {
        await controller.nextQuestion()
    }
}

#Preview {
    TowersView(Towers())
        .frame(width: 1000, height: 600)
        .border(.red)
}
