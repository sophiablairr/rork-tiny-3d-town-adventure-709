import SceneKit
import SwiftUI
import simd

@Observable
class GameViewModel {
    var joystickInput: CGPoint = .zero
    let interactionManager = InteractionManager()

    let scene = SCNScene()
    @ObservationIgnored var playerNode: SCNNode!
    @ObservationIgnored var cameraNode: SCNNode!
    @ObservationIgnored private var lastTime: TimeInterval = 0

    private let moveSpeed: Float = 6.0
    private let cameraOffset = SIMD3<Float>(10, 14, 12)
    private let cameraSmoothSpeed: Float = 0.1

    init() {
        setupScene()
    }

    private func setupScene() {
        // Aesthetic background and fog
        scene.background.contents = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        scene.fogStartDistance = 40
        scene.fogEndDistance = 80
        scene.fogColor = UIColor(red: 0.6, green: 0.85, blue: 1.0, alpha: 1)

        setupLighting()
        setupCamera()
        TownBuilder.buildTown(in: scene)
        createPlayer()
    }

    private func setupLighting() {
        // Soft ambient light
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 800
        ambient.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambient)

        // Balanced sun light for shadows
        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.intensity = 1200
        sun.light?.castsShadow = true
        sun.light?.shadowRadius = 4
        sun.light?.shadowSampleCount = 16
        sun.light?.shadowMapSize = CGSize(width: 4096, height: 4096)
        sun.light?.shadowColor = UIColor(white: 0, alpha: 0.3)
        sun.eulerAngles = SCNVector3(-0.8, 0.6, 0)
        scene.rootNode.addChildNode(sun)
        
        // Secondary fill light for meshes
        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .directional
        fill.light?.intensity = 400
        fill.eulerAngles = SCNVector3(0.5, -0.5, 0)
        scene.rootNode.addChildNode(fill)
    }

    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        cameraNode.position = SCNVector3(cameraOffset.x, cameraOffset.y, cameraOffset.z)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }

    private func createPlayer() {
        // CharacterLoader now handles everything: loading, scaling, and the neon fallback if file is missing.
        playerNode = CharacterLoader.load(named: "player") ?? SCNNode() 
        playerNode.position = SCNVector3(0, 0, 3)
        scene.rootNode.addChildNode(playerNode)
    }

    func update(time: TimeInterval) {
        let deltaTime: Float
        if lastTime == 0 {
            deltaTime = 1.0 / 60.0
        } else {
            deltaTime = min(Float(time - lastTime), 1.0 / 30.0)
        }
        lastTime = time

        guard let playerNode, let cameraNode else { return }

        let jx = Float(joystickInput.x)
        let jy = Float(joystickInput.y)
        let isMoving = abs(jx) > 0.05 || abs(jy) > 0.05

        if isMoving {
            let forward = simd_normalize(SIMD2<Float>(-cameraOffset.x, -cameraOffset.z))
            let right = SIMD2<Float>(-forward.y, forward.x)

            var worldMove = forward * jy + right * jx
            let moveLen = simd_length(worldMove)
            if moveLen > 1 { worldMove /= moveLen }

            let dx = worldMove.x * moveSpeed * deltaTime
            let dz = worldMove.y * moveSpeed * deltaTime

            playerNode.position.x += dx
            playerNode.position.z += dz

            let angle = atan2(dx, dz)
            playerNode.eulerAngles.y = angle

            CharacterBuilder.addWalkAnimation(to: playerNode, isMoving: true, time: time)
            
            interactionManager.checkInteractions(player: playerNode, scene: scene)

        } else {
            CharacterBuilder.addWalkAnimation(to: playerNode, isMoving: false, time: time)
            interactionManager.checkInteractions(player: playerNode, scene: scene)
        }

        // Global interaction check
        interactionManager.checkInteractions(player: playerNode, scene: scene)

        // Cinematic camera tracking
        let tX = playerNode.position.x + cameraOffset.x
        let tZ = playerNode.position.z + cameraOffset.z
        
        cameraNode.position.x += (tX - cameraNode.position.x) * cameraSmoothSpeed
        cameraNode.position.z += (tZ - cameraNode.position.z) * cameraSmoothSpeed
        cameraNode.look(at: playerNode.position)
    }
}
