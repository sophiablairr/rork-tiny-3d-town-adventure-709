import SwiftUI
import SceneKit

struct SceneKitGameView: UIViewRepresentable {
    let viewModel: GameViewModel

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = viewModel.scene
        scnView.pointOfView = viewModel.cameraNode
        scnView.delegate = context.coordinator
        scnView.isPlaying = true
        scnView.allowsCameraControl = false
        scnView.antialiasingMode = .multisampling4X
        scnView.backgroundColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        scnView.preferredFramesPerSecond = 60
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, @preconcurrency SCNSceneRendererDelegate {
        let viewModel: GameViewModel

        init(viewModel: GameViewModel) {
            self.viewModel = viewModel
        }

        func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
            viewModel.update(time: time)
        }
    }
}
