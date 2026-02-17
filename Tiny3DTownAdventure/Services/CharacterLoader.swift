import SceneKit
import SwiftUI

class CharacterLoader {
    static func load(named name: String) -> SCNNode? {
        // --- DEBUG: LOG BUNDLE CONTENTS ---
        if let resourcePath = Bundle.main.resourcePath {
            let files = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath)) ?? []
            print("📁 Bundle files: \(files.joined(separator: ", "))")
        }
        
        let extensions = ["usdz", "scn", "dae", "obj"]
        var modelUrl: URL? = nil
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                modelUrl = url
                break
            }
        }
        
        guard let url = modelUrl else {
            print("❌ CharacterLoader: File '\(name)' NOT found in bundle.")
            return nil
        }
        
        print("✅ CharacterLoader: Found '\(url.lastPathComponent)'. Attempting to load...")
        
        let wrapper = SCNNode()
        wrapper.name = "CharacterRoot"
        
        // --- STRATEGY 1: SCNReferenceNode (Recommended for USDZ) ---
        print("🔄 Loading Strategy 1: SCNReferenceNode")
        let refNode = SCNReferenceNode(url: url)
        refNode.load()
        if refNode.childNodes.count > 0 || refNode.geometry != nil {
            print("✅ Strategy 1 Success!")
            wrapper.addChildNode(refNode)
        } else {
            print("⚠️ Strategy 1 failed (empty node), trying Strategy 2...")
            
            // --- STRATEGY 2: SCNScene(url:options:) ---
            print("🔄 Loading Strategy 2: SCNScene(url:)")
            do {
                let scene = try SCNScene(url: url, options: nil)
                for child in scene.rootNode.childNodes {
                    wrapper.addChildNode(child.clone())
                }
                if wrapper.childNodes.count > 0 {
                    print("✅ Strategy 2 Success!")
                } else {
                    print("⚠️ Strategy 2 yielded no nodes, trying Strategy 3...")
                }
            } catch {
                print("❌ Strategy 2 Error: \(error)")
            }
            
            // --- STRATEGY 3: SCNScene(named:) ---
            if wrapper.childNodes.count == 0 {
                let fullName = "\(name).\(url.pathExtension)"
                print("🔄 Loading Strategy 3: SCNScene(named: '\(fullName)')")
                if let scene = SCNScene(named: fullName) {
                    for child in scene.rootNode.childNodes {
                        wrapper.addChildNode(child.clone())
                    }
                    if wrapper.childNodes.count > 0 {
                        print("✅ Strategy 3 Success!")
                    }
                }
            }
        }
        
        guard wrapper.childNodes.count > 0 else {
            print("❌ CharacterLoader: All strategies failed to load any geometry for '\(name)'")
            return nil
        }
        
        // --- FIX VISIBILITY & MATERIALS ---
        print("🛠 Fixing materials and visibility for \(wrapper.childNodes.count) child nodes")
        wrapper.enumerateChildNodes { (child, _) in
            child.isHidden = false
            child.opacity = 1.0
            
            if let geo = child.geometry {
                for mat in geo.materials {
                    mat.isDoubleSided = true
                    mat.transparency = 1.0
                    mat.lightingModel = .blinn // More reliable than PBR
                    mat.metalness.intensity = 0.0 // Avoid invisible metallic surfaces
                    mat.roughness.intensity = 0.5
                    if mat.diffuse.contents == nil {
                        mat.diffuse.contents = UIColor.systemGray3
                    }
                }
            }
        }
        
        // --- AUTO-SCALE & CENTER ---
        let (minV, maxV) = wrapper.boundingBox
        let height = maxV.y - minV.y
        let width = maxV.x - minV.x
        let depth = maxV.z - minV.z
        let largestDim = max(height, max(width, depth))
        
        print("📐 Loaded mesh dims: W=\(width), H=\(height), D=\(depth)")
        
        if largestDim > 0 {
            let targetHeight: Float = 1.8
            let scale = targetHeight / largestDim
            wrapper.scale = SCNVector3(scale, scale, scale)
            let yOffset = -minV.y * scale
            wrapper.position.y = yOffset
            print("📐 Applied scale: \(scale), ground offset: \(yOffset)")
        }
        
        return wrapper
    }
}
