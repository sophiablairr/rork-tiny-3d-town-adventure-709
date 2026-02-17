import SceneKit

enum CharacterBuilder {

    static func buildPlayer() -> SCNNode {
        let root = SCNNode()
        root.name = "Player"

        // -- Legs --
        let leftLeg = makeLimb(width: 0.18, height: 0.45, depth: 0.18, color: UIColor(red: 0.25, green: 0.35, blue: 0.6, alpha: 1))
        leftLeg.position = SCNVector3(-0.14, 0.225, 0)
        leftLeg.name = "LeftLeg"
        root.addChildNode(leftLeg)

        let rightLeg = makeLimb(width: 0.18, height: 0.45, depth: 0.18, color: UIColor(red: 0.25, green: 0.35, blue: 0.6, alpha: 1))
        rightLeg.position = SCNVector3(0.14, 0.225, 0)
        rightLeg.name = "RightLeg"
        root.addChildNode(rightLeg)

        // -- Shoes --
        let leftShoe = makeBox(width: 0.22, height: 0.1, depth: 0.28, radius: 0.04, color: UIColor(red: 0.45, green: 0.25, blue: 0.15, alpha: 1))
        leftShoe.position = SCNVector3(-0.14, 0.05, 0.03)
        root.addChildNode(leftShoe)

        let rightShoe = makeBox(width: 0.22, height: 0.1, depth: 0.28, radius: 0.04, color: UIColor(red: 0.45, green: 0.25, blue: 0.15, alpha: 1))
        rightShoe.position = SCNVector3(0.14, 0.05, 0.03)
        root.addChildNode(rightShoe)

        // -- Torso --
        let torso = makeBox(width: 0.55, height: 0.55, depth: 0.35, radius: 0.06, color: UIColor(red: 0.92, green: 0.42, blue: 0.32, alpha: 1))
        torso.position = SCNVector3(0, 0.72, 0)
        root.addChildNode(torso)

        // -- Overall straps --
        let strapL = makeBox(width: 0.08, height: 0.2, depth: 0.36, radius: 0.02, color: UIColor(red: 0.28, green: 0.38, blue: 0.62, alpha: 1))
        strapL.position = SCNVector3(-0.16, 0.82, 0)
        root.addChildNode(strapL)

        let strapR = makeBox(width: 0.08, height: 0.2, depth: 0.36, radius: 0.02, color: UIColor(red: 0.28, green: 0.38, blue: 0.62, alpha: 1))
        strapR.position = SCNVector3(0.16, 0.82, 0)
        root.addChildNode(strapR)

        // -- Arms --
        let leftArm = makeLimb(width: 0.15, height: 0.4, depth: 0.15, color: UIColor(red: 0.96, green: 0.82, blue: 0.7, alpha: 1))
        leftArm.position = SCNVector3(-0.4, 0.68, 0)
        leftArm.name = "LeftArm"
        root.addChildNode(leftArm)

        let rightArm = makeLimb(width: 0.15, height: 0.4, depth: 0.15, color: UIColor(red: 0.96, green: 0.82, blue: 0.7, alpha: 1))
        rightArm.position = SCNVector3(0.4, 0.68, 0)
        rightArm.name = "RightArm"
        root.addChildNode(rightArm)

        // -- Head --
        let head = SCNNode(geometry: {
            let sphere = SCNSphere(radius: 0.32)
            sphere.firstMaterial = makeMaterial(color: UIColor(red: 0.96, green: 0.84, blue: 0.72, alpha: 1))
            return sphere
        }())
        head.position = SCNVector3(0, 1.25, 0)
        root.addChildNode(head)

        // -- Eyes --
        let leftEye = makeEye()
        leftEye.position = SCNVector3(-0.1, 1.28, 0.28)
        root.addChildNode(leftEye)

        let rightEye = makeEye()
        rightEye.position = SCNVector3(0.1, 1.28, 0.28)
        root.addChildNode(rightEye)

        // -- Eye pupils --
        let leftPupil = makePupil()
        leftPupil.position = SCNVector3(-0.1, 1.28, 0.31)
        root.addChildNode(leftPupil)

        let rightPupil = makePupil()
        rightPupil.position = SCNVector3(0.1, 1.28, 0.31)
        root.addChildNode(rightPupil)

        // -- Mouth (little smile) --
        let mouth = SCNNode(geometry: {
            let torus = SCNTorus(ringRadius: 0.06, pipeRadius: 0.015)
            torus.firstMaterial = makeMaterial(color: UIColor(red: 0.75, green: 0.35, blue: 0.3, alpha: 1))
            return torus
        }())
        mouth.position = SCNVector3(0, 1.18, 0.28)
        mouth.eulerAngles.x = Float.pi * 0.15
        mouth.scale = SCNVector3(1, 1, 0.5)
        root.addChildNode(mouth)

        // -- Hair --
        let hair = SCNNode(geometry: {
            let sphere = SCNSphere(radius: 0.34)
            sphere.firstMaterial = makeMaterial(color: UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1))
            return sphere
        }())
        hair.position = SCNVector3(0, 1.3, -0.04)
        hair.scale = SCNVector3(1.05, 0.9, 1.0)
        root.addChildNode(hair)

