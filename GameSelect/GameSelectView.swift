import SwiftUI

precedencegroup ExponentiativePrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiativePrecedence

public func ** <N: BinaryInteger>(base: N, power: N) -> N {
    N(pow(Double(base), Double(power)))
}

struct GameSelectView: View {
    @Environment(\.gameState) private var gameState

    @State private var isShowing = false

    @State private var isShowingHeaders = false
    @State private var isFullyVisisble = false

    @State private var selectedGameOptions: [GameOption] = []

    let gridIcons = ["topleft", "topmiddle", "topright", "middleleft", "middle", "middleright", "bottomleft", "bottommiddle", "bottomright"]
    let objectsIcons = ["chair", "hare", "tortoise", "lamp.floor", "car", "cat", "tree", "hand.wave", "eye"]

    var headerText: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    Text("Welcome to the Game Room")
                        .font(.system(size: geometry.size.height / 7, weight: .bold))
                        .foregroundStyle(.tint)

                    Text("Let's start by selecting some game types from around here.")
                        .font(.system(size: geometry.size.height / 12, weight: .semibold))
                }
                .padding(.bottom, 2)
                .background()

                if isFullyVisisble {
                    Divider()
                        .padding(.bottom, 6)

                    VStack(spacing: 10) {
                        Text("Each game is designed to test some part of your brain, so **prepare yourself**. They all start with a brief description of what they test and how to complete them. You will also be able to see how you are doing using the **progress bar** at the top.")
                            .lineLimit(3)

                        Text("One more thing… as this is a game, it's **three strikes and you're out**: three incorrect actions and the current game ends. You can see your strikes in the progress bar.")
                            .lineLimit(2)
                    }
                    .font(.system(size: geometry.size.height / 15.5))
                    .zIndex(-1)
                    .transition(.scale(0.5, anchor: .top).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .minimumScaleFactor(0.5)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .transition(.scale(0.8).combined(with: .opacity))
    }

    var reactionsCard: some View {
        GameOptionCard(gameType: GameOption.reactions.gameType, isSelected: gameOptionSelectionBinding(.reactions)) { date in
            Image(systemName: "target")
                .symbolEffect(.bounce.down, value: date)
        }
    }

    var squaresCard: some View {
        GameOptionCard(gameType: GameOption.squares.gameType, isSelected: gameOptionSelectionBinding(.squares)) { date in
            Image(systemName: "square.grid.3x3.\(gridIcons.randomElement()!).filled")
                .symbolEffect(.pulse.wholeSymbol, value: date)
                .animation(.smooth.delay(1), value: date)
        }
    }

    var objectsCard: some View {
        GameOptionCard(gameType: GameOption.objects.gameType, isSelected: gameOptionSelectionBinding(.objects)) { _ in
            Image(systemName: objectsIcons.randomElement()!)
                .contentTransition(.symbolEffect(.replace.downUp.wholeSymbol))
        }
    }

    var definitionsCard: some View {
        GameOptionCard(gameType: GameOption.definitions.gameType, isSelected: gameOptionSelectionBinding(.definitions)) { date in
            FlippingDictionary(trigger: date)
        }
    }

    var numbersCard: some View {
        GameOptionCard(gameType: GameOption.numbers.gameType, isSelected: gameOptionSelectionBinding(.numbers)) { _ in
            let num = Int.random(in: 1...4)

            let lowerBound = 10 ** num
            let upperBound = 10 ** (num + 1) - 1
            let value = Int.random(in: lowerBound...upperBound)

            Text(value, format: .number.grouping(.never))
                .fontDesign(.rounded)
                .contentTransition(.numericText())
                .animation(.bouncy, value: value)
        }
    }

    var detectionCard: some View {
        GameOptionCard(gameType: GameOption.detection.gameType, isSelected: gameOptionSelectionBinding(.detection)) { date in
            TargetScope(trigger: date)
        }
    }

    var mathsCard: some View {
        GameOptionCard(gameType: GameOption.maths.gameType, isSelected: gameOptionSelectionBinding(.maths)) { date in
            LaunchingOperators(trigger: date)
        }
    }

    var colorsCard: some View {
        GameOptionCard(gameType: GameOption.colors.gameType, isSelected: gameOptionSelectionBinding(.colors)) { date in
            Image(systemName: "paintpalette")
                .symbolEffect(.bounce, value: date)
        }
    }

    var towersCard: some View {
        GameOptionCard(gameType: GameOption.towers.gameType, isSelected: gameOptionSelectionBinding(.towers)) { date in
            TowerDisks(trigger: date)
        }
    }

    var rotationCard: some View {
        GameOptionCard(gameType: GameOption.rotation.gameType, isSelected: gameOptionSelectionBinding(.rotation)) { date in
            RotatingBox(trigger: date)
        }
    }

    var optionsGrid: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                reactionsCard
                colorsCard
                rotationCard
                objectsCard
            }

            GridRow {
                towersCard

                Group {
                    if isShowingHeaders {
                        headerText
                    } else {
                        Color.clear
                    }
                }
                .gridCellUnsizedAxes([.horizontal, .vertical])
                .gridCellColumns(2)

                detectionCard
            }

            GridRow {
                definitionsCard
                mathsCard
                numbersCard
                squaresCard
            }
        }
        .padding(.vertical, 40)
    }

    @ViewBuilder var startButton: some View {
        if isShowingHeaders {
            Button {
                withAnimation(.timingCurve(0.5, 0, 0.25, 1, duration: 4)) {
                    gameState.wrappedValue = .game(selectedGameOptions)
                }
            } label: {
                Text("Begin")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 20))
            .controlSize(.large)
            .disabled(selectedGameOptions.count < 1)
            .transition(.push(from: .bottom))
        } else {
            Button(" ", action: {})
                .controlSize(.large)
                .hidden()
        }
    }

    var body: some View {
        VStack {
            if isShowing {
                optionsGrid
                    .transition(.scale.combined(with: .opacity))
            }
            
            startButton
        }
        .padding(.horizontal)
        .padding()
        .allowsHitTesting(isFullyVisisble)
        .transition(.move(edge: .top).combined(with: .opacity.animation(.smooth(duration: 2))))
        .task {
            try? await Task.sleep(for: .seconds(2))

            withAnimation(.smooth(duration: 5)) {
                isShowing = true
            }

            try? await Task.sleep(for: .seconds(3))

            withAnimation(.easeOut(duration: 2)) {
                isShowingHeaders = true
            }

            try? await Task.sleep(for: .seconds(2))

            withAnimation(.snappy(duration: 0.8)) {
                isFullyVisisble = true
            }
        }
    }

    func gameOptionSelectionBinding(_ gameOption: GameOption) -> Binding<Bool> {
        Binding {
            selectedGameOptions.contains(gameOption)
        } set: { newValue in
            withAnimation(.smooth(duration: 0.2)) {
                if newValue {
                    selectedGameOptions.append(gameOption)
                } else {
                    if let index = selectedGameOptions.firstIndex(of: gameOption) {
                        selectedGameOptions.remove(at: index)
                    }
                }
            }
        }
    }
}

#Preview {
    GameSelectView()
}
