import SwiftUI

@Observable final class Detection: GameType {
    override class var name: String {
        "An Imposter Among Us"
    }

    override class var category: String {
        "Attention"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        The target detection task measures "attention", that is, your ability to identify visual information that is relevant and to filter out information that is distracting. Attention is very important in everyday life because we live in a complex and noisy world.
        \\
        \\
        You will be shown an area where figures will appear and disappear randomly. Your aim is to tap on the **archer** before they disappear again. You are awarded points for every archer you catch and are docked points for every archer you miss or other figure you tap on.
        """)

        if let range = str.range(of: "attention") {
            str[range].foregroundColor = color
        }

        if let range = str.range(of: "archer") {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .teal
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.92, averageTime: 2.33)
    }

    typealias ElementLocation = (row: Int, col: Int)

    struct Element: Equatable {
        let creationDate: Date
        let duration: Double
        let icon: String
        let offset: CGSize

        init(duration: Double, icon: String) {
            self.duration = duration
            self.icon = icon

            creationDate = .now
            offset = .init(width: .random(in: -8...8), height: .random(in: -8...8))
        }
    }

    let rowCount = 8
    let columnCount = 15

    let timeInterval = 0.3
    var timeRemaining = 30.0

    private var missedTargets = 0

    var score = 0

    let icons = [
        "figure.archery",
        "figure.boxing",
        "figure.american.football",
        "figure.softball",
        "figure.golf",
        "figure.fencing"
    ]

    let targetIcon = "figure.archery"

    var elementsGrid: [[Element?]] = []

    var selectedElement: ElementLocation?

    func updateTime() {
        timeRemaining -= timeInterval
        addPoints(1)

        removeExpiredElements()

        if .random() {
            for _ in 1...(.random(in: 1...4)) {
                addElement()
            }
        }

        checkFinished()
    }

    func checkFinished() {
        guard isAcceptingInput, progress >= 100 else { return }

        isAcceptingInput = false

        Sounds.glass.play()

        Task { @MainActor in
            try await Task.sleep(for: .seconds(1))

            checkIfFinished()

            for _ in 0..<missedTargets {
                addQuestion(checkIncorrect: false)
            }
        }
    }

    func addElement() {
        var nilIndices: [(row: Int, column: Int)] = []

        for (rowIndex, row) in elementsGrid.enumerated() {
            for (columnIndex, element) in row.enumerated() where element == nil {
                nilIndices.append((rowIndex, columnIndex))
            }
        }

        if let randomNilIndex = nilIndices.randomElement() {
            let icon = icons.randomElement()!

            let newElement = Element(duration: .random(in: 5...10), icon: icon)
            elementsGrid[randomNilIndex.row][randomNilIndex.column] = newElement
        }
    }

    func removeExpiredElements() {
        for i in 0..<rowCount {
            for j in 0..<columnCount {
                if let element = elementsGrid[i][j], element.creationDate.advanced(by: element.duration) <= .now {
                    elementsGrid[i][j] = nil

                    if targetIcon == element.icon {
                        addToScore(-Int(element.duration))
                        missedTargets += 1
                    }
                }
            }
        }
    }

    func addToScore(_ value: Int) {
        score = max(0, score + value)
    }

    @MainActor func generateGrid() async {
        try? await Task.sleep(for: .seconds(1))

        Sounds.playSplitSound()
        elementsGrid = .init(repeating: .init(repeating: nil, count: columnCount), count: rowCount)

        isAcceptingInput = true
    }

    @discardableResult func elementSelected(at location: ElementLocation) -> AnswerOptionState {
        let element = elementsGrid[location.row][location.col]

        defer {
            Task { @MainActor in
                try await Task.sleep(for: .seconds(0.4))
                elementsGrid[location.row][location.col] = nil
                selectedElement = nil

                checkFinished()
            }
        }

        if let element {
            selectedElement = location

            let isCorrect = targetIcon == element.icon

            if isCorrect {
                addCorrect()
                Sounds.playCorrectSound()

                let interval = Date.now.timeIntervalSince(element.creationDate)
                addTime(interval)

                addToScore(Int(element.duration - interval))
            } else {
                Sounds.playIncorrectSound()

                addToScore(-Int(element.duration))
            }

            addQuestion()

            return isCorrect ? .correct : .incorrect
        } else {
            return .none
        }
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(percentageCorrect: percentageCorrect, averageTime: averageTime)
    }
}
