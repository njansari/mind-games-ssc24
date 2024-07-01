import SwiftUI

@Observable final class Definitions: GameType {
    override class var name: String {
        "I Know What That Means"
    }

    override class var category: String {
        "Verbal Comprehension"
    }

    override class var description: AttributedString {
        var str = try! AttributedString(markdown: """
        This game measures the diversity of your 'lexicon', that is, your internal library of words. People tend to keep acquiring words throughout their lifespan. Therefore, older adults often perform well. The number of words that we learn through our lives is very much dependent on the number of years spent in education, as well as the types of jobs and pastimes that we engage in.
        \\
        \\
        This is a simple game where you will be shown a word and need to choose the **corresponding definition** from the list of options to get the question right.
        """)

        if let range = str.range(of: "corresponding definition") {
            str[range].underlineStyle = .single
        }

        return str
    }

    override class var color: Color {
        .purple
    }

    override class var averageResults: GameResult.Data {
        .init(percentageCorrect: 0.67)
    }

    struct DefinitionQuestion: Decodable {
        let word: String
        let definition: String
    }

    let loadedQuestions: [DefinitionQuestion] = {
        guard let url = Bundle.main.url(forResource: "wordDefinitions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let contents = try? JSONDecoder().decode([DefinitionQuestion].self, from: data)
        else { fatalError("No definitions could be loaded.") }

        return contents.shuffled()
    }()

    var currentQuestion: DefinitionQuestion?
    var answerOptions: [String] = []

    @MainActor func nextQuestion() async {
        currentQuestion = nil

        try? await Task.sleep(for: .seconds(1))

        Sounds.playSplitSound()

        currentQuestion = loadedQuestions[totalQuestions]

        answerOptions = {
            guard let currentQuestion else { return [] }

            var answerOptions: [String] = []

            var questionsCopy = loadedQuestions

            if let index = questionsCopy.firstIndex(where: { $0.word == currentQuestion.word }) {
                questionsCopy.remove(at: index)
            }

            answerOptions.append(currentQuestion.definition)
            answerOptions.append(contentsOf: questionsCopy.map(\.definition).shuffled().prefix(3))

            return answerOptions.shuffled()
        }()

        isAcceptingInput = true
    }

    @discardableResult func definitionSelected(_ definition: String) -> AnswerOptionState {
        guard isAcceptingInput else { return .none }
        isAcceptingInput = false

        let isCorrect = definition == currentQuestion?.definition

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
