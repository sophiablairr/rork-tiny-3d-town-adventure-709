import SceneKit

class ResourceManager {
    static let shared = ResourceManager()
    
    private init() {}
    
    func loadCharacter(named name: String) -> SCNNode? {
        let extensions = ["usdz", "scn", "dae", "obj"]
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                print("✅ Found model: \(name).\(ext) at \(url)")
                do {
                    let scene = try SCNScene(url: url, options: [
                        .checkConsistency: true,
                        .convertToYUp: true
                    ])
                    
                    let wrapperNode = SCNNode()
                    
                    // Copy all children from the loaded scene
                    for child in scene.rootNode.childNodes {
                        wrapperNode.addChildNode(child.clone())
                    }
                    
                    // Debug: count geometry nodes
                    var geometryCount = 0
                    var materialCount = 0
                    wrapperNode.enumerateChildNodes { (child, _) in
                        if let geo = child.geometry {
                            geometryCount += 1
                            materialCount += geo.materials.count
                            
                            // Fix every material to ensure visibility
                            for material in geo.materials {
                                material.isDoubleSided = true
                                material.transparency = 1.0
                                material.blendMode = .replace
                                
                                // If diffuse has no content, assign a visible color
                                if material.diffuse.contents == nil {
                                    material.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1)
                                }
                                
                                // Convert PBR to Blinn for guaranteed visibility
                                material.lightingModel = .blinn
                                
                                // Clear metalness which can make things invisible
                                material.metalness.contents = NSNumber(value: 0.0)
                                material.roughness.contents = NSNumber(value: 0.8)
                            }
                        }
                        
                        // Make sure no nodes are hidden
                        child.isHidden = false
                        child.opacity = 1.0
                    }
                    
                    print("📊 Model stats: \(geometryCount) geometry nodes, \(materialCount) materials")
                    print("📐 Bounding box: \(wrapperNode.boundingBox)")
                    
                    return wrapperNode
                } catch {
                    print("❌ Error loading scene: \(error)")
                }
            }
        }
        
        print("⚠️ Could not find model named '\(name)' in bundle")
        // Debug: list what IS in the bundle
        if let resourcePath = Bundle.main.resourcePath {
            let files = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath)) ?? []
            let modelFiles = files.filter { $0.hasSuffix(".usdz") || $0.hasSuffix(".scn") || $0.hasSuffix(".dae") }
            print("📁 Model files in bundle: \(modelFiles)")
        }
        return nil
    }
}
