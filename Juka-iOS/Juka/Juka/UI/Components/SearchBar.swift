import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            
            TextField("搜尋", text: $text)
                .padding(4)
                .background(Color.clear)
                .onTapGesture {
                    isEditing = true
                }
            
            if isEditing && !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 8)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack {
        SearchBar(text: .constant(""))
        SearchBar(text: .constant("Coffee"))
    }
    .padding()
} 