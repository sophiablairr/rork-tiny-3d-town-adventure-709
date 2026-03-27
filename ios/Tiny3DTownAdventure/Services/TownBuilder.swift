import SceneKit

enum TownBuilder {

    static func buildTown(in scene: SCNScene) {
        addTerrain(to: scene)
        addOcean(to: scene)
        addBeach(to: scene)
        addMountains(to: scene)
        addPaths(to: scene)
        addHouses(to: scene)
        addFountain(to: scene, at: SCNVector3(0, 0, -3))
        addTrees(to: scene)
        addFlowers(to: scene)
        addGrassDetails(to: scene)
    }

    // MARK: - Terrain

    private static func addTerrain(to scene: SCNScene) {
        let ground = SCNBox(width: 60, height: 0.2, length: 60, chamferRadius: 0)
        ground.firstMaterial?.diffuse.contents = UIColor(red: 0.38, green: 0.68, blue: 0.28, alpha: 1)
        let groundNode = SCNNode(geometry: ground)
        groundNode.position = SCNVector3(5, -0.1, 0)
        scene.rootNode.addChildNode(groundNode)

        let grassOverlay = SCNBox(width: 50, height: 0.02, length: 50, chamferRadius: 0)
        grassOverlay.firstMaterial?.diffuse.contents = UIColor(red: 0.42, green: 0.72, blue: 0.32, alpha: 1)
        let overlayNode = SCNNode(geometry: grassOverlay)
        overlayNode.position = SCNVector3(5, 0.01, 0)
        scene.rootNode.addChildNode(overlayNode)
    }

    // MARK: - Ocean

    private static func addOcean(to scene: SCNScene) {
        let ocean = SCNBox(width: 35, height: 0.3, length: 60, chamferRadius: 0)
        ocean.firstMaterial?.diffuse.contents = UIColor(red: 0.12, green: 0.5, blue: 0.82, alpha: 1)
        ocean.firstMaterial?.specular.contents = UIColor.white
        ocean.firstMaterial?.shininess = 30
        ocean.firstMaterial?.transparency = 0.92
        let oceanNode = SCNNode(geometry: ocean)
        oceanNode.position = SCNVector3(-28, -0.35, 0)
        scene.rootNode.addChildNode(oceanNode)

        let oceanSurface = SCNBox(width: 35, height: 0.05, length: 60, chamferRadius: 0)
        oceanSurface.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.5)
        oceanSurface.firstMaterial?.specular.contents = UIColor.white
        oceanSurface.firstMaterial?.shininess = 60
        let surfaceNode = SCNNode(geometry: oceanSurface)
        surfaceNode.position = SCNVector3(-28, -0.15, 0)
        scene.rootNode.addChildNode(surfaceNode)

