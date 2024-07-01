import SwiftUI

struct GameAreaSizeEnvironmentKey: EnvironmentKey {
    static var defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var gameAreaSize: CGSize {
        get { self[GameAreaSizeEnvironmentKey.self] }
        set { self[GameAreaSizeEnvironmentKey.self] = newValue }
    }
}

struct GameView: View {
    @Environment(\.gameState) private var gameState

    @State private var game: GameController

    init(options: [GameOption]) {
        game = GameController(gameOptions: options)
    }

    var progressBar: some View {
        ProgressBar(
            progress: Double(game.currentGameType.progress) / 100,
            numSegments: game.gameOptions.count,
            currentSegment: game.currentGame,
            numIncorrect: game.currentGameType.numIncorrect
        ) {
            game.gameOptions[$0].gameType.color
        }
        .onLongPressGesture(minimumDuration: 2, perform: game.nextGame)
        .padding()
        .padding(.horizontal)
    }

    var intro: some View {
        VStack(spacing: 20) {
            if let gameType = game.currentGameOption?.gameType {
                Text(gameType.formattedName())
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundStyle(gameType.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                VStack {
                    Text(gameType.description)
                }
                .font(.title3)
            }

            Button(action: game.startGame) {
                Text("Start")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .padding()
        }
        .multilineTextAlignment(.center)
        .frame(width: 600)
    }

    var finish: some View {
        VStack(spacing: 20) {
            let endings = [
                "And that's the end of that!",
                "And that's all for now!",
                "Finished, done, and dusted!",
                "That's all we have time for, folks!",
                "And that's a wrap on this!",
                "And thus, it draws to a close!",
                "And that's all there is to say about that!",
                "That's the last of it, all done!"
            ]

            Text(endings.randomElement()!)
                .font(.largeTitle.bold())
                .foregroundStyle(.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text("Well done on getting through it – must have been tough. So, does your brain hurt? You feeling okay? Anyways, it's time to get your results and see how you really did.")
                .font(.title2)

            Text("Your scores for each game have been calculated and complied into single values. You can swipe through each game to see your overall score and how it compares to an average. Good luck!")
                .font(.title3)

            Button {
                withAnimation(.easeInOut(duration: 2)) {
                    gameState.wrappedValue = .results(game.results)
                }
            } label: {
                Text("See Results")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .padding()
        }
        .multilineTextAlignment(.center)
        .frame(width: 600)
    }

    @ViewBuilder var header: some View {
        switch game.currentGameOption {
        case .reactions:
            ReactionsHeader(game.currentGameType)
        case .detection:
            DetectionHeader(game.currentGameType)
        default:
            EmptyView()
        }
    }

    @ViewBuilder var mainContent: some View {
        switch game.currentGameOption {
        case .reactions:
            ReactionsView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .squares:
            SquaresView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .objects:
            ObjectsView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .numbers:
            NumbersView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .towers:
            TowersView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .colors:
            ColorsView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .rotation:
            RotationView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .detection:
            DetectionView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .definitions:
            DefinitionsView(game.currentGameType, isGameStarted: game.isGameStarted)
        case .maths:
            MathsView(game.currentGameType, isGameStarted: game.isGameStarted)
        default:
            EmptyView()
        }
    }

    var gameArea: some View {
        GeometryReader { geometry in
            let gameSize = geometry.size.applying(.init(scaleX: 0.8, y: 0.8))

            VStack {
                header

                ZStack {
                    mainContent
                }
                .frame(width: gameSize.width, height: gameSize.height)
                .background(.background.shadow(.inner(color: .primary.opacity(0.5), radius: 10)), in: .rect(cornerRadius: 20))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.gameAreaSize, gameSize)
        }
    }

    var body: some View {
        VStack {
            progressBar

            Spacer()

            if game.isGameEnded {
                finish
                    .transition(.scale.combined(with: .opacity.animation(.smooth)))
            } else if game.isGameStarted {
                gameArea
                    .transition(.scale.combined(with: .opacity.animation(.smooth)))
            } else {
                intro
                    .transition(.scale.combined(with: .opacity.animation(.smooth)))
            }

            Spacer()
        }
        .tint(game.currentGameOption?.gameType.color)
        .animation(.easeInOut(duration: 2), value: game.currentGame)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom),
            removal: .opacity.animation(.smooth(duration: 0.2))
        ))
    }
}

#Preview {
    GameView(options: [.maths])
}
