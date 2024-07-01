import SwiftUI

struct ReactionsView: GameTypeView {
    @Environment(\.gameAreaSize) private var gameAreaSize

    @State private var timer = Timer.publish(every: 0.004, on: .main, in: .common).autoconnect()

    let controller: Reactions

    var targetArea: CGSize {
        let multiplier = Double(controller.progress) * 0.012

        return .init(
            width: (gameAreaSize.width / 2 - 100) * multiplier,
            height: (gameAreaSize.height / 2 - 100) * multiplier
        )
    }

    var content: some View {
        if controller.isTiming {
            Image(systemName: "target")
                .font(.system(size: 144, weight: .bold))
                .foregroundStyle(.tint)
                .contentShape(.circle)
                .offset(
                    x: .random(in: -targetArea.width...targetArea.width),
                    y: .random(in: -targetArea.height...targetArea.height)
                )
                .onTapGesture {
                    Task { @MainActor in
                        controller.targetClicked()
                    }
                }
                .onReceive(timer) { _ in
                    guard controller.isTiming else { return }
                    controller.clockTime += timer.upstream.interval
                }
        } else {
            PlaceholderIcon()
        }
    }

    func start() async {
        await controller.showTarget()
    }
}

#Preview {
    ReactionsView(Reactions())
        .frame(width: 1000, height: 600)
        .environment(\.gameAreaSize, .init(width: 1000, height: 600))
        .border(.red)
}
