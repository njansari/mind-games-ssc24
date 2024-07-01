import SwiftUI

@Observable final class Numbers: GameType {
    override class var name: String {
        "How High Can You Go?"
    }

    override class var category: String {
        "Verbal Working Memory"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        Can you remember a telephone number without writing it down? This game is designed to test that ability and see how many numbers you can remember over a short period of time. Holding numbers in your mind typically uses what is called the "phonological loop". That is, the loop of sounds that you can rehearse in your mind. We rely on working memory buffers such as the phonological loop every day to perform actions.
        \\
        \\
        You will be shown a sequence of numbers which you will need to remember **in order**. Then, enter those numbers on the number pad in the correct order. Each iteration of numbers increases in length.
        """)

        if let range = str.range(of: "working memory") {
            str[range].foregroundColor = color
        }

        if let range = str.range(of: "in order") {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .blue
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.72, memoryLength: 7)
    }

    enum GameState {
        case showing
        case accepting
    }

    var state: GameState = .showing

    var numbers: [Int] = []

    var currentNumberIndex = 0

    var currentNumber: Int {
        numbers[currentNumberIndex]
    }

    func generateNewNumbers() {
        for i in 0..<numElements {
            let range = (0...9).filter { i == 0 ? true : $0 != numbers[i - 1] }
            numbers.append(range.randomElement()!)
        }
    }

    @discardableResult func numberEntered(_ number: Int) -> AnswerOptionState {
        guard isAcceptingInput else { return .none }

        let isCorrect = number == numbers[currentNumberIndex]

        if isCorrect {
            if currentNumberIndex < numbers.count - 1 {
                currentNumberIndex += 1
                return .none
            }

            addCorrect()
            Sounds.playCorrectSound()
            addPoints(20)
            addElements(2)
        } else {
            Sounds.playIncorrectSound()
            addPoints(10)
        }

        addQuestion()

        isAcceptingInput = false

        Task { @MainActor in
            try await Task.sleep(for: .seconds(1))

            if !checkIfFinished() {
                await startShowingNewNumbers()
            }
        }

        return isCorrect ? .correct : .incorrect
    }

    @MainActor func startShowingNewNumbers() async {
        state = .showing
        currentNumberIndex = 0
        numbers.removeAll()

        try? await Task.sleep(for: .seconds(1))
        generateNewNumbers()
        await showNextNumber()
    }

    @MainActor func showNextNumber() async {
        Sounds.playSplitSound()
        try? await Task.sleep(for: .seconds(1))

        if currentNumberIndex < numbers.count - 1 {
            currentNumberIndex += 1
            await showNextNumber()
        } else {
            state = .accepting
            currentNumberIndex = 0
            isAcceptingInput = true
        }
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(percentageCorrect: percentageCorrect, memoryLength: memoryLength)
    }
}
