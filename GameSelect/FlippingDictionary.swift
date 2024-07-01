import SwiftUI

struct FlippingDictionary: View {
    @State private var flip = 0.0

    let trigger: Date

    let icon = ["", "ar", "he", "th", "zh", "ja", "ko", "hi"].randomElement()!

    var body: some View {
        Image(systemName: "character.book.closed\(icon.isEmpty ? icon : ".\(icon)")")
            .contentTransition(.symbolEffect(.replace))
            .rotation3DEffect(.degrees(flip), axis: (0, 1, 0))
            .onChange(of: trigger) {
                withAnimation(.smooth(duration: 1)) {
                    if .random() {
                        flip += 360
                    } else {
                        flip -= 360
                    }
                } completion: {
                    flip = 0
                }
            }
    }
}

#Preview {
    TimelineView(.periodic(from: .now, by: 2)) { context in
        FlippingDictionary(trigger: context.date)
            .font(.system(size: 56))
    }
}
