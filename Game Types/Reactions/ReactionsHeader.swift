import SwiftUI

struct ReactionsHeader: GameTypeHeader {
    let controller: Reactions

    var content: some View {
        Text(controller.clockTime, format: .number.precision(.fractionLength(3)))
            .font(.largeTitle.bold().monospacedDigit())
            .contentTransition(controller.isTiming ? .identity : .numericText())
            .phaseAnimator([false, true], trigger: controller.isTiming) { content, phase in
                content
                    .scaleEffect(phase ? 1.1 : 1)
            } animation: { phase in
                if !controller.isTiming {
                    phase ? .bouncy(duration: 0.4) : .bouncy(duration: 0.5)
                } else {
                    nil
                }
            }
    }
}

#Preview {
    ReactionsHeader(Reactions())
}
