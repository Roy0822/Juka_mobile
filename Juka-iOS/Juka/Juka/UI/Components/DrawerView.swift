import SwiftUI

enum DrawerState {
    case collapsed
    case halfExpanded
    case fullyExpanded
}

struct DrawerView<Content: View>: View {
    @Binding var state: DrawerState
    @GestureState private var translation: CGFloat = 0
    @State private var contentSize: CGSize = .zero
    
    let minHeight: CGFloat
    let halfHeight: CGFloat
    let maxHeight: CGFloat
    let content: Content
    
    init(state: Binding<DrawerState>, 
         minHeight: CGFloat, 
         halfHeight: CGFloat,
         maxHeight: CGFloat,
         @ViewBuilder content: () -> Content) {
        self._state = state
        self.minHeight = minHeight
        self.halfHeight = halfHeight
        self.maxHeight = maxHeight
        self.content = content()
    }
    
    private var offset: CGFloat {
        switch state {
        case .collapsed:
            return maxHeight - minHeight
        case .halfExpanded:
            return maxHeight - min(halfHeight, contentSize.height + 60) // Add padding for handle
        case .fullyExpanded:
            return 0
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Handle area
                VStack(spacing: 4) {
                    // Handle bar
                    HandleBar()
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    
                    Text("附近揪團")
                        .font(AppStyles.Typography.subtitle)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)
                        .padding(.horizontal)
                }
                .background(Color(.systemBackground).opacity(0.01)) // Invisible background for taps
                .contentShape(Rectangle()) // Make whole area tappable
                .onTapGesture {
                    withAnimation(AppStyles.animation) {
                        toggleState()
                    }
                }
                
                // Content with size reader
                content
                    .frame(maxWidth: .infinity)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: SizePreferenceKey.self, value: geo.size)
                                .onPreferenceChange(SizePreferenceKey.self) { size in
                                    self.contentSize = size
                                }
                        }
                    )
            }
            .frame(width: geometry.size.width, height: maxHeight)
            .background(
                Rectangle()
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .stroke(Color.secondary.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .cornerRadius(AppStyles.largeCornerRadius, corners: [.topLeft, .topRight])
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(0, offset + self.translation))
            .shadow(
                color: AppStyles.shadowColor,
                radius: AppStyles.shadowRadius,
                x: AppStyles.shadowX,
                y: -AppStyles.shadowY
            )
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let threshold = 50.0
                        let dragDirection = value.translation.height
                        let velocity = value.predictedEndLocation.y - value.location.y
                        
                        withAnimation(AppStyles.animation) {
                            if dragDirection > threshold || velocity > threshold {
                                // Dragging down
                                switch state {
                                case .fullyExpanded:
                                    state = .halfExpanded
                                case .halfExpanded:
                                    state = .collapsed
                                case .collapsed:
                                    break
                                }
                            } else if dragDirection < -threshold || velocity < -threshold {
                                // Dragging up
                                switch state {
                                case .collapsed:
                                    state = .halfExpanded
                                case .halfExpanded:
                                    state = .fullyExpanded
                                case .fullyExpanded:
                                    break
                                }
                            }
                        }
                    }
            )
        }
    }
    
    private func toggleState() {
        switch state {
        case .collapsed:
            state = .halfExpanded
        case .halfExpanded:
            state = .fullyExpanded
        case .fullyExpanded:
            state = .halfExpanded
        }
    }
}

// Preference key to measure content size
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct HandleBar: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 40, height: 6)
            .foregroundColor(Color.gray.opacity(0.5))
    }
}

// Extension to add rounded corners to specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        
        DrawerView(
            state: .constant(.halfExpanded),
            minHeight: 120,
            halfHeight: 300,
            maxHeight: 600
        ) {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<10) { index in
                        Text("Item \(index)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
} 