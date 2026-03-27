import SwiftUI

struct JoystickView: View {
    @Binding var input: CGPoint

    @State private var dragOffset: CGSize = .zero

    private let baseRadius: CGFloat = 60
    private let knobRadius: CGFloat = 26

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: baseRadius * 2, height: baseRadius * 2)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.4), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.9), .white.opacity(0.6)],
                        center: .center,
                        startRadius: 0,
                        endRadius: knobRadius
                    )
                )
                .frame(width: knobRadius * 2, height: knobRadius * 2)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .offset(dragOffset)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let vector = CGSize(
                        width: value.translation.width,
                        height: value.translation.height
                    )
                    let distance = sqrt(vector.width * vector.width + vector.height * vector.height)
                    let maxDistance = baseRadius - knobRadius

                    if distance <= maxDistance {
                        dragOffset = vector
                    } else {
                        let scale = maxDistance / distance
                        dragOffset = CGSize(
                            width: vector.width * scale,
                            height: vector.height * scale
                        )
                    }

                    let normalizedX = dragOffset.width / maxDistance
                    let normalizedY = -dragOffset.height / maxDistance
                    input = CGPoint(x: normalizedX, y: normalizedY)
                }
                .onEnded { _ in
                    withAnimation(.spring(duration: 0.25)) {
                        dragOffset = .zero
                    }
                    input = .zero
                }
        )
    }
}
