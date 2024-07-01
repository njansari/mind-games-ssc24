import SwiftUI

@Observable final class GameController {
    private(set) var results = GameResult()

    private(set) var gameOptions: [GameOption] = []
    var currentGame = -1
    var currentGameType: GameType!

    var isGameStarted = false
    var isGameEnded = false

    init(gameOptions: [GameOption]) {
        self.gameOptions = gameOptions.shuffled()
        nextGame()
    }

    var currentGameOption: GameOption? {
        currentGame >= gameOptions.count ? nil : gameOptions[currentGame]
    }

    func startGame() {
        isGameStarted = true
    }

    func nextGame() {
        if currentGame >= 0 {
            addResults()
        }

        isGameStarted = false
        currentGame += 1

        guard currentGame < gameOptions.count else {
            isGameEnded = true
            return
        }

        currentGameType = currentGameOption?.gameType.init(onCompletion: nextGame)
    }

    func addResults() {
        if let currentGameOption {
            results.data[currentGameOption] = currentGameType.calculateResults()
        }
    }
}
