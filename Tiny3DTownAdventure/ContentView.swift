import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        @Bindable var vm = viewModel
        ZStack {
            SceneKitGameView(viewModel: viewModel)
                .ignoresSafeArea()

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
