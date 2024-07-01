import SwiftUI

struct NumbersView: GameTypeView {
    @State private var numberPadState: AnswerOptionState = .none

    let controller: Numbers

    var content: some View {
        switch controller.state {
        case .showing:
            if controller.numbers.isEmpty {
                PlaceholderIcon()
            } else {
                Text("\(controller.currentNumber)")
                    .font(.system(size: 196).bold())
            }
        case .accepting:
            NumberPad(state: numberPadState) { num in
                Task { @MainActor in
                    numberPadState = controller.numberEntered(num)
                    try await Task.sleep(for: .seconds(1))
                    numberPadState = .none
                }
            }
        }
    }

    func start() async {
        await controller.startShowingNewNumbers()
    }
}

#Preview {
    NumbersView(Numbers())
        .frame(width: 1000, height: 600)
        .border(.red)
}
