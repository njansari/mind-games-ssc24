import SwiftUI

struct DetectionHeader: GameTypeHeader {
    let controller: Detection

    var content: some View {
        HStack {
            Text("Score:")

            Text("\(controller.score)")
                .contentTransition(.numericText(value: Double(controller.score)))
                .animation(.easeOut, value: controller.score)
        }
        .font(.title.bold().monospacedDigit())
    }
}

#Preview {
    DetectionHeader(Detection())
}
