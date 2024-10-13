import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let imageName: String
    var isSecure: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            SwiftUI.Image(systemName: imageName)
                .foregroundColor(colorScheme == .dark ? .white : .gray)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .accentColor(colorScheme == .dark ? .white : .blue)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .accentColor(colorScheme == .dark ? .white : .blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .shadow(color: colorScheme == .dark ? Color.clear : Color.gray.opacity(0.2), radius: 5, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// 为了设置占位符文本的颜色，我们需要创建一个自定义的 ViewModifier
struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    @Environment(\.colorScheme) var colorScheme

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                    .padding(.horizontal, 4)
            }
            content
        }
    }
}

extension View {
    func placeholder(_ text: String) -> some View {
        self.modifier(PlaceholderStyle(showPlaceHolder: true, placeholder: text))
    }
}
