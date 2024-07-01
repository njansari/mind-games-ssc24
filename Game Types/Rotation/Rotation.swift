import SwiftUI

@Observable final class Rotation: GameType {
    override class var name: String {
        "You Spin Me Round"
    }

    override class var category: String {
        "Mental Rotation"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        Have you ever tried to solve a Rubik's cube by imagining what would happen if you rotated one of the sides? This game is designed to test that same ability by seeing how well you can keep an image in mind and manipulate it mentally to get the right answer. This relies on both your working memory and reasoning abilities which are both very important to help you plan and problem-solve.
        \\
        \\
        A grid of colored squares is the basis for each question and you have to choose, from the list of options, that **same** grid which has been **rotated** some amount.
        """)

        if let range1 = str.range(of: "mentally"), let range2 = str.range(of: "rotated") {
            str[range1].foregroundColor = color
            str[range2].foregroundColor = color
        }

        if let range = str.range(of: "same", options: .backwards) {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .init(red: 224 / 255, green: 172 / 255, blue: 0)
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.91)
    }

    typealias RotatedGrid = [[Int]]

    let loadedQuestions: [RotatedGrid] = {
        guard let url = Bundle.main.url(forResource: "rotatedGridConfigs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let contents = try? JSONDecoder().decode([RotatedGrid].self, from: data)
        else { fatalError("No config questions could be loaded.") }
        return Array(contents.shuffled().prefix(10))
    }()

    var targetGrid: RotatedGrid?

    var answerOptions: [(grid: RotatedGrid, rotation: Double)] = []

    func generateGrid() -> RotatedGrid {
        guard let targetGrid else { return [] }

        var grid = targetGrid

        for i in 0..<4 {
            for j in 0..<4 {
                if .random() {
                    let number = Int.random(in: 1...10)
                    let value = 1...4 ~= number ? number : 0
                    grid[i][j] = value
                }
            }
        }

        return grid
    }

    @MainActor func nextGrid() async {
        targetGrid = nil

        try? await Task.sleep(for: .seconds(1))

        Sounds.playSplitSound()

        targetGrid = loadedQuestions[totalQuestions]

        answerOptions = {
            let rotationAmounts: [Double] = [90, 180, 270]
            var options: [(grid: RotatedGrid, rotation: Double)] = []

            if let targetGrid {
                options.append((targetGrid, rotationAmounts.randomElement()!))
            }

            options.append(contentsOf: (1...3).map { _ in (generateGrid(), rotationAmounts.randomElement()!) })

            return options.shuffled()
        }()

        isAcceptingInput = true
    }

    @discardableResult func gridOptionSelected(_ option: Int) -> AnswerOptionState {
        guard isAcceptingInput else { return .none }
        isAcceptingInput = false

        let isCorrect = answerOptions[option].grid == targetGrid

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
                await nextGrid()
            }
        }

        return isCorrect ? .correct : .incorrect
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(percentageCorrect: percentageCorrect)
    }
}
