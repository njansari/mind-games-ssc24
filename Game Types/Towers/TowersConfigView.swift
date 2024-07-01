import SwiftUI

struct TowersConfigView: View {
    let config: Towers.TowerConfig

    let colors: [Color] = [.red, .green, .blue]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(config.indices, id: \.self) { i in
                    ZStack(alignment: .bottom) {
                        UnevenRoundedRectangle(topLeadingRadius: 10, topTrailingRadius: 10)
                            .frame(width: 10, height: 100)

                        VStack(spacing: 0) {
                            ForEach(config[i], id: \.self) { j in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colors[j - 1])
                                    .frame(width: 36 * Double(j), height: 25)
                            }
                        }
                    }
                    .frame(width: 110)
                }
            }

            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 5, bottomTrailingRadius: 5, topTrailingRadius: 10)
                .frame(width: 360, height: 15)
        }
    }
}

#Preview {
    TowersConfigView(config: [[3], [2], [1]])
}
