import SceneKit

class ResourceManager {
    static let shared = ResourceManager()
    
    private init() {}
    
    func loadCharacter(named name: String) -> SCNNode? {
        // Try loading from .usdz, .scn, or .dae
        let extensions = ["usdz", "scn", "dae", "obj"]
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                print("Found model for \(name) at \(url)")
                do {
                    let scene = try SCNScene(url: url, options: nil)
                    // Return the first node that contains geometry or the root node of the scene
                    // Flattening might be good for performance, but for now let's just return the root wrapper
                    let wrapperNode = SCNNode()
                    for child in scene.rootNode.childNodes {
                        wrapperNode.addChildNode(child)
                    }
                    return wrapperNode
                } catch {
                    print("Error loading scene: \(error)")
                }
            }
        }
        
        print("Could not find model for \(name)")
        return nil
    }
}
