import SceneKit
import SwiftUI

class CharacterLoader {
    static func load(named name: String) -> SCNNode? {
        // 1. Try to find the file
        let extensions = ["usdz", "scn", "dae", "obj"]
        var modelUrl: URL? = nil
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                modelUrl = url
                break
            }
        }
        
        guard let url = modelUrl else {
            print("❌ CharacterLoader: File '\(name)' not found in bundle.")
            return nil
        }
        
        print("✅ CharacterLoader: Loading '\(url.lastPathComponent)'")
        
        do {
            // 2. Load the scene
            // Using SCNReferenceNode is often better for USDZ as it keeps links alive
            let refNode = SCNReferenceNode(url: url)
            refNode.load()
            
            let wrapper = SCNNode()
            wrapper.addChildNode(refNode)
            
            // 3. Fix visibility and materials
            // AI models often have weird material settings (metallic=1, etc)
            wrapper.enumerateChildNodes { (child, _) in
                child.isHidden = false
                child.opacity = 1.0
                
                if let geo = child.geometry {
                    for mat in geo.materials {
                        mat.isDoubleSided = true // Important for some AI models
                        mat.transparency = 1.0
                        
                        // Fallback to a visible lighting model if PBR is failing
                        mat.lightingModel = .blinn
                        
                        // Metallic 1 on PBR makes thing black/invisible without environment maps
                        mat.metalness.intensity = 0.0
                        mat.roughness.intensity = 0.5
                        
                        if mat.diffuse.contents == nil {
                            mat.diffuse.contents = UIColor.systemGray3
                        }
                    }
                }
            }
            
            // 4. Auto-Calculate Scale and Center
            let (minV, maxV) = wrapper.boundingBox
            let height = maxV.y - minV.y
            let width = maxV.x - minV.x
            let depth = maxV.z - minV.z
            let largestDim = max(height, max(width, depth))
            
            if largestDim > 0 {
                // Target height of 1.8 units
                let targetHeight: Float = 1.8
                let scale = targetHeight / largestDim
                wrapper.scale = SCNVector3(scale, scale, scale)
                
                // Offset to put "feet" at Y=0
                // Using max(1.8 / largestDim) above, but let's be precise
                let yOffset = -minV.y * scale
                wrapper.position.y = yOffset
            }
            
            return wrapper
        } catch {
            print("❌ CharacterLoader: Failed to load scene: \(error)")
            return nil
        }
    }
}
