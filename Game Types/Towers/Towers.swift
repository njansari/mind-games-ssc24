import SwiftUI

@Observable final class Towers: GameType {
    override class var name: String {
        "London, Hanoi"
    }

    override class var category: String {
        "Planning"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        The Tower of London is a classical neuropsychological test that measures your planning ability. This version of the test is particularly difficult because you cannot directly move the disks. Instead, you have to hold all previous moves in your memory whilst predicting future moves. This game is in combination with the older Tower of Hanoi test in which **no disk may be placed on top of a disk that is smaller than it**.
        \\
        \\
        Each question in this game shows you two configurations of three different-sized disks arranged on three rods: a starting state and a goal state. You will need to calculate the **minimum** number of moves required to get from the start to the goal. Moving a disk from one rod to another counts as one move.
        """)

        if let range = str.range(of: "planning") {
            str[range].foregroundColor = color
        }

        if let range = str.range(of: "minimum") {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .pink
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.83)
    }

    typealias TowerConfig = [[Int]]

    struct TowerQuestion: Decodable {
        let startConfig: TowerConfig
        let endConfig: TowerConfig
        let minimumMoves: Int
    }

    let loadedQuestions: [TowerQuestion] = {
        guard let url = Bundle.main.url(forResource: "towersConfigs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let contents = try? JSONDecoder().decode([TowerQuestion].self, from: data)
        else { fatalError("No config questions could be loaded.") }
        return Array(contents.shuffled().prefix(10))
    }()

    var currentQuestion: TowerQuestion?

    @MainActor func nextQuestion() async {
        currentQuestion = nil

        try? await Task.sleep(for: .seconds(1))

        Sounds.playSplitSound()
        currentQuestion = loadedQuestions[totalQuestions]

        isAcceptingInput = true
    }

    @discardableResult func minMovesEntered(_ moves: Int) -> AnswerOptionState {
        guard isAcceptingInput else { return .none }
        isAcceptingInput = false

        let isCorrect = moves == currentQuestion?.minimumMoves

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
                await nextQuestion()
            }
        }

        return isCorrect ? .correct : .incorrect
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(percentageCorrect: percentageCorrect)
    }
}
