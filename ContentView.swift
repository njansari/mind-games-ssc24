import SwiftUI

struct ContentView: View {
    @State private var state: GameState = .intro

    var body: some View {
        Group {
            switch state {
            case .intro:
                IntroView()
            case .select:
                GameSelectView()
            case .game(let options):
                GameView(options: options)
            case .results(let results):
                ResultsView(results: results)
            }
        }
        .environment(\.gameState, $state)
    }
}
