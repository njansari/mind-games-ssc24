import SwiftUI

@Observable final class Reactions: GameType {
    override class var name: String {
        "Targeted Reactions"
    }

    override class var category: String {
        "Reaction Time"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        The simple reaction time task is the simplest cognitive task possible. It measures your ability to perceive a stimulus in your environment and take action in response to it.
        \\
        \\
        A red target will repeatedly appear after a random amount of time and you need to tap on it as quickly as possible. The target can appear anywhere in the outlined area.
        """)

        if let range = str.range(of: "reaction time") {
            str[range].foregroundColor = color
        }

        if let range = str.range(of: "one") {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .red
    }

    override class var averageResults: GameResult.Data {
        .init(averageTime: 0.473)
    }

    var clockTime = 0.0
    var isTiming = false

    @MainActor func showTarget() async {
        Sounds.playSplitSound()

        try? await Task.sleep(for: .seconds(.random(in: 2...5)))

        isTiming = true
        isAcceptingInput = true
    }

    @MainActor func targetClicked() {
        guard isTiming else { return }

        isTiming = false
        addTime(clockTime)
        addPoints(20)

        Task { @MainActor in
            try await Task.sleep(for: .seconds(1))

            if !checkIfFinished() {
                withAnimation {
                    clockTime = 0
                }

                await showTarget()
            }
        }
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(averageTime: averageTime)
    }
}
