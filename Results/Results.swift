import Foundation

struct GameResult: Equatable {
    struct Data {
        let percentageCorrect: Double?
        let averageTime: Double?
        let memoryLength: Int?

        init(percentageCorrect: Double? = nil, averageTime: Double? = nil, memoryLength: Int? = nil) {
            self.percentageCorrect = percentageCorrect
            self.averageTime = averageTime
            self.memoryLength = memoryLength
        }
    }

    var data: [GameOption: Data] = [:]

    static func == (lhs: GameResult, rhs: GameResult) -> Bool {
        lhs.data.keys == rhs.data.keys
    }
}
