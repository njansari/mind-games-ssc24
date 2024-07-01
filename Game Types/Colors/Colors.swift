import SwiftUI

@Observable final class Colors: GameType {
    override class var name: String {
        "Stroop~wafels~"
    }

    override class var category: String {
        "Conflict Resolution"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        Sorry, but there aren't any stroopwafels here. This game is a variation on the classic Stroop Task which measures your ability to deal with conflicting information and still choose the correct outcome.
        \\
        \\
        For each question, you will be shown a word in a certain color. Your task is simply to select the **color** of the text from the list of options below. Easy right? Your response time will also be recorded.
        """)

        if let range = str.range(of: "conflicting") {
            str[range].foregroundColor = color
        }

        if let range = str.range(of: "color", options: .backwards) {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .orange
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.89, averageTime: 1.803)
    }

    typealias ColorPair = (label: String, color: Color)

    let labels: [String] = ["Blue", "Green", "Purple", "Red"]

    private let colors: [Color] = [
        .init(red: 0, green: 0, blue: 1),
        .init(red: 0, green: 1, blue: 0),
        .init(red: 1, green: 0, blue: 1),
        .init(red: 1, green: 0, blue: 0)
    ]

    private var startTime = Date.now

    var targetColor: ColorPair?

    @MainActor func nextColor() async {
        let previousColor = targetColor
        targetColor = nil

        try? await Task.sleep(for: .seconds(1))

        startTime = .now
        Sounds.playSplitSound()

        let label = labels.randomElement()!
        
        let color = {
            var colorsCopy = colors

            if .random(in: 1...4) != 1, let sameColorIndex = labels.firstIndex(of: label) {
                colorsCopy.remove(at: sameColorIndex)
            }

            if let previousColor, let previousColorIndex = colorsCopy.firstIndex(of: previousColor.color) {
                colorsCopy.remove(at: previousColorIndex)
            }

            return colorsCopy.randomElement()!
        }()

        targetColor = (label, color)

        isAcceptingInput = true
    }

    @discardableResult func colorOptionSelected(_ option: Int) -> AnswerOptionState {
        guard isAcceptingInput else { return .none }
        isAcceptingInput = false

        addTime(startTime.distance(to: .now))

        let isCorrect = colors[option] == targetColor?.color

        if isCorrect {
            addCorrect()
            Sounds.playCorrectSound()
            addPoints(20)
        } else {
            Sounds.playIncorrectSound()
            addPoints(10)
        }

        addQuestion()

        Task { @MainActor in
            try await Task.sleep(for: .seconds(1))

            if !checkIfFinished() {
                await nextColor()
            }
        }

        return isCorrect ? .correct : .incorrect
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(percentageCorrect: percentageCorrect, averageTime: averageTime)
    }
}
