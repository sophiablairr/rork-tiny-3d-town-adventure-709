import SceneKit

class ResourceManager {
    static let shared = ResourceManager()
    
    // Keep a strong reference to loaded scenes so textures don't get garbage collected
    private var loadedScenes: [String: SCNScene] = [:]
    
    private init() {}
    
    func loadCharacter(named name: String) -> SCNNode? {
        let extensions = ["usdz", "scn", "dae", "obj"]
        
        for ext in extensions {
            guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
                continue
            }
            
            print("✅ Found model file: \(name).\(ext)")
            
            // METHOD 1: Try SCNReferenceNode (Apple's recommended approach for USDZ)
            if let refNode = SCNReferenceNode(url: url) {
                refNode.load()
                
                // Check if it actually loaded content
                if refNode.childNodes.count > 0 || refNode.geometry != nil {
                    print("✅ Loaded via SCNReferenceNode — children: \(refNode.childNodes.count)")
                    fixMaterials(on: refNode)
                    return refNode
                } else {
                    print("⚠️ SCNReferenceNode loaded but empty, trying SCNScene...")
                }
            }
            
            // METHOD 2: Fall back to SCNScene loading
            do {
                let scene = try SCNScene(url: url, options: nil)
                
                // IMPORTANT: Keep scene alive so textures aren't freed
                loadedScenes[name] = scene
                
                let wrapperNode = SCNNode()
                
                // Move children directly (don't clone — cloning can lose texture refs)
                let children = scene.rootNode.childNodes
                for child in children {
                    child.removeFromParentNode()
                    wrapperNode.addChildNode(child)
                }
                
                let geometryCount = countGeometry(in: wrapperNode)
                print("✅ Loaded via SCNScene — \(geometryCount) geometry nodes")
                
                fixMaterials(on: wrapperNode)
                return wrapperNode
            } catch {
                print("❌ SCNScene loading failed: \(error)")
            }
        }
        
        // Debug: show what files ARE in the bundle
        print("⚠️ Could not find model '\(name)' in bundle")
        if let resourcePath = Bundle.main.resourcePath {
            let files = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath)) ?? []
            print("📁 All bundle files: \(files.joined(separator: ", "))")
        }
        return nil
    }
    
    private func fixMaterials(on node: SCNNode) {
        node.enumerateChildNodes { (child, _) in
            // Ensure node is visible
            child.isHidden = false
            child.opacity = 1.0
            child.castsShadow = true
            
            guard let geometry = child.geometry else { return }
            
            for material in geometry.materials {
                // Force double-sided rendering (fixes flipped normals)
                material.isDoubleSided = true
                
                // Ensure full opacity
                material.transparency = 1.0
                material.blendMode = .replace
                
                // Use Blinn lighting — works without HDR environment maps
                material.lightingModel = .blinn
                
                // Assign a visible diffuse color if none exists
                if material.diffuse.contents == nil {
                    material.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1.0)
                }
                
                // Zero out metalness — high metalness with no environment = invisible
                material.metalness.contents = UIColor.black
                material.metalness.intensity = 0
                
                // Set reasonable roughness
                material.roughness.contents = UIColor.gray
                material.roughness.intensity = 0.8
                
                // Clear any ambient occlusion that might darken everything
                material.ambientOcclusion.contents = nil
            }
        }
        
        // Also fix the node itself if it has geometry
        if let geometry = node.geometry {
            for material in geometry.materials {
                material.isDoubleSided = true
                material.transparency = 1.0
                material.lightingModel = .blinn
                if material.diffuse.contents == nil {
                    material.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1.0)
                }
                material.metalness.contents = UIColor.black
                material.metalness.intensity = 0
            }
        }
    }
    
    private func countGeometry(in node: SCNNode) -> Int {
        var count = 0
        if node.geometry != nil { count += 1 }
        node.enumerateChildNodes { (child, _) in
            if child.geometry != nil { count += 1 }
        }
        return count
    }
}
