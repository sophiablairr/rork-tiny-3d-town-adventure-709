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
        
        // --- STEP 3: ENSURE VISIBILITY + FIX PBR MATERIALS ---
        wrapper.enumerateChildNodes { (child, _) in
            child.isHidden = false
            child.opacity = 1.0
<<<<<<< HEAD
            guard let geometry = child.geometry else { return }
            for material in geometry.materials {
                // USDZ uses PBR which needs IBL (env map) to render.
                // Convert to blinn to preserve diffuse texture without needing IBL.
                let diffuse = material.diffuse.contents
                let hasDiffuse = diffuse != nil
                material.lightingModel = .blinn
                if !hasDiffuse {
                    material.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1.0)
=======
            child.renderingOrder = 100
            
            if let geo = child.geometry {
                for mat in geo.materials {
                    // Force the lighting model to Blinn (non-PBR) as suggested
                    mat.lightingModel = .blinn
                    
                    // Reset PBR-specific properties that can cause invisibility without IBL
                    mat.metalness.contents = 0.0
                    mat.roughness.contents = 1.0
                    
                    // Ensure the diffuse (main texture) is at full intensity
                    mat.diffuse.intensity = 1.0
                    
                    // Force visibility and depth settings
                    mat.isDoubleSided = true
                    mat.transparency = 1.0
                    mat.transparencyMode = .aOne 
                    mat.writesToDepthBuffer = true
                    mat.readsFromDepthBuffer = true
                    mat.blendMode = .alpha
                    
                    if mat.diffuse.contents == nil {
                        mat.diffuse.contents = UIColor.systemGray
                    }
>>>>>>> 49d0abd (Refined material conversion: forced Blinn lighting and reset PBR properties to solve USDZ invisibility)
                }
                material.isDoubleSided = true
            }
        }
        
        // --- STEP 4: AUTO-SCALE AND PIVOT TO BOTTOM ---
        let (min, max) = wrapper.boundingBox
        let height = max.y - min.y
        print("📐 CharacterLoader: BoundingBox Min:\(min) Max:\(max) Height:\(height)")

        if height > 0 {
<<<<<<< HEAD
=======
            // Scale if it's way off
>>>>>>> 49d0abd (Refined material conversion: forced Blinn lighting and reset PBR properties to solve USDZ invisibility)
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
