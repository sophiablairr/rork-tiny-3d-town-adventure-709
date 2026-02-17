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
    var interactionTargetNode: SCNNode? = nil
    
    // Check for interactions based on player position and orientation
    func checkInteractions(player: SCNNode, scene: SCNScene) {
        // 1. Raycast forward from player to see if we're facing something
        // 2. Check distance to specific "Trigger" nodes in the scene
        
        // Simple distance check implementation for now
        // We will look for nodes with specific names or prefixes
        
        let playerPos = player.presentation.position
        var closestDist: Float = 2.0 // Interaction range
        var foundType: InteractionType = .none
        var foundName: String? = nil
        var foundNode: SCNNode? = nil
        
        // Scan for interactables
        scene.rootNode.enumerateChildNodes { (node, stop) in
            // Check if node is relevant
            if let name = node.name {
                let dist = distance(node.position, playerPos)
                
                if dist < closestDist {
                    if name.hasPrefix("NPC_") {
                        closestDist = dist
                        foundType = .talk
                        foundName = String(name.dropFirst(4)) // Remove "NPC_" prefix
                        foundNode = node
                    } else if name.hasPrefix("Door_") {
                        closestDist = dist
                        foundType = .enter
                        foundName = String(name.dropFirst(5))
                        foundNode = node
                    } else if name.hasPrefix("Exit_") {
                        closestDist = dist
                        foundType = .exit
                        foundName = String(name.dropFirst(5))
                        foundNode = node
                    }
                }
            }
        }
        
        // Update state
        if foundType != .none {
            activeInteraction = foundType
            interactionTargetName = foundName
            interactionTargetNode = foundNode
        } else {
            activeInteraction = .none
            interactionTargetName = nil
            interactionTargetNode = nil
        }
    }
    
    private func distance(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        let dx = a.x - b.x
        let dy = a.y - b.y
        let dz = a.z - b.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
}
