import SceneKit
import SwiftUI
import ModelIO
import SceneKit.ModelIO

class CharacterLoader {
    static func load(named name: String) -> SCNNode? {
        print("🔍 CharacterLoader: Attempting to load '\(name)'")
        
        let extensions = ["glb", "usdz", "scn", "dae", "obj"]
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
            print("📦 [CharacterLoader] FILE FOUND: \(url.path)")
            
            // Strategy 0: ModelIO (for .glb support)
            if url.pathExtension.lowercased() == "glb" {
                let asset = MDLAsset(url: url)
                asset.loadTextures()
                let scene = SCNScene(mdlAsset: asset)
                
                print("📦 [GLB] Node count in scene: \(scene.rootNode.childNodes.count)")
                for child in scene.rootNode.childNodes {
                    wrapper.addChildNode(child.clone())
                }
            }
            
            // Strategy 1: Scene(named:)
            if wrapper.childNodes.isEmpty {
                let fullName = "\(name).\(url.pathExtension)"
                if let scene = SCNScene(named: fullName) {
                    print("📦 [SceneNamed] SUCCESS")
                    for child in scene.rootNode.childNodes {
                        wrapper.addChildNode(child.clone())
                    }
                }
            }
            
            // Strategy 2: URL Direct
            if wrapper.childNodes.isEmpty {
                if let scene = try? SCNScene(url: url, options: nil) {
                    print("📦 [SCNSceneURL] SUCCESS")
                    for child in scene.rootNode.childNodes {
                        wrapper.addChildNode(child.clone())
                    }
                }
            }
        } else {
            print("❌ [CharacterLoader] NO FILE FOUND matching '\(name)' with extensions \(extensions)")
        }
        
        // --- STEP 1.5: DEBUG MARKER (RED BALL) ---
        // This will always be at the character's pivot point.
        // If you see this but No character, the model is invisible.
        // If you see nothing, the whole character is missing/far away.
        let debugMarker = SCNNode(geometry: SCNSphere(radius: 0.1))
        debugMarker.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        debugMarker.geometry?.firstMaterial?.lightingModel = .constant
        debugMarker.name = "DEBUG_MARKER"
        wrapper.addChildNode(debugMarker)
        
        // --- STEP 2: FALLBACK IF EMPTY ---
        if wrapper.childNodes.count <= 1 { // Only the debug marker
            print("⚠️ [CharacterLoader] EMPTY LOAD. Using Fallback Pill.")
            let capsule = SCNCapsule(capRadius: 0.3, height: 1.6)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            material.lightingModel = .constant
            capsule.firstMaterial = material
            let fallbackNode = SCNNode(geometry: capsule)
            fallbackNode.position = SCNVector3(0, 0.8, 0)
            wrapper.addChildNode(fallbackNode)
        }
        
        // --- STEP 3: MATERIAL FIXES ---
        wrapper.enumerateChildNodes { (child, _) in
            child.isHidden = false
            child.opacity = 1.0
            
            if let geo = child.geometry, child.name != "DEBUG_MARKER" {
                var newMaterials: [SCNMaterial] = []
                for oldMat in geo.materials {
                    let newMat = SCNMaterial()
                    let diffuseContent = oldMat.diffuse.contents
                    
                    if let image = diffuseContent as? UIImage {
                        let size = image.size
                        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
                        UIColor.black.setFill()
                        UIRectFill(CGRect(origin: .zero, size: size))
                        image.draw(in: CGRect(origin: .zero, size: size))
                        let laundered = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        newMat.diffuse.contents = laundered
                    } else if diffuseContent != nil {
                        newMat.diffuse.contents = diffuseContent
                    } else {
                        newMat.diffuse.contents = UIColor.systemGray
                    }
                    
                    newMat.lightingModel = .constant
                    newMat.isDoubleSided = true
                    newMat.transparencyMode = .aOne 
                    newMat.writesToDepthBuffer = true
                    newMat.blendMode = .replace
                    
                    newMaterials.append(newMat)
                }
                geo.materials = newMaterials
            }
        }
        
        // --- STEP 4: SCALE & PIVOT ---
        let (min, max) = wrapper.boundingBox
        if min.x.isFinite && max.x.isFinite {
            let h = max.y - min.y
            if h > 0 {
                if h > 5 || h < 0.2 {
                    let s = 1.8 / Float(h)
                    wrapper.scale = SCNVector3(s, s, s)
                    print("⚖️ Auto-scaled by \(s) (Measured height: \(h))")
                }
                let centerX = (max.x + min.x) / 2
                let centerZ = (max.z + min.z) / 2
                wrapper.pivot = SCNMatrix4MakeTranslation(centerX, min.y, centerZ)
            }
        }
        
        wrapper.position = SCNVector3(0, 0, 0)
        return wrapper
    }
}
