import SwiftUI

@Observable final class Squares: GameType {
    override class var name: String {
        "Order. Orderrrr!"
    }

    override class var category: String {
        "Spatial Working Memory"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        This game measures a different type of memory buffer to \(Numbers.name). This is sometimes referred to as the visuospatial scratchpad. When you close your eyes and hold in your mind something that you have just seen, it is the visuospatial that is used.
        \\
        \\
        You will be shown a grid on which squares will be highlighted in  sequence. You will need to remember the locations of these squares in the **order** they appeared. Then, repeat that sequence back on to the grid in the correct order. Each iteration of highlighted squares increases in length.
        """)

        if let range = str.range(of: Numbers.name) {
            str[range].foregroundColor = Numbers.color
        }

        if let range = str.range(of: "order") {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .cyan
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.63, memoryLength: 6)
    }

    enum GameState {
        case showing
        case accepting
    }

    var state: GameState = .showing

    var squares: [Int] = []

    var currentSquareIndex = 0

    var currentSquare: Int {
        squares[currentSquareIndex]
    }

    func generateNewSquares() {
        for i in 0..<numElements {
            let range = (1...16).filter { i == 0 ? true : $0 != squares[i - 1] }
            squares.append(range.randomElement()!)
        }
    }

    @discardableResult func squareEntered(_ square: Int) -> AnswerOptionState {
        guard isAcceptingInput else { return .none }

        let isCorrect = square == squares[currentSquareIndex]

        if isCorrect {
            if currentSquareIndex < squares.count - 1 {
                currentSquareIndex += 1
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
                await startShowingNewSquares()
            }
        }

        return isCorrect ? .correct : .incorrect
    }

    @MainActor func startShowingNewSquares() async {
        state = .showing
        currentSquareIndex = 0
        squares.removeAll()

        try? await Task.sleep(for: .seconds(1))
        generateNewSquares()
        await showNextSquare()
    }

    @MainActor func showNextSquare() async {
        Sounds.playSplitSound()
        try? await Task.sleep(for: .seconds(1))

        if currentSquareIndex < squares.count - 1 {
            currentSquareIndex += 1
            await showNextSquare()
        } else {
            state = .accepting
            currentSquareIndex = 0
            isAcceptingInput = true
        }
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(percentageCorrect: percentageCorrect, memoryLength: memoryLength)
    }
}
