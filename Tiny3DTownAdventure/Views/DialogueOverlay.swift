import SwiftUI

struct DialogueOverlay: View {
    let text: String
    let onAdvance: () -> Void
    
    @State private var displayedText: String = ""
    @State private var charIndex: Int = 0
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: onAdvance) {
                HStack(alignment: .top, spacing: 16) {
                    // NPC Portrait (placeholder)
                    Circle()
                        .fill(Color.orange.opacity(0.8))
                        .frame(width: 60, height: 60)
                        .overlay(Text("NPC").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Villager")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.1))
                        
                        Text(displayedText)
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.98, green: 0.95, blue: 0.88))
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(red: 0.85, green: 0.75, blue: 0.6), lineWidth: 3)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onReceive(timer) { _ in
            if charIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: charIndex)
                displayedText.append(text[index])
                charIndex += 1
            }
        }
        .onChange(of: text) { _, newValue in
            // Reset typing effect when text changes
            displayedText = ""
            charIndex = 0
        }
    }
}
