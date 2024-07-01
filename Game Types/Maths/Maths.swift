import SwiftUI

@Observable final class Maths: GameType {
    override class var name: String {
        "Operating Table"
    }

    override class var category: String {
        "Visual Planning"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        The subject of mathematics is the core area of knowledge most people have. At the very beginning are the four basic operations: addition, subtraction, multiplication, and division. In this game, they are being used to test your ability to understand visual information and use a set of predetermined rules to come to a logical conclusion.
        \\
        \\
        You will be shown a grid of numbers and placeholders [**?**] for operations. Each row and column represents a simple mathematical equation. Your aim is to complete the grid by placing operations in all the right places so that the equations **equal** the number at the end of their row or column. *Don't forget about the order of operations!*
        """)

        if let range = str.range(of: "visual") {
            str[range].foregroundColor = color
        }

        if let range = str.range(of: "equal") {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .indigo
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.84)
    }

    enum Operator {
        case add
        case subtract
        case multiply
        case divide

        var icon: String {
            switch self {
            case .add:
                "plus"
            case .subtract:
                "minus"
            case .multiply:
                "multiply"
            case .divide:
                "divide"
            }
        }

        func apply(_ a: Int, _ b: Int) -> Int {
            switch self {
            case .add:
                a + b
            case .subtract:
                a - b
            case .multiply:
                a * b
            case .divide:
                a / b
            }
        }
    }

    var numbersGrid: [[Int]] = []
    var answerNumbers: [[Int]] = []

    @MainActor func generateGrid() async {
        numbersGrid = []
        answerNumbers = []

        guard let url = Bundle.main.url(forResource: "mathsGridConfigs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let contents = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { fatalError("No grids could be loaded.") }

        guard let grid = contents.randomElement(),
              let numbers = grid["numbers"] as? [[Int]],
              let answers = grid["answers"] as? [[Int]]
        else { fatalError("The selected grid could not be loaded.") }

        try? await Task.sleep(for: .seconds(1))

        numbersGrid = numbers
        answerNumbers = answers
        
        Sounds.playSplitSound()
        
        selectedOperator = (0, 0, 0)

        isAcceptingInput = true
    }

    var operatorsGrid: [[[Operator?]]] = .init(
        repeating: .init(
            repeating: .init(
                repeating: nil,
                count: 2
            ),
            count: 3
        ),
        count: 2
    )

    var selectedOperator: OperatorLocation?
    var onSelect: ((OperatorLocation) -> Bool?)?

    func setSelectorOperator(to operator: Operator) {
        guard let selectedOperator else { return }

        operatorsGrid[selectedOperator.0][selectedOperator.1][selectedOperator.2] = `operator`

        if let result = onSelect?(selectedOperator) {
            if result {
                self.selectedOperator = nil

                addCorrect()
                Sounds.playCorrectSound()
                addPoints(17)

            } else {
                Sounds.playIncorrectSound()
            }

            addQuestion()

            Task { @MainActor in
                try await Task.sleep(for: .seconds(1))
                checkIfFinished()
            }
        }
    }

    func getNumbers(row: Int) -> [Int] {
        numbersGrid[row]
    }

    func getNumbers(col: Int) -> [Int] {
        numbersGrid.map { $0[col] }
    }

    func getOperators(row: Int) -> [Operator?] {
        operatorsGrid[0][row]
    }

    func getOperators(col: Int) -> [Operator?] {
        operatorsGrid[1][col]
    }

    func evaluateRow(_ row: Int) -> Int? {
        let numbers = getNumbers(row: row)
        let operators = getOperators(row: row)

        guard !operators.contains(where: { $0 == nil }) else { return nil }

        return evaluateEquation(numbers[0], operators[0]!, numbers[1], operators[1]!, numbers[2])
    }

    func evaluateColumn(_ col: Int) -> Int? {
        let numbers = getNumbers(col: col)
        let operators = getOperators(col: col)

        guard !operators.contains(where: { $0 == nil }) else { return nil }

        return evaluateEquation(numbers[0], operators[0]!, numbers[1], operators[1]!, numbers[2])
    }

    private func evaluateEquation(_ a: Int, _ op1: Operator, _ b: Int, _ op2: Operator, _ c: Int) -> Int {
        switch op1 {
        case .add, .subtract:
            switch op2 {
            case .add, .subtract:
                let result1 = op1.apply(a, b)
                let result2 = op2.apply(result1, c)
                return result2
            case .multiply, .divide:
                let result1 = op2.apply(b, c)
                let result2 = op1.apply(a, result1)
                return result2
            }
        case .multiply, .divide:
            let result1 = op1.apply(a, b)
            let result2 = op2.apply(result1, c)
            return result2
        }
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(percentageCorrect: percentageCorrect)
    }
}
