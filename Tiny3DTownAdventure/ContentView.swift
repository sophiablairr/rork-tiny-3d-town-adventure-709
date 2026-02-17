import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    @State private var showDialogue = false
    @State private var dialogueText = ""

    var body: some View {
        @Bindable var vm = viewModel
        ZStack {
            SceneKitGameView(viewModel: viewModel)
                .ignoresSafeArea()

            // Interaction Button
            if vm.interactionManager.activeInteraction != .none && !showDialogue {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: handleInteraction) {
                            HStack {
                                Image(systemName: vm.interactionManager.activeInteraction == .talk ? "bubble.left.fill" : "arrow.up.circle.fill")
                                Text(vm.interactionManager.activeInteraction.prompt)
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                        }
                        .padding(.bottom, 50)
                        .padding(.trailing, 30)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Dialogue Overlay
            if showDialogue {
                DialogueOverlay(text: dialogueText) {
                    withAnimation {
                        showDialogue = false
                    }
                }
            }

            // Joystick (hide when dialogue is open to prevent moving)
            if !showDialogue {
                VStack {
                    Spacer()
                    HStack {
                        JoystickView(input: $vm.joystickInput)
                            .frame(width: 140, height: 140)
                            .padding(.leading, 24)
                            .padding(.bottom, 40)
                        Spacer()
                    }
                }
            }
        }
    }
    
    func handleInteraction() {
        switch viewModel.interactionManager.activeInteraction {
        case .talk:
            let phrases = [
                "Hello there! Isn't this town lovely?",
                "I heard there's a new neighbor moving in soon.",
                "Have you seen the fountain today? It's beautiful.",
                "I love catching bugs in the summer!"
            ]
            dialogueText = phrases.randomElement() ?? "Hello!"
            withAnimation {
                showDialogue = true
            }
        case .enter:
            print("Entering building...")
            // TODO: Implement scene switch
            dialogueText = "The door is locked right now."
            withAnimation {
                showDialogue = true
            }
        case .exit:
             print("Exiting...")
        case .none:
            break
        }
    }
}
