import SceneKit
import SwiftUI

enum InteractionType {
    case talk
    case enter
    case exit
    case none
    
    var prompt: String {
        switch self {
        case .talk: return "Talk"
        case .enter: return "Enter"
        case .exit: return "Exit"
        case .none: return ""
        }
    }
}

@Observable
class InteractionManager {
    var activeInteraction: InteractionType = .none
    var interactionTargetName: String? = nil

    // Track frame count to throttle checks
    @ObservationIgnored private var frameCount: Int = 0
    
    // Called from SceneKit render thread — must dispatch UI updates to main thread
    func checkInteractions(player: SCNNode, scene: SCNScene) {
        // Throttle: only check every 10 frames
        frameCount += 1
        guard frameCount % 10 == 0 else { return }
        
        let playerWorldPos = player.presentation.worldPosition
        var closestDist: Float = 3.0 // Interaction range
        var foundType: InteractionType = .none
        var foundName: String? = nil
        
        // Scan for interactable nodes by name prefix
        scene.rootNode.enumerateChildNodes { (node, _) in
            guard let name = node.name else { return }
            
            // Only check nodes with our interaction prefixes
            guard name.hasPrefix("NPC_") || name.hasPrefix("Door_") || name.hasPrefix("Exit_") else { return }
            
            // Use world position for accurate distance
            let nodeWorldPos = node.presentation.worldPosition
            let dist = self.distance(nodeWorldPos, playerWorldPos)
            
            if dist < closestDist {
                if name.hasPrefix("NPC_") {
                    closestDist = dist
                    foundType = .talk
                    foundName = String(name.dropFirst(4))
                } else if name.hasPrefix("Door_") {
                    closestDist = dist
                    foundType = .enter
                    foundName = String(name.dropFirst(5))
                } else if name.hasPrefix("Exit_") {
                    closestDist = dist
                    foundType = .exit
                    foundName = String(name.dropFirst(5))
                }
            }
        }
        
        // Dispatch state updates to main thread to avoid race condition with SwiftUI
        let newType = foundType
        let newName = foundName
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.activeInteraction = newType
            self.interactionTargetName = newName
        }
    }
    
    private func distance(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        let dx = a.x - b.x
        let dy = a.y - b.y
        let dz = a.z - b.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
}
