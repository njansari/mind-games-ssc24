//
//  PlaceholderIcon.swift
//  Mind Games
//

import SwiftUI

struct PlaceholderIcon: View {
    var body: some View {
        Image(systemName: "brain")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(.tertiary)
    }
}

#Preview {
    PlaceholderIcon()
}
