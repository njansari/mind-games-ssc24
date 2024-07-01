import SwiftUI

@Observable final class Objects: GameType {
    override class var name: String {
        "Did You See What I Saw?"
    }

    override class var category: String {
        "Short-Term Memory Objects"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        There are many different types of memory. One of the main ways in which they differ is the temporal scales that they operate on. This game measures your short-term memory performance with an immediate recall of a list of objects.
        \\
        \\
        You will be show a sequence of ten objects which you will need to remember **exactly**. A set of questions will follow, each with six objects but where only **one** you have seen before. Select that object to get the question right.
        """)

        if let range = str.range(of: "short-term memory") {
            str[range].foregroundColor = color
        }

        if let range = str.range(of: "one") {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .mint
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.64)
    }

    struct ObjectIcon: Equatable {
        let icon: String
        let isFlipped: Bool

        init(icon: String, isFlipped: Bool = false) {
            self.icon = icon
            self.isFlipped = isFlipped
        }
    }

    typealias ObjectIconSet = [ObjectIcon]

    let loadedObjects: [ObjectIconSet] = {
        guard let url = Bundle.main.url(forResource: "objectsList", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let contents = try? JSONSerialization.jsonObject(with: data) as? [[String]]
        else { fatalError("No objects could be loaded.") }

        return contents.map { icons in
            icons.flatMap { icon -> [ObjectIcon] in
                let suffix = ".flip"
                if icon.hasSuffix(suffix) {
                    let object = icon.replacingOccurrences(of: suffix, with: "")
                    return [.init(icon: object), .init(icon: object, isFlipped: true)]
                } else {
                    return [.init(icon: icon)]
                }
            }
        }.shuffled()
    }()

    enum GameState {
        case showing
        case accepting
    }

    var state: GameState = .showing

    var objects: [ObjectIcon] = []
    var answerOptionObjects: [ObjectIcon] = []

    var currentObjectIndex = 0

    var currentObject: ObjectIcon {
        objects[currentObjectIndex]
    }

    func generateObjects() {
        objects = loadedObjects.prefix(10).map { $0.randomElement()! }
    }

    @discardableResult func objectSelected(_ object: ObjectIcon) -> AnswerOptionState {
        guard isAcceptingInput else { return .none }

        let isCorrect = objects.contains(object)

        if isCorrect {
            addCorrect()
            Sounds.playCorrectSound()
        } else {
            Sounds.playIncorrectSound()
        }

        addPoints(10)
        addQuestion()

        isAcceptingInput = false

        Task { @MainActor in
            try await Task.sleep(for: .seconds(1))

            if !checkIfFinished() {
                await showNextObjectsGrid()
            }
        }

        return isCorrect ? .correct : .incorrect
    }

    @MainActor func startShowingObjects() async {
        state = .showing
        currentObjectIndex = 0
        objects.removeAll()

        try? await Task.sleep(for: .seconds(1))
        generateObjects()
        await showNextObject()
    }

    @MainActor func showNextObject() async {
        Sounds.playSplitSound()
        try? await Task.sleep(for: .seconds(2))

        if currentObjectIndex < objects.count - 1 {
            currentObjectIndex += 1
            await showNextObject()
        } else {
            state = .accepting
            currentObjectIndex = 0
            objects.shuffle()
            await showNextObjectsGrid()
        }
    }

    @MainActor func showNextObjectsGrid() async {
        answerOptionObjects.removeAll()

        try? await Task.sleep(for: .seconds(0.5))

        var objectsCopy = loadedObjects
        var answerOptions: [ObjectIcon] = []

        if let answerIconSetIndex = objectsCopy.firstIndex(where: { $0.contains(currentObject) }) {
            var iconSet = objectsCopy.remove(at: answerIconSetIndex)

            if let answerIconIndex = iconSet.firstIndex(of: currentObject) {
                answerOptions.append(iconSet.remove(at: answerIconIndex))
            }

            answerOptions.append(iconSet.randomElement()!)

            answerOptions.append(contentsOf: objectsCopy.map {
                var copy = $0
                copy.removeAll(where: objects.contains)
                return copy.randomElement()!
            }.prefix(4))
        }

        answerOptionObjects = answerOptions.shuffled()
        currentObjectIndex += 1
        Sounds.playSplitSound()
        isAcceptingInput = true
    }

    override func calculateResults(percentageCorrect: Double, averageTime: Double, memoryLength: Int) -> GameResult.Data {
        .init(percentageCorrect: percentageCorrect)
    }
}
