import SwiftUI

struct AdaptiveBlurView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if colorScheme == .dark {
            Color.black.opacity(1)
        } else {
            Color.white.opacity(1)
        }
    }
}