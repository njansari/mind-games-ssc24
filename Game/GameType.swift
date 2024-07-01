import SwiftUI

@Observable class GameType {
    private(set) var numCorrect = 0
    private(set) var totalQuestions = 0
    private(set) var times: [TimeInterval] = []
    private(set) var numElements = 2

    var numIncorrect: Int {
        totalQuestions - numCorrect
    }

    private(set) var progress = 0

    var isAcceptingInput = false

    var isGameStarted = false
    private var completion: () -> Void

    required init(onCompletion completion: @escaping () -> Void = {}) {
        self.completion = completion
    }

    class var name: String {
        fatalError("Subclasses must override name.")
    }

    class var description: AttributedString {
        fatalError("Subclasses must override description.")
    }

    class var category: String {
        fatalError("Subclasses must override category.")
    }

    class var color: Color {
        fatalError("Subclasses must override color.")
    }

    class var averageResults: GameResult.Data {
        fatalError("Subclasses must override averageResults.")
    }

    static func formattedName() -> AttributedString {
        try! AttributedString(markdown: name)
    }

    func addPoints(_ points: Int) {
        progress += points
    }

    func addCorrect() {
        numCorrect += 1
    }

    func addQuestion(checkIncorrect: Bool = true) {
        totalQuestions += 1

        if checkIncorrect, numIncorrect >= 3 {
            progress = 100
            Sounds.bottle.play()
        }
    }

    func addTime(_ time: TimeInterval) {
        times.append(time)
    }

    func addElements(_ numElements: Int) {
        self.numElements += numElements
    }

    @discardableResult func checkIfFinished() -> Bool {
        guard progress >= 100 else { return false }

        progress = 100
        completion()
        return true
    }

    final func calculateResults() -> GameResult.Data {
        calculateResults(
            percentageCorrect: Double(numCorrect) / Double(totalQuestions),
            averageTime: times.reduce(0, +) / Double(times.count),
            memoryLength: numElements - 2
        )
    }

    func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init()
    }
}
