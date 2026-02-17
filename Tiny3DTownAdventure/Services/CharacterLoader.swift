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
        
        let wrapper = SCNNode()
        wrapper.name = "CharacterRoot"
        
        if let url = modelUrl {
            print("✅ Found file at \(url.lastPathComponent). Loading...")
            
            let fullName = "\(name).\(url.pathExtension)"
            if let scene = SCNScene(named: fullName) {
                for child in scene.rootNode.childNodes {
                    wrapper.addChildNode(child.clone())
                }
            }
            
            if wrapper.childNodes.isEmpty {
                if let refNode = SCNReferenceNode(url: url) {
                    refNode.load()
                    wrapper.addChildNode(refNode)
                }
            }
            
            if wrapper.childNodes.isEmpty {
                if let scene = try? SCNScene(url: url, options: nil) {
                    for child in scene.rootNode.childNodes {
                        wrapper.addChildNode(child.clone())
                    }
                }
            }
        }
        
        if wrapper.childNodes.isEmpty {
            print("⚠️ CharacterLoader: All file strategies failed. Creating NEON FALLBACK.")
            let capsule = SCNCapsule(capRadius: 0.4, height: 1.8)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            material.emission.contents = UIColor.green
            material.lightingModel = .constant
            capsule.firstMaterial = material
            
            let fallbackNode = SCNNode(geometry: capsule)
            fallbackNode.name = "FALLBACK_NODE"
            fallbackNode.position = SCNVector3(0, 0.9, 0)
            wrapper.addChildNode(fallbackNode)
        }
        
        wrapper.enumerateChildNodes { (child, _) in
            child.isHidden = false
            child.opacity = 1.0
            child.renderingOrder = 100
            
            if let geo = child.geometry {
                geo.materials = geo.materials.map { oldMat in
                    let newMat = SCNMaterial()
                    newMat.diffuse.contents = oldMat.diffuse.contents
                    newMat.lightingModel = .blinn
                    newMat.isDoubleSided = true
                    newMat.transparency = 1.0
                    newMat.transparencyMode = .rgbZero
                    newMat.writesToDepthBuffer = true
                    newMat.readsFromDepthBuffer = true
                    if newMat.diffuse.contents == nil {
                        newMat.diffuse.contents = UIColor.systemGray
                    }
                    return newMat
                }
            }
        }
        
        let (min, max) = wrapper.boundingBox
        let height = max.y - min.y
        print("📐 CharacterLoader: BoundingBox Min:\(min) Max:\(max) Height:\(height)")

        if height > 0 {
            if height > 10 || height < 0.1 {
                let s = 1.8 / height
                wrapper.scale = SCNVector3(s, s, s)
                print("📐 Applied auto-scale: \(s)")
            }
            
            let centerX = (max.x + min.x) / 2
            let centerZ = (max.z + min.z) / 2
            wrapper.pivot = SCNMatrix4MakeTranslation(centerX, min.y, centerZ)
        }
        
        let marker = SCNNode(geometry: SCNSphere(radius: 0.15))
        marker.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        marker.geometry?.firstMaterial?.lightingModel = .constant
        marker.position = SCNVector3(0, 1.7, 0)
        wrapper.addChildNode(marker)
        
        wrapper.position = SCNVector3(0, 0, 0)
        return wrapper
    }
}
