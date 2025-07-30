//
//  DetectHoleVC.swift
//  Reflection Windows
//
//  Created by Pranay Barua on 16/04/25.
//

import UIKit
import RealityKit
import ARKit
import simd

class DetectHoleVC: UIViewController, ARSessionDelegate, XIBed {

    @IBOutlet weak var arView: ARView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup ARView
//        arView = ARView(frame: view.bounds)
//        view.addSubview(arView)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        arView.session.delegate = self
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: arView)
        checkForHole(at: tapLocation)
    }

    func checkForHole(at screenPoint: CGPoint) {
        // Try to raycast to any vertical surface (like a wall)
        let results = arView.raycast(from: screenPoint, allowing: .estimatedPlane, alignment: .vertical)

        if let result = results.first {
            print("Surface detected at: \(result.worldTransform.columns.3)")
            // Optionally place something here if you want to visualize hits
            // Estimate a position 0.5m in front of the camera
            let cameraTransform = arView.cameraTransform
            let cameraPosition = cameraTransform.translation
            let forward = -cameraTransform.matrix.columns.2.xyz
            let estimatedHolePosition = cameraPosition + forward * 0.5

            placeObject2(at: estimatedHolePosition)
        } else {
            print("No surface hit — possible hole")

            // Estimate a position 0.5m in front of the camera
            let cameraTransform = arView.cameraTransform
            let cameraPosition = cameraTransform.translation
            let forward = -cameraTransform.matrix.columns.2.xyz
            let estimatedHolePosition = cameraPosition + forward * 0.5

            placeObject(at: estimatedHolePosition)
        }
    }

    func placeObject(at position: SIMD3<Float>) {
        let sphere = MeshResource.generateSphere(radius: 0.03)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let entity = ModelEntity(mesh: sphere, materials: [material])

        let anchor = AnchorEntity(world: position)
        anchor.addChild(entity)
        arView.scene.anchors.append(anchor)
//        do {
//        // Load your USDZ model
//               let modelEntity = try Entity.loadModel(named: "New.usdz")
//
//               // Optional: scale the model if needed
//                modelEntity.scale = SIMD3<Float>(0.5, 0.5, 0.5)
//
//               // Create an anchor at the given position
//               let anchor = AnchorEntity(world: position)
//               anchor.addChild(modelEntity)
//
//               // Add the anchor to the scene
//               arView.scene.anchors.append(anchor)
//           } catch {
//               print("❌ Failed to load model: \(error)")
//           }
    }
    
    @IBAction func backBtnTap(_ sender: UIButton) {
        self.closeARSession()
    }
    
    func placeObject2(at position: SIMD3<Float>) {
        let sphere = MeshResource.generateSphere(radius: 0.03)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let entity = ModelEntity(mesh: sphere, materials: [material])

        let anchor = AnchorEntity(world: position)
        anchor.addChild(entity)
        arView.scene.anchors.append(anchor)
    }
    
    func closeARSession() {
        guard arView.session.configuration != nil else { return }

        // Step 1: Pause the AR session safely
                
        print("✅ AR session paused. Cleaning up objects...")

        // Step 2: Delay node removal to avoid conflict with rendering
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.arView.scene.rootNode.enumerateChildNodes { (node, _) in
            self.arView.session.pause()  // Stop AR session
            self.arView.scene.anchors.removeAll()
            self.navigationController?.popViewController(animated: false)
//            }
            print("✅ AR session closed and all objects removed.")
            
        }
    }
}

// Helper to convert matrix translation
extension simd_float4x4 {
    var translation: SIMD3<Float> {
        let translation = columns.3
        return SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}

// Helper to get xyz vector from simd_float4
extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}