        // -- Hat --
        let hatBrim = SCNNode(geometry: {
            let cyl = SCNCylinder(radius: 0.42, height: 0.05)
            cyl.firstMaterial = makeMaterial(color: UIColor(red: 0.92, green: 0.78, blue: 0.45, alpha: 1))
            return cyl
        }())
        hatBrim.position = SCNVector3(0, 1.5, 0)
        root.addChildNode(hatBrim)

        let hatTop = SCNNode(geometry: {
            let cyl = SCNCylinder(radius: 0.28, height: 0.25)
            cyl.firstMaterial = makeMaterial(color: UIColor(red: 0.92, green: 0.78, blue: 0.45, alpha: 1))
            return cyl
        }())
        hatTop.position = SCNVector3(0, 1.65, 0)
        root.addChildNode(hatTop)

        let hatBand = SCNNode(geometry: {
            let cyl = SCNCylinder(radius: 0.285, height: 0.06)
            cyl.firstMaterial = makeMaterial(color: UIColor(red: 0.82, green: 0.35, blue: 0.28, alpha: 1))
            return cyl
        }())
        hatBand.position = SCNVector3(0, 1.55, 0)
        root.addChildNode(hatBand)

        // Shadow disc under feet
        let shadow = SCNNode(geometry: {
            let cyl = SCNCylinder(radius: 0.35, height: 0.01)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor(white: 0, alpha: 0.18)
            mat.lightingModel = .constant
            mat.writesToDepthBuffer = false
            cyl.firstMaterial = mat
            return cyl
        }())
        shadow.position = SCNVector3(0, 0.005, 0)
        shadow.castsShadow = false
        root.addChildNode(shadow)

        root.castsShadow = true
        return root
    }

    // MARK: - Walk Animation

    static func addWalkAnimation(to playerNode: SCNNode, isMoving: Bool, time: TimeInterval) {
        let speed: Float = 10
        let phase = Float(time) * speed
        
        let leftLeg = playerNode.childNode(withName: "LeftLeg", recursively: true)
        let rightLeg = playerNode.childNode(withName: "RightLeg", recursively: true)
        let leftArm = playerNode.childNode(withName: "LeftArm", recursively: true)
        let rightArm = playerNode.childNode(withName: "RightArm", recursively: true)

        if leftLeg != nil || rightLeg != nil {
            // Traditional limb animation
            let swingAngle: Float = isMoving ? 0.4 : 0
            let legSwing = sin(phase) * swingAngle
            let armSwing = sin(phase) * swingAngle * 0.7

            leftLeg?.eulerAngles.x = legSwing
            rightLeg?.eulerAngles.x = -legSwing
            leftArm?.eulerAngles.x = -armSwing
            rightArm?.eulerAngles.x = armSwing
        } else if isMoving {
            // Fallback: Simple bobbing/wobbling for USDZ or single-mesh models
            let bob = sin(phase * 1.5) * 0.05
            let wobble = cos(phase) * 0.05
            playerNode.position.y = 0 + bob // Pivot is at bottom
            playerNode.eulerAngles.z = wobble
        } else {
            // Reset
            playerNode.eulerAngles.z = 0
            playerNode.position.y = 0
        }
    }

    // MARK: - Helpers

    private static func makeBox(width: CGFloat, height: CGFloat, depth: CGFloat, radius: CGFloat, color: UIColor) -> SCNNode {
        let box = SCNBox(width: width, height: height, length: depth, chamferRadius: radius)
        box.firstMaterial = makeMaterial(color: color)
        return SCNNode(geometry: box)
    }

    private static func makeLimb(width: CGFloat, height: CGFloat, depth: CGFloat, color: UIColor) -> SCNNode {
        let capsule = SCNCapsule(capRadius: width / 2, height: height)
        capsule.firstMaterial = makeMaterial(color: color)
        return SCNNode(geometry: capsule)
    }

    private static func makeEye() -> SCNNode {
        let sphere = SCNSphere(radius: 0.065)
        sphere.firstMaterial = makeMaterial(color: .white)
        return SCNNode(geometry: sphere)
    }

    private static func makePupil() -> SCNNode {
        let sphere = SCNSphere(radius: 0.035)
        sphere.firstMaterial = makeMaterial(color: UIColor(red: 0.15, green: 0.12, blue: 0.1, alpha: 1))
        return SCNNode(geometry: sphere)
    }

    private static func makeMaterial(color: UIColor) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        mat.lightingModel = .blinn
        mat.isDoubleSided = false
        return mat
    }
}
