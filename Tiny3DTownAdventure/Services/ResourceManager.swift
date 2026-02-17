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
        node.isHidden = false
        node.opacity = 1.0
        node.castsShadow = true
        if let geometry = node.geometry {
            fixGeometryMaterials(geometry)
        }
        node.enumerateChildNodes { (child, _) in
            child.isHidden = false
            child.opacity = 1.0
            child.castsShadow = true
            guard let geometry = child.geometry else { return }
            self.fixGeometryMaterials(geometry)
        }
    }
    
    private func fixGeometryMaterials(_ geometry: SCNGeometry) {
        if geometry.materials.isEmpty {
            let fallback = SCNMaterial()
            fallback.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1.0)
            fallback.lightingModel = .blinn
            fallback.isDoubleSided = true
            geometry.materials = [fallback]
            return
        }
        for material in geometry.materials {
            material.isDoubleSided = true
            material.transparency = 1.0
            material.blendMode = .replace
            material.writesToDepthBuffer = true
            material.readsFromDepthBuffer = true
            
            material.lightingModel = .blinn
            material.metalness.contents = nil
            material.roughness.contents = nil
            material.ambientOcclusion.contents = nil
            material.normal.contents = nil
            
            if material.diffuse.contents == nil {
                material.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1.0)
            }
            
            if let color = material.diffuse.contents as? UIColor {
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: &a)
                if a < 0.1 {
                    material.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1.0)
                }
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
