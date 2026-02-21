import SceneKit
import SwiftUI

class CharacterLoader {
    static func load(named name: String) -> SCNNode? {
        print("🔍 CharacterLoader: Attempting to load '\(name)'")
        
        let extensions = ["usdz", "scn", "dae", "obj"]
        var modelUrl: URL? = nil
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                modelUrl = url
                break
            }
        }
        
        // --- STEP 1: LOAD THE NODE ---
        let wrapper = SCNNode()
        wrapper.name = "CharacterRoot"
        
        if let url = modelUrl {
            print("✅ Found file at \(url.lastPathComponent). Loading...")
            
            // Try Scene(named:) first as it's the most common for bundled assets
            let fullName = "\(name).\(url.pathExtension)"
            if let scene = SCNScene(named: fullName) {
                for child in scene.rootNode.childNodes {
                    wrapper.addChildNode(child.clone())
                }
            }
            
            // Strategy 2: Reference Node
            if wrapper.childNodes.isEmpty {
                if let refNode = SCNReferenceNode(url: url) {
                    refNode.load()
                    wrapper.addChildNode(refNode)
                }
            }
            
            // Strategy 3: URL Direct
            if wrapper.childNodes.isEmpty {
                if let scene = try? SCNScene(url: url, options: nil) {
                    for child in scene.rootNode.childNodes {
                        wrapper.addChildNode(child.clone())
                    }
                }
            }
        }
        
        // --- STEP 2: FALLBACK IF EMPTY ---
        if wrapper.childNodes.isEmpty {
            print("⚠️ CharacterLoader: All file strategies failed. Creating NEON FALLBACK.")
            let capsule = SCNCapsule(capRadius: 0.4, height: 1.8)
            // NEON GREEN - Impossible to miss
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            material.emission.contents = UIColor.green
            material.lightingModel = .constant
            capsule.firstMaterial = material
            
            let fallbackNode = SCNNode(geometry: capsule)
            fallbackNode.name = "FALLBACK_NODE"
            fallbackNode.position = SCNVector3(0, 0.9, 0) // Center of 1.8m height
            wrapper.addChildNode(fallbackNode)
        }
        
        // --- STEP 3: THE ULTIMATE NUCLEAR OPAQUE FIX ---
        let textureName = "player_texture"
        var finalImage: UIImage? = UIImage(named: textureName) ?? (Bundle.main.url(forResource: textureName, withExtension: "png").flatMap { UIImage(contentsOfFile: $0.path) })

        // STRIP ALPHA CHANNEL: Redraw the texture onto a completely black/opaque canvas
        if let original = finalImage {
            let size = original.size
            UIGraphicsBeginImageContextWithOptions(size, true, 1.0) // 'true' means OPAQUE
            UIColor.black.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            original.draw(in: CGRect(origin: .zero, size: size))
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            print("🧼 Image Nuclear Fix: Alpha channel stripped and flattened.")
        }

        print("🚀 CharacterLoader: Executing Absolute Zero Opaque Lock...")
        
        wrapper.renderingOrder = 5000
        wrapper.opacity = 1.0
        
        wrapper.enumerateChildNodes { (child, _) in
            child.isHidden = false
            child.opacity = 1.0
            child.renderingOrder = 5000
            child.filters = [] 
            
            if let geo = child.geometry {
                let nuclearMat = SCNMaterial()
                nuclearMat.name = "ABSOLUTE_OPAQUE"
                
                if let image = finalImage {
                    nuclearMat.diffuse.contents = image
                    // Add emission so she doesn't look dark/ghosty in shadows
                    nuclearMat.emission.contents = image
                    nuclearMat.emission.intensity = 0.2
                } else {
                    nuclearMat.diffuse.contents = UIColor.magenta
                }
                
                // LIGHTING
                nuclearMat.lightingModel = .lambert
                
                // THE OPAQUE LOCK
                nuclearMat.transparency = 1.0
                nuclearMat.transparent.contents = UIColor.white // In .aOne, white = Opaque
                nuclearMat.transparencyMode = .aOne
                nuclearMat.blendMode = .replace
                
                // DEPTH & CULLING
                nuclearMat.writesToDepthBuffer = true
                nuclearMat.readsFromDepthBuffer = true
                nuclearMat.isDoubleSided = true // Flipped normals fix
                
                // Remove all other material settings that could cause bugs
                nuclearMat.specular.contents = UIColor.black
                nuclearMat.reflective.contents = nil
                nuclearMat.colorBufferWriteMask = [.all]
                
                geo.materials = [nuclearMat]
                print("💎 Locked Node '\(child.name ?? "unnamed")' to Absolute Opaque.")
            }
        }
        
        // --- STEP 4: AUTO-SCALE AND PIVOT TO BOTTOM ---
        let (min, max) = wrapper.boundingBox
        let height = max.y - min.y
        print("📐 CharacterLoader: BoundingBox Min:\(min) Max:\(max) Height:\(height)")

        if height > 0 {
            if height > 8 || height < 0.2 {
                let s = 1.8 / height
                wrapper.scale = SCNVector3(s, s, s)
            }
            
            let centerX = (max.x + min.x) / 2
            let centerZ = (max.z + min.z) / 2
            wrapper.pivot = SCNMatrix4MakeTranslation(centerX, min.y, centerZ)
        }
        
        wrapper.position = SCNVector3(0, 0, 0)
        return wrapper
    }
}
