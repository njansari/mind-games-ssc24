import SwiftUI

struct GameOptionCard<Content: View>: View {
    struct AnimatingContent: Equatable, View {
        @ViewBuilder let content: (Date) -> Content

        var body: some View {
            TimelineView(.periodic(from: .now.advanced(by: .random(in: 0...2)), by: 2)) { context in
                content(context.date)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(5)
            }
            .frame(height: 80)
        }

        static func == (lhs: AnimatingContent, rhs: AnimatingContent) -> Bool {
            true
        }
    }

    let gameType: GameType.Type
    @Binding var isSelected: Bool
    @ViewBuilder let content: (Date) -> Content

    var mainContent: some View {
        VStack(spacing: 15) {
            AnimatingContent(content: content)
                .equatable()

            Text(gameType.formattedName())
                .font(.title2.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .multilineTextAlignment(.center)
        .padding()
    }


    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(gameType.color.gradient)

            mainContent
        }
        .onTapGesture(perform: toggleSelection)
        .padding(6)
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(gameType.color, lineWidth: 5)
            }
        }
    }

    func toggleSelection() {
        isSelected.toggle()
    }
}

#Preview {
    GameOptionCard(gameType: Reactions.self, isSelected: .constant(true)) { _ in
        Image(systemName: "hand.wave")
    }
    .frame(width: 300, height: 200)
}
