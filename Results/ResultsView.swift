import SwiftUI

struct AnimatingText<Content: View>: Animatable, View {
    var value: Double
    @ViewBuilder let content: (Double) -> Content

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        content(value)
    }
}

struct ResultsView: View {
    @Environment(\.gameState) private var gameState

    @State private var scrollPosition: Int? = 0
    @State private var appearedOptions: [Bool]

    let results: GameResult

    init(results: GameResult) {
        self.results = results
        _appearedOptions = State(initialValue: .init(repeating: false, count: results.data.count))
    }

    var scrollingGameResults: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                Color.clear
                    .containerRelativeFrame(.horizontal, count: 3, spacing: 0)
                    .id(0)

                ForEach(Array(results.data.enumerated()), id: \.offset) { offset, option in
                    GameResultView(offset: offset, option: option, scrollPosition: scrollPosition, appearedOptions: appearedOptions)
                        .id(offset + 1)
                }

                Color.clear
                    .containerRelativeFrame(.horizontal, count: 3, spacing: 0)
            }
            .scrollTargetLayout()
        }
        .multilineTextAlignment(.center)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, 20)
        .onChange(of: scrollPosition, initial: true) { _, newValue in
            if let newValue, 0..<results.data.count ~= newValue {
                appearedOptions[newValue] = true
            }
        }
    }

    var scrollButtons: some View {
        HStack {
            Button {
                withAnimation(.easeOut) {
                    if let scrollPosition {
                        self.scrollPosition = scrollPosition - 1
                    } else {
                        scrollPosition = 0
                    }
                }
            } label: {
                Image(systemName: "chevron.compact.backward")
                    .font(.system(size: 72, weight: .bold))
            }
            .disabled(scrollPosition == 0)

            Spacer()

            Button {
                withAnimation(.easeOut) {
                    if let scrollPosition {
                        self.scrollPosition = scrollPosition + 1
                    } else {
                        scrollPosition = results.data.count - 1
                    }
                }
            } label: {
                Image(systemName: "chevron.compact.forward")
                    .font(.system(size: 72, weight: .bold))
            }
            .disabled(scrollPosition == results.data.count - 1)
        }
        .padding()
    }

    var startAgainButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 2)) {
                gameState.wrappedValue = .intro
            }
        } label: {
            Text("Start All Over Again")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 20))
        .controlSize(.large)
        .transition(.push(from: .bottom))
    }

    var body: some View {
        ZStack {
            VStack {
                scrollingGameResults

                Text("Averages have been calculated based on results collected from students aged 19-22 years old. Factors, such as age, can affect your mental abilities so don't be too disheartened if you score below average.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding()

                startAgainButton
            }
            .padding(.horizontal)
            .padding()

            scrollButtons
        }
    }
}

#Preview {
    ResultsView(results: .init(data: [
        .colors: .init(percentageCorrect: 0.8, averageTime: 1.2),
        .rotation: .init(percentageCorrect: 0.5),
        .squares: .init(percentageCorrect: 0.95, memoryLength: 6),
        .definitions: .init(percentageCorrect: 0.65),
        .towers: .init(percentageCorrect: 1),
        .reactions: .init(averageTime: 0.55)
    ]))
}
