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

    private let moveSpeed: Float = 7.0
    private let cameraOffset = SIMD3<Float>(9, 13, 11)
    private let cameraSmoothSpeed: Float = 0.08

    init() {
        setupScene()
    }

    private func setupScene() {
        scene.background.contents = UIColor(red: 0.45, green: 0.75, blue: 0.95, alpha: 1.0)
        scene.fogStartDistance = 30
        scene.fogEndDistance = 65
        scene.fogColor = UIColor(red: 0.6, green: 0.8, blue: 0.95, alpha: 1)

        setupLighting()
        setupCamera()
        TownBuilder.buildTown(in: scene)
        createPlayer()
    }

    private func setupLighting() {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.intensity = 600
        ambientLight.light!.color = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1)
        scene.rootNode.addChildNode(ambientLight)

        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light!.type = .directional
        sunLight.light!.intensity = 1100
        sunLight.light!.color = UIColor(red: 1.0, green: 0.96, blue: 0.88, alpha: 1.0)
        sunLight.light!.castsShadow = true
        sunLight.light!.shadowRadius = 3
        sunLight.light!.shadowSampleCount = 8
        sunLight.light!.shadowMapSize = CGSize(width: 2048, height: 2048)
        sunLight.light!.shadowColor = UIColor(white: 0, alpha: 0.25)
        sunLight.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4, 0)
        scene.rootNode.addChildNode(sunLight)
    }

    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.fieldOfView = 50
        cameraNode.camera!.zNear = 0.1
        cameraNode.camera!.zFar = 150
        cameraNode.position = SCNVector3(cameraOffset.x, cameraOffset.y, cameraOffset.z)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }

    private func createPlayer() {
        // Try to load user's model first
        if let loadedNode = ResourceManager.shared.loadCharacter(named: "character") {
            playerNode = loadedNode
            playerNode.scale = SCNVector3(0.5, 0.5, 0.5) // Adjust scale as needed
            // Ensure player is at correct starting position
            playerNode.position = SCNVector3(0, 0, 3)
            playerNode.name = "Player"
            scene.rootNode.addChildNode(playerNode)
            return
        }

        // Fallback to procedural player if no model found
        print("Using fallback player")
        playerNode = SCNNode()
        playerNode.position = SCNVector3(0, 0, 3)
        playerNode.name = "Player"

        let body = SCNCapsule(capRadius: 0.22, height: 0.7)
        body.firstMaterial?.diffuse.contents = UIColor(red: 0.32, green: 0.62, blue: 0.42, alpha: 1)
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(0, 0.6, 0)
        playerNode.addChildNode(bodyNode)

        let head = SCNSphere(radius: 0.24)
        head.firstMaterial?.diffuse.contents = UIColor(red: 0.96, green: 0.84, blue: 0.72, alpha: 1)
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 1.2, 0)
        playerNode.addChildNode(headNode)
        
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
            if moveLen > 1 {
                worldMove /= moveLen
            }

            let dx = worldMove.x * moveSpeed * deltaTime
            let dz = worldMove.y * moveSpeed * deltaTime

            var newX = playerNode.position.x + dx
            var newZ = playerNode.position.z + dz
            newX = max(-11, min(22, newX))
            newZ = max(-15, min(20, newZ))

            playerNode.position.x = newX
            playerNode.position.z = newZ

            let angle = atan2(dx, dz)
            playerNode.eulerAngles.y = angle

            let bob = sin(Float(time) * 14) * 0.035
            playerNode.position.y = abs(bob)
            
            interactionManager.checkInteractions(player: playerNode, scene: scene)

        } else {
            playerNode.position.y = 0
            interactionManager.checkInteractions(player: playerNode, scene: scene)
        }

        let targetX = playerNode.position.x + cameraOffset.x
        let targetZ = playerNode.position.z + cameraOffset.z

        cameraNode.position.x += (targetX - cameraNode.position.x) * cameraSmoothSpeed
        cameraNode.position.z += (targetZ - cameraNode.position.z) * cameraSmoothSpeed
        cameraNode.position.y = cameraOffset.y

        cameraNode.look(at: playerNode.position)
    }
}