        let wave1 = SCNAction.moveBy(x: 0.4, y: 0, z: 0.3, duration: 2.5)
        wave1.timingMode = .easeInEaseOut
        let wave2 = SCNAction.moveBy(x: -0.4, y: 0, z: -0.3, duration: 2.5)
        wave2.timingMode = .easeInEaseOut
        surfaceNode.runAction(SCNAction.repeatForever(SCNAction.sequence([wave1, wave2])))
    }

    // MARK: - Beach

    private static func addBeach(to scene: SCNScene) {
        let beach = SCNBox(width: 6, height: 0.15, length: 35, chamferRadius: 0)
        beach.firstMaterial?.diffuse.contents = UIColor(red: 0.94, green: 0.87, blue: 0.65, alpha: 1)
        let beachNode = SCNNode(geometry: beach)
        beachNode.position = SCNVector3(-13, -0.08, -2)
        scene.rootNode.addChildNode(beachNode)

        let wetSand = SCNBox(width: 2, height: 0.12, length: 35, chamferRadius: 0)
        wetSand.firstMaterial?.diffuse.contents = UIColor(red: 0.78, green: 0.72, blue: 0.52, alpha: 1)
        let wetNode = SCNNode(geometry: wetSand)
        wetNode.position = SCNVector3(-15, -0.12, -2)
        scene.rootNode.addChildNode(wetNode)
    }

    // MARK: - Mountains

    private static func addMountains(to scene: SCNScene) {
        addMountain(to: scene, position: SCNVector3(14, 0, -24), height: 14, radius: 9)
        addMountain(to: scene, position: SCNVector3(4, 0, -28), height: 18, radius: 11)
        addMountain(to: scene, position: SCNVector3(-4, 0, -22), height: 11, radius: 7)
        addMountain(to: scene, position: SCNVector3(22, 0, -20), height: 10, radius: 7)
    }

    private static func addMountain(to scene: SCNScene, position: SCNVector3, height: CGFloat, radius: CGFloat) {
        let mountain = SCNCone(topRadius: 0, bottomRadius: radius, height: height)
        mountain.firstMaterial?.diffuse.contents = UIColor(red: 0.32, green: 0.55, blue: 0.28, alpha: 1)
        let mountainNode = SCNNode(geometry: mountain)
        mountainNode.position = SCNVector3(position.x, Float(height) / 2, position.z)
        scene.rootNode.addChildNode(mountainNode)

        let snowH = height * 0.3
        let snowR = radius * 0.25
        let snow = SCNCone(topRadius: 0, bottomRadius: snowR, height: snowH)
        snow.firstMaterial?.diffuse.contents = UIColor(red: 0.97, green: 0.97, blue: 1.0, alpha: 1)
        let snowNode = SCNNode(geometry: snow)
        snowNode.position = SCNVector3(position.x, Float(height) - Float(snowH) / 2, position.z)
        scene.rootNode.addChildNode(snowNode)
    }

    // MARK: - Paths

    private static func addPaths(to scene: SCNScene) {
        for z in stride(from: -9.0, through: 10.0, by: 0.95) {
            for x in stride(from: -1.5, through: 1.5, by: 0.95) {
                addStone(to: scene, at: SCNVector3(
                    Float(x) + Float.random(in: -0.04...0.04),
                    0.02,
                    Float(z) + Float.random(in: -0.04...0.04)
                ))
            }
        }

        for x in stride(from: -6.0, through: -2.0, by: 0.95) {
            for z in stride(from: 1.0, through: 2.5, by: 0.95) {
                addStone(to: scene, at: SCNVector3(Float(x), 0.02, Float(z)))
            }
        }

        for x in stride(from: 2.0, through: 6.5, by: 0.95) {
            for z in stride(from: 1.5, through: 3.0, by: 0.95) {
                addStone(to: scene, at: SCNVector3(Float(x), 0.02, Float(z)))
            }
        }
    }

    private static func addStone(to scene: SCNScene, at position: SCNVector3) {
        let stone = SCNBox(width: 0.85, height: 0.06, length: 0.85, chamferRadius: 0.06)
        let gray = CGFloat.random(in: 0.55...0.72)
        stone.firstMaterial?.diffuse.contents = UIColor(white: gray, alpha: 1)
        let stoneNode = SCNNode(geometry: stone)
        stoneNode.position = position
        stoneNode.eulerAngles.y = Float.random(in: -0.05...0.05)
        scene.rootNode.addChildNode(stoneNode)
    }

    // MARK: - Houses

    private static func addHouses(to scene: SCNScene) {
        addHouse(
            to: scene,
            position: SCNVector3(-5, 0, 1),
            wallColor: UIColor(red: 0.96, green: 0.82, blue: 0.78, alpha: 1),
            roofColor: UIColor(red: 0.8, green: 0.3, blue: 0.18, alpha: 1),
            trimColor: UIColor.white,
            name: "House1"
        )
        addHouse(
            to: scene,
            position: SCNVector3(5, 0, 2.5),
            wallColor: UIColor(red: 0.72, green: 0.88, blue: 0.86, alpha: 1),
            roofColor: UIColor(red: 0.78, green: 0.28, blue: 0.2, alpha: 1),
            trimColor: UIColor(red: 0.92, green: 0.92, blue: 0.95, alpha: 1),
            name: "House2"
        )
        addHouse(
            to: scene,
            position: SCNVector3(8, 0, -6),
            wallColor: UIColor(red: 0.92, green: 0.88, blue: 0.75, alpha: 1),
            roofColor: UIColor(red: 0.55, green: 0.35, blue: 0.25, alpha: 1),
            trimColor: UIColor(red: 0.85, green: 0.82, blue: 0.78, alpha: 1),
            name: "House3"
        )
    }

    private static func addHouse(to scene: SCNScene, position: SCNVector3, wallColor: UIColor, roofColor: UIColor, trimColor: UIColor, name: String) {
        let houseNode = SCNNode()
        houseNode.position = position

        let foundation = SCNBox(width: 3.4, height: 0.2, length: 2.8, chamferRadius: 0)
        foundation.firstMaterial?.diffuse.contents = UIColor(white: 0.62, alpha: 1)
        let foundationNode = SCNNode(geometry: foundation)
        foundationNode.position = SCNVector3(0, 0.1, 0)
        houseNode.addChildNode(foundationNode)

        let walls = SCNBox(width: 3, height: 2.2, length: 2.5, chamferRadius: 0.02)
        walls.firstMaterial?.diffuse.contents = wallColor
        let wallsNode = SCNNode(geometry: walls)
        wallsNode.position = SCNVector3(0, 1.3, 0)
        houseNode.addChildNode(wallsNode)

        let roof = SCNPyramid(width: 3.5, height: 1.4, length: 3.0)
        roof.firstMaterial?.diffuse.contents = roofColor
        let roofNode = SCNNode(geometry: roof)
        roofNode.position = SCNVector3(0, 2.4 + 0.7, 0)
        houseNode.addChildNode(roofNode)

        let door = SCNBox(width: 0.55, height: 0.9, length: 0.06, chamferRadius: 0.04)
        door.firstMaterial?.diffuse.contents = UIColor(red: 0.55, green: 0.38, blue: 0.2, alpha: 1)
        let doorNode = SCNNode(geometry: door)
        doorNode.position = SCNVector3(0, 0.65, 1.28)
        doorNode.name = "Door_" + name
        houseNode.addChildNode(doorNode)

        let doorFrame = SCNBox(width: 0.65, height: 1.0, length: 0.04, chamferRadius: 0)
        doorFrame.firstMaterial?.diffuse.contents = trimColor
        let doorFrameNode = SCNNode(geometry: doorFrame)
        doorFrameNode.position = SCNVector3(0, 0.7, 1.27)
        houseNode.addChildNode(doorFrameNode)

        let knob = SCNSphere(radius: 0.03)
        knob.firstMaterial?.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.3, alpha: 1)
        knob.firstMaterial?.specular.contents = UIColor.white
        let knobNode = SCNNode(geometry: knob)
        knobNode.position = SCNVector3(0.18, 0.65, 1.31)
        houseNode.addChildNode(knobNode)

        addWindow(to: houseNode, at: SCNVector3(-0.75, 1.5, 1.28), trimColor: trimColor)
        addWindow(to: houseNode, at: SCNVector3(0.75, 1.5, 1.28), trimColor: trimColor)

        let chimney = SCNBox(width: 0.4, height: 0.9, length: 0.4, chamferRadius: 0.02)
        chimney.firstMaterial?.diffuse.contents = UIColor(white: 0.55, alpha: 1)
        let chimneyNode = SCNNode(geometry: chimney)
        chimneyNode.position = SCNVector3(0.85, 3.2, -0.4)
        houseNode.addChildNode(chimneyNode)

        let chimneyTop = SCNBox(width: 0.5, height: 0.1, length: 0.5, chamferRadius: 0)
        chimneyTop.firstMaterial?.diffuse.contents = UIColor(white: 0.45, alpha: 1)
        let chimneyTopNode = SCNNode(geometry: chimneyTop)
        chimneyTopNode.position = SCNVector3(0.85, 3.7, -0.4)
        houseNode.addChildNode(chimneyTopNode)

        scene.rootNode.addChildNode(houseNode)
    }

    private static func addWindow(to parent: SCNNode, at position: SCNVector3, trimColor: UIColor) {
        let frame = SCNBox(width: 0.55, height: 0.55, length: 0.04, chamferRadius: 0)
        frame.firstMaterial?.diffuse.contents = trimColor
        let frameNode = SCNNode(geometry: frame)
        frameNode.position = SCNVector3(position.x, position.y, position.z - 0.01)
        parent.addChildNode(frameNode)

        let glass = SCNBox(width: 0.45, height: 0.45, length: 0.05, chamferRadius: 0.02)
        glass.firstMaterial?.diffuse.contents = UIColor(red: 0.65, green: 0.82, blue: 0.95, alpha: 0.85)
        glass.firstMaterial?.specular.contents = UIColor.white
        glass.firstMaterial?.shininess = 40
        let glassNode = SCNNode(geometry: glass)
        glassNode.position = position
        parent.addChildNode(glassNode)

        let dividerH = SCNBox(width: 0.45, height: 0.03, length: 0.06, chamferRadius: 0)
        dividerH.firstMaterial?.diffuse.contents = trimColor
        let dividerHNode = SCNNode(geometry: dividerH)
        dividerHNode.position = SCNVector3(position.x, position.y, position.z + 0.01)
        parent.addChildNode(dividerHNode)

        let dividerV = SCNBox(width: 0.03, height: 0.45, length: 0.06, chamferRadius: 0)
        dividerV.firstMaterial?.diffuse.contents = trimColor
        let dividerVNode = SCNNode(geometry: dividerV)
        dividerVNode.position = SCNVector3(position.x, position.y, position.z + 0.01)
        parent.addChildNode(dividerVNode)
    }

    // MARK: - Fountain

    private static func addFountain(to scene: SCNScene, at position: SCNVector3) {
        let node = SCNNode()
        node.position = position

        let base = SCNCylinder(radius: 1.3, height: 0.4)
        base.firstMaterial?.diffuse.contents = UIColor(white: 0.72, alpha: 1)
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.2, 0)
        node.addChildNode(baseNode)

        let rim = SCNTorus(ringRadius: 1.1, pipeRadius: 0.12)
        rim.firstMaterial?.diffuse.contents = UIColor(white: 0.68, alpha: 1)
        let rimNode = SCNNode(geometry: rim)
        rimNode.position = SCNVector3(0, 0.45, 0)
        node.addChildNode(rimNode)

        let water = SCNCylinder(radius: 0.95, height: 0.08)
        water.firstMaterial?.diffuse.contents = UIColor(red: 0.35, green: 0.65, blue: 0.92, alpha: 0.7)
        water.firstMaterial?.specular.contents = UIColor.white
        water.firstMaterial?.shininess = 50
        water.firstMaterial?.transparency = 0.7
        let waterNode = SCNNode(geometry: water)
        waterNode.position = SCNVector3(0, 0.4, 0)
        node.addChildNode(waterNode)

        let pillar = SCNCylinder(radius: 0.12, height: 1.1)
        pillar.firstMaterial?.diffuse.contents = UIColor(white: 0.72, alpha: 1)
        let pillarNode = SCNNode(geometry: pillar)
        pillarNode.position = SCNVector3(0, 0.95, 0)
        node.addChildNode(pillarNode)

        let topBowl = SCNCylinder(radius: 0.35, height: 0.12)
        topBowl.firstMaterial?.diffuse.contents = UIColor(white: 0.72, alpha: 1)
        let topBowlNode = SCNNode(geometry: topBowl)
        topBowlNode.position = SCNVector3(0, 1.55, 0)
        node.addChildNode(topBowlNode)

        let spout = SCNSphere(radius: 0.12)
        spout.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.7, blue: 1, alpha: 0.5)
        spout.firstMaterial?.transparency = 0.5
        spout.firstMaterial?.specular.contents = UIColor.white
        let spoutNode = SCNNode(geometry: spout)
        spoutNode.position = SCNVector3(0, 1.75, 0)
        node.addChildNode(spoutNode)

        let bobUp = SCNAction.moveBy(x: 0, y: 0.08, z: 0, duration: 1.2)
        bobUp.timingMode = .easeInEaseOut
        let bobDown = SCNAction.moveBy(x: 0, y: -0.08, z: 0, duration: 1.2)
        bobDown.timingMode = .easeInEaseOut
        spoutNode.runAction(SCNAction.repeatForever(SCNAction.sequence([bobUp, bobDown])))

        scene.rootNode.addChildNode(node)
    }

    // MARK: - Trees

    private static func addTrees(to scene: SCNScene) {
        let roundTreePositions: [SCNVector3] = [
            SCNVector3(-2.5, 0, -6),
            SCNVector3(3, 0, -7),
            SCNVector3(-8, 0, -3),
            SCNVector3(10, 0, 0),
            SCNVector3(-7, 0, 6),
            SCNVector3(12, 0, -10),
            SCNVector3(-4, 0, -12),
            SCNVector3(6, 0, 8),
            SCNVector3(-9, 0, 9),
            SCNVector3(2, 0, -10),
            SCNVector3(14, 0, 5),
            SCNVector3(-3, 0, 10),
        ]
        for pos in roundTreePositions {
            addRoundTree(to: scene, at: pos)
        }

        let pineTreePositions: [SCNVector3] = [
            SCNVector3(8, 0, -15),
            SCNVector3(15, 0, -14),
            SCNVector3(18, 0, -12),
            SCNVector3(11, 0, -17),
            SCNVector3(5, 0, -18),
            SCNVector3(-2, 0, -17),
            SCNVector3(20, 0, -15),
        ]
        for pos in pineTreePositions {
            addPineTree(to: scene, at: pos)
        }
    }

    private static func addRoundTree(to scene: SCNScene, at position: SCNVector3) {
        let node = SCNNode()
        node.position = position

        let trunk = SCNCylinder(radius: 0.2, height: 1.6)
        trunk.firstMaterial?.diffuse.contents = UIColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1)
        let trunkNode = SCNNode(geometry: trunk)
        trunkNode.position = SCNVector3(0, 0.8, 0)
        node.addChildNode(trunkNode)

        let canopy = SCNSphere(radius: 1.3)
        canopy.firstMaterial?.diffuse.contents = UIColor(
            red: CGFloat.random(in: 0.22...0.32),
            green: CGFloat.random(in: 0.55...0.65),
            blue: CGFloat.random(in: 0.22...0.3),
            alpha: 1
        )
        let canopyNode = SCNNode(geometry: canopy)
        canopyNode.position = SCNVector3(0, 2.6, 0)
        canopyNode.scale = SCNVector3(1, 0.8, 1)
        node.addChildNode(canopyNode)

        let detail = SCNSphere(radius: 0.9)
        detail.firstMaterial?.diffuse.contents = UIColor(
            red: CGFloat.random(in: 0.25...0.35),
            green: CGFloat.random(in: 0.58...0.68),
            blue: CGFloat.random(in: 0.22...0.3),
            alpha: 1
        )
        let detailNode = SCNNode(geometry: detail)
        detailNode.position = SCNVector3(
            Float.random(in: -0.4...0.4),
            2.9,
            Float.random(in: -0.4...0.4)
        )
        node.addChildNode(detailNode)

        scene.rootNode.addChildNode(node)
    }

    private static func addPineTree(to scene: SCNScene, at position: SCNVector3) {
        let node = SCNNode()
        node.position = position

        let trunk = SCNCylinder(radius: 0.12, height: 1.2)
        trunk.firstMaterial?.diffuse.contents = UIColor(red: 0.42, green: 0.28, blue: 0.14, alpha: 1)
        let trunkNode = SCNNode(geometry: trunk)
        trunkNode.position = SCNVector3(0, 0.6, 0)
        node.addChildNode(trunkNode)

        let layers: [(CGFloat, CGFloat, Float)] = [
            (1.2, 1.8, 2.1),
            (0.9, 1.5, 3.0),
            (0.6, 1.2, 3.8),
        ]
        for (radius, height, y) in layers {
            let foliage = SCNCone(topRadius: 0, bottomRadius: radius, height: height)
            foliage.firstMaterial?.diffuse.contents = UIColor(red: 0.12, green: 0.42, blue: 0.18, alpha: 1)
            let foliageNode = SCNNode(geometry: foliage)
            foliageNode.position = SCNVector3(0, y, 0)
            node.addChildNode(foliageNode)
        }

        scene.rootNode.addChildNode(node)
    }

    // MARK: - Flowers

    private static func addFlowers(to scene: SCNScene) {
        let clusters: [(SCNVector3, Int)] = [
            (SCNVector3(-6.5, 0, 0.5), 5),
            (SCNVector3(7.5, 0, 1.5), 4),
            (SCNVector3(1, 0, 6), 6),
            (SCNVector3(-1, 0, -5), 4),
            (SCNVector3(3.5, 0, -5), 3),
            (SCNVector3(-8.5, 0, -7), 5),
            (SCNVector3(11, 0, -3), 3),
            (SCNVector3(-5, 0, 8), 4),
        ]

        let colors: [UIColor] = [
            UIColor(red: 1, green: 0.35, blue: 0.35, alpha: 1),
            UIColor(red: 1, green: 0.85, blue: 0.15, alpha: 1),
            UIColor(red: 0.4, green: 0.55, blue: 1, alpha: 1),
            UIColor(red: 1, green: 0.55, blue: 0.75, alpha: 1),
            UIColor(red: 0.85, green: 0.45, blue: 1, alpha: 1),
            UIColor(red: 1, green: 0.7, blue: 0.25, alpha: 1),
            UIColor(red: 1, green: 1, blue: 0.6, alpha: 1),
        ]

        var colorIndex = 0
        for (center, count) in clusters {
            for _ in 0..<count {
                let pos = SCNVector3(
                    center.x + Float.random(in: -0.6...0.6),
                    0,
                    center.z + Float.random(in: -0.6...0.6)
                )
                addFlower(to: scene, at: pos, color: colors[colorIndex % colors.count])
                colorIndex += 1
            }
        }
    }

    private static func addFlower(to scene: SCNScene, at position: SCNVector3, color: UIColor) {
        let node = SCNNode()
        node.position = position

        let stem = SCNCylinder(radius: 0.015, height: 0.2)
        stem.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.55, blue: 0.2, alpha: 1)
        let stemNode = SCNNode(geometry: stem)
        stemNode.position = SCNVector3(0, 0.1, 0)
        node.addChildNode(stemNode)

        let petal = SCNSphere(radius: 0.07)
        petal.firstMaterial?.diffuse.contents = color
        let petalNode = SCNNode(geometry: petal)
        petalNode.position = SCNVector3(0, 0.22, 0)
        petalNode.scale = SCNVector3(1.3, 0.6, 1.3)
        node.addChildNode(petalNode)

        let center = SCNSphere(radius: 0.03)
        center.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 0.95, blue: 0.5, alpha: 1)
        let centerNode = SCNNode(geometry: center)
        centerNode.position = SCNVector3(0, 0.24, 0)
        node.addChildNode(centerNode)

        scene.rootNode.addChildNode(node)
    }

    // MARK: - Grass Details

    private static func addGrassDetails(to scene: SCNScene) {
        for _ in 0..<40 {
            let x = Float.random(in: -10...20)
            let z = Float.random(in: -14...18)
            let patch = SCNBox(
                width: CGFloat.random(in: 0.2...0.5),
                height: 0.015,
                length: CGFloat.random(in: 0.2...0.5),
                chamferRadius: 0.01
            )
            let greenVariation = CGFloat.random(in: 0.35...0.52)
            patch.firstMaterial?.diffuse.contents = UIColor(
                red: greenVariation - 0.08,
                green: greenVariation + 0.22,
                blue: greenVariation - 0.12,
                alpha: 1
            )
            let patchNode = SCNNode(geometry: patch)
            patchNode.position = SCNVector3(x, 0.015, z)
            patchNode.eulerAngles.y = Float.random(in: 0...Float.pi * 2)
            scene.rootNode.addChildNode(patchNode)
        }
    }
}
