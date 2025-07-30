//
//  ARViewController.swift
//  Reflection Windows
//
//  Created by Pranay Barua on 20/02/25.
//

import UIKit
//import SceneKit
import ARKit
import RealityKit
import SVProgressHUD

class ARViewController: UIViewController, XIBed {
    
//    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var placeWindowBtn: UIButton!
    @IBOutlet weak var saveToGalleryBtn: UIButton!
    @IBOutlet weak var place3DWindowBtn: UIButton!
    @IBOutlet weak var arView: ARView!
    
//    var arView: ARView!
    var isWindowAdded = false
    var imageNode: SCNNode? // Global reference to store the placed image
    var modelEntity: Entity?
    var path = ""
    var viewfinderEntity: ModelEntity?
    var planeIndicatorEntity: ModelEntity?
    var viewfinder: UIView!
    var depthLabel: UILabel!
    var initialTouchSide: String? = nil
    var productModelURL = ""
    
    private var noWallLabel: UILabel = {
        let label = UILabel()
        label.text = "No wall detected. Try again!"
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.alpha = 0 // Start hidden
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        
        self.backBtn.layer.cornerRadius = 12.0
        self.placeWindowBtn.layer.cornerRadius = 12.0
        self.saveToGalleryBtn.layer.cornerRadius = 12.0
        self.place3DWindowBtn.layer.cornerRadius = 12.0
        // Add label to the view
        noWallLabel.frame = CGRect(x: 50, y: 150, width: self.view.frame.width - 100, height: 40)
        self.view.addSubview(noWallLabel)
        setupArkit()
    }
    
    func setupArkit(){
        downloadModel()
        arView.automaticallyConfigureSession = false
        arView.session.pause()
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .none  // Instead of .manual
        configuration.planeDetection = [.vertical]
        configuration.isLightEstimationEnabled = false  // Disable light estimation
        
        self.arView.renderOptions = [.disableAREnvironmentLighting]
//        arView.debugOptions = [.showFeaturePoints]
//        arView.session.run(configuration)
        arView.automaticallyConfigureSession = false
        
        // Run the new configuration **without** resetting tracking
            arView.session.run(configuration, options: [])
//        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        // Add pinch gesture recognizer for zooming
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
//        setupViewfinder()
        addViewfinder()
        addDepthLabel()
        // 5. Start Depth Checking
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkDepth), userInfo: nil, repeats: true)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        arView.addGestureRecognizer(panGesture)
        
        let toMoveGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTranslationGesture(_:)))
        toMoveGesture.minimumNumberOfTouches = 2 // Use two fingers for translation to differentiate from rotation
        arView.addGestureRecognizer(toMoveGesture)
        
        let StretchGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStretchGesture(_:)))
        StretchGesture.minimumNumberOfTouches = 3
        arView.addGestureRecognizer(StretchGesture)
    }
//    func setupArkit() {
//        downloadModel()
//        addViewfinder()
//        addDepthLabel()
//        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkDepth), userInfo: nil, repeats: true)
//        arView.automaticallyConfigureSession = false
//        arView.session.pause()
//        
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.environmentTexturing = .none  // ⬅️ Changed from .manual
//        configuration.planeDetection = [.vertical]
//        configuration.isLightEstimationEnabled = false  // ⬅️ Disable light estimation
//        
//        self.arView.renderOptions = [
//            .disableAREnvironmentLighting,
//            .disableHDR,
//            .disableMotionBlur,
//            .disableDepthOfField
//        ]  // ⬅️ Expanded render options
//        
//        arView.session.run(configuration, options: [])
//        // ... rest of your setup code ...
//    }
    
    func addDimDirectionalLight() {
        let lightEntity = Entity()
        let lightComponent = DirectionalLightComponent(
            color: .white,
            intensity: 10000,  // Lower intensity to avoid spotlight-like effect
            isRealWorldProxy: false
        )
        lightEntity.look(at: SIMD3<Float>(0, -1, -1), from: SIMD3<Float>(0, 2, 2), relativeTo: nil)
        lightEntity.components[DirectionalLightComponent.self] = lightComponent

        let lightAnchor = AnchorEntity(world: SIMD3<Float>(2, 0, 0)) // Position above scene
        lightAnchor.addChild(lightEntity)
        arView.scene.addAnchor(lightAnchor)
    }
    
    func addViewfinder() {
        //        let size: CGFloat = 200 // Viewfinder size
        
        viewfinder = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 250))
        viewfinder.layer.borderColor = UIColor.white.cgColor
        viewfinder.layer.borderWidth = 2
        viewfinder.backgroundColor = UIColor.clear
        viewfinder.center = view.center
        
        view.addSubview(viewfinder)
    }
    
    func addDepthLabel() {
        depthLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 140, height: 240))
        depthLabel.textColor = .white
        //          depthLabel.backgroundColor = .black.withAlphaComponent(0.5)
        depthLabel.textAlignment = .center
        depthLabel.font = UIFont.boldSystemFont(ofSize: 16)
        viewfinder.addSubview(depthLabel)
    }
    
//    @objc func checkDepth() {
//        guard let raycastResult = arView.raycast(from: viewfinder.center, allowing: .estimatedPlane, alignment: .any).first else {
//            depthLabel.text = "Depth: N/A"
//            return
//        }
//        
//        let depth = raycastResult.worldTransform.position.z
//        depthLabel.text = String(format: "Depth: %.2f m", depth)
//        
//        // Hide viewfinder when depth is detected
//        if depth < 2.0 { // Example: Hide if object is within 2 meters
//            viewfinder.isHidden = true
//        }
//    }
    
    @objc func checkDepth() {
        let screenCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        // Perform a raycast to detect vertical planes (walls)
        guard let raycastResult = arView.raycast(from: screenCenter, allowing: .existingPlaneGeometry, alignment: .vertical).first else {
            depthLabel.text = "Wall not found"
            return
        }
        
        // Compute distance from camera to wall
        let cameraPosition = arView.cameraTransform.translation
        let hitTransform = raycastResult.worldTransform
        let hitPosition = SIMD3<Float>(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
        
        let distance = simd_distance(cameraPosition, hitPosition)
        depthLabel.text = String(format: "Distance: %.2f m", distance)
        
        // Hide viewfinder when close to the wall
        if distance < 1.0 {  // Example: Hide if wall is within 1 meter
            depthLabel.isHidden = false
        } else {
            depthLabel.isHidden = true
        }
    }
    
//    func showPlaneIndicator(at hitResult: ARRaycastResult) {
//        if planeIndicatorEntity == nil {
//            // Create a semi-transparent green plane
//            let mesh = MeshResource.generatePlane(width: 0.2, depth: 0.2)
//            let material = SimpleMaterial(color: UIColor.green.withAlphaComponent(0.5), isMetallic: false)
//            planeIndicatorEntity = ModelEntity(mesh: mesh, materials: [material])
//
//            // Create an anchor to attach the entity
//            let anchorEntity = AnchorEntity(world: hitResult.worldTransform.translation)
//            anchorEntity.addChild(planeIndicatorEntity!)
//            arView.scene.addAnchor(anchorEntity)
//        }
//        
//        // Update the indicator position
//        planeIndicatorEntity?.transform.translation = hitResult.worldTransform.translation
//
//        // Optional: Add a subtle animation for better feedback
//        planeIndicatorEntity?.transform.scale = SIMD3<Float>(1.05, 1.05, 1.0)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.planeIndicatorEntity?.transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)
//        }
//    }

    
    func setupViewfinder() {
        let mesh = MeshResource.generatePlane(width: 1.0, depth: 1.0)
        let material = SimpleMaterial(color: UIColor.blue.withAlphaComponent(0.5), isMetallic: false)
        viewfinderEntity = ModelEntity(mesh: mesh, materials: [material])
        viewfinderEntity?.isEnabled = false

        let anchor = AnchorEntity()
        anchor.addChild(viewfinderEntity!)
        arView.scene.addAnchor(anchor)
        
        startUpdatingViewfinder()
    }

    func startUpdatingViewfinder() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let wallPosition = self.raycastWall() else {
                self.viewfinderEntity?.isEnabled = false
                return
            }
            self.viewfinderEntity?.isEnabled = true
            self.viewfinderEntity?.transform.translation = wallPosition
        }
    }

    
//    func loadModel() {
//            do {
//                modelEntity = try Entity.loadModel(named: "cc_Window_1_Green.usdz")
//                // Create an anchor entity at the detected plane's position
////                // Rotate the model 90 degrees around the Y-axis
////                let rotationAngle = -Float.pi / 2 // 90 degrees in radians
////                let rotationAxis = SIMD3<Float>(1, 0, 0) // Y-axis
////                let rotation = simd_quatf(angle: rotationAngle, axis: rotationAxis)
////                modelEntity!.transform.rotation = rotation
////                
////                let anchorEntity = AnchorEntity(world: transform)
////                // Add the model to the anchor entity
////                anchorEntity.addChild(modelEntity!)
////                // Add the anchor entity to the scene
////                arView.scene.addAnchor(anchorEntity)
//                
//                let anchorEntity = AnchorEntity(world: [0, -0.5, -2]) // 1 meter in front of the camera
//                anchorEntity.addChild(modelEntity!)
//                arView.scene.addAnchor(anchorEntity)
//            } catch {
//                print("Failed to load model: \(error.localizedDescription)")
//            }
//        }
    
//    private func downloadModel() {
//        SVProgressHUD.show()
//        let url = URL(string: "https://reflectionwindow.s3.us-east-2.amazonaws.com/images/products/2/3/2/16/ar.usdz")
//        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let destinationUrl = documentsUrl.appendingPathComponent(url!.lastPathComponent)
//        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "GET"
//        let downloadTask = session.downloadTask(with: request, completionHandler: { (location:URL?, response:URLResponse?, error:Error?) -> Void in
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: destinationUrl.path) {
//                try! fileManager.removeItem(atPath: destinationUrl.path)
//            }
//            try! fileManager.moveItem(atPath: location!.path, toPath: destinationUrl.path)
//            self.path = destinationUrl.path
//            SVProgressHUD.dismiss()
//        })
//        downloadTask.resume()
//    }
    private func downloadModel() {
        SVProgressHUD.show(withStatus: "Downloading model...")

        guard let url = URL(string: self.productModelURL) else {
            print("❌ Invalid URL")
            return
        }

        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20  // ⏳ Set a timeout of 30 seconds

        let session = URLSession(configuration: .default)
        let downloadTask = session.downloadTask(with: request) { (location, response, error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()

                if let error = error {
                    print("❌ Download failed: \(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "Download failed. Please try again.")
                    return
                }

                guard let location = location else {
                    print("❌ Download failed: No file location")
                    SVProgressHUD.showError(withStatus: "Download failed.")
                    return
                }

                let fileManager = FileManager.default
                do {
                    if fileManager.fileExists(atPath: destinationUrl.path) {
                        try fileManager.removeItem(at: destinationUrl)
                    }
                    try fileManager.moveItem(at: location, to: destinationUrl)
                    self.path = destinationUrl.path
                    print("✅ Model downloaded successfully to: \(destinationUrl.path)")
                    SVProgressHUD.showSuccess(withStatus: "Download complete!")
                } catch {
                    print("❌ Error saving file: \(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "Failed to save model.")
                }
            }
        }

        downloadTask.resume()

        // ⏳ Dismiss after 30 seconds if download takes too long
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if SVProgressHUD.isVisible() {
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Download took too long. Check your internet.")
                downloadTask.cancel()  // Cancel the request
            }
        }
    }
    
    func loadUszdModel(path: String) {
        guard var wallPosition = raycastWall() else {
            print("❌ No wall detected in front.")
            
            // Show label with animation
            UIView.animate(withDuration: 0.3) {
                self.noWallLabel.alpha = 1
            }
            
            // Hide label after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.3) {
                    self.noWallLabel.alpha = 0
                }
            }
            return
        }

        // Hide label if wall is found
        noWallLabel.alpha = 0
        wallPosition.y -= 0.5
        let url = URL(fileURLWithPath: path)

        DispatchQueue.main.async {
            do {
                let object = try Entity.load(contentsOf: url) // ✅ Load model
                object.scale = SIMD3<Float>(0.5, 0.5, 0.5)
                
                // Apply UnlitMaterial
                if let modelEntity = object as? ModelEntity {
                    let unlitMaterial = UnlitMaterial(color: .white) // Use white or any color
                    modelEntity.model?.materials = [unlitMaterial]
                }

                let anchor = AnchorEntity(world: wallPosition) // ✅ Place model at wall
                anchor.addChild(object)
                
                self.arView.scene.addAnchor(anchor)
                self.modelEntity = object
                self.isWindowAdded = true
                
                DispatchQueue.main.async {
                    self.viewfinder.isHidden = true
                    SVProgressHUD.dismiss()
                }
                
            } catch {
                SVProgressHUD.dismiss()
                print("Fail to load entity: \(error.localizedDescription)")
            }
        }
    }
    
    private func raycastWall() -> SIMD3<Float>? {
        guard let frame = arView.session.currentFrame else { return nil }
        
        let center = arView.center // Get the center point of the screen
        let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .vertical)
        
        guard let firstResult = results.first else { return nil }
        
        return firstResult.worldTransform.position // Extract position correctly
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let modelEntity = modelEntity else { return }
        
        // Get the current scale of the model
        let currentScale = modelEntity.scale
        
        // Calculate the new scale based on the pinch gesture
        let newScale = currentScale * Float(gesture.scale)
        
        // Apply the new scale to the model
        modelEntity.scale = newScale
        
        // Reset the gesture scale to 1 to avoid exponential scaling
        gesture.scale = 1
    }
        
//    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
//        guard let modelEntity = modelEntity else { return }
//        
//        // Get the current rotation of the model
//        let currentRotation = modelEntity.transform.rotation
//        
//        // Calculate the new rotation based on the rotation gesture
//        let newRotation = simd_quatf(angle: Float(gesture.rotation), axis: [0, 1, 0]) // Rotate around the Y-axis
//        
//        // Apply the new rotation to the model
//        modelEntity.transform.rotation = newRotation * currentRotation
//        
//        // Reset the gesture rotation to 0 to avoid exponential rotation
//        gesture.rotation = 0
//    }
//    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
//        guard let modelEntity = modelEntity else { return }
//        
//        switch gesture.state {
//        case .began, .changed:
//            // Get the current rotation
//            let currentRotation = modelEntity.transform.rotation
//            
//            // Get rotation angles from the gesture
//            let rotationX = Float(gesture.rotation) * 0.5  // Adjust factor for smoothness
//            let rotationY = Float(gesture.velocity) * 0.01 // Y-axis based on velocity
//            
//            // Create rotation quaternions
//            let newRotationX = simd_quatf(angle: rotationX, axis: [1, 0, 0]) // X-axis rotation
//            let newRotationY = simd_quatf(angle: rotationY, axis: [0, 1, 0]) // Y-axis rotation
//            
//            // Combine rotations
//            modelEntity.transform.rotation = newRotationX * newRotationY * currentRotation
//            
//            // Reset gesture rotation to avoid exponential rotations
//            gesture.rotation = 0
//
//        default:
//            break
//        }
//    }

    
//    func addLightToModel() {
//        //        // Create a point light
//        //        let light = PointLight()
//        //
//        //        // Set light properties
//        //        light.light.intensity = 1000 // Brightness of the light
//        //        light.light.color = .white // Light color
//        //
//        //        // Position the light (e.g., 1 meter above the model)
//        //        light.position = [0, 1, 0] // Adjust as needed
//        //
//        //        // Add the light to the model's parent entity (or anchor entity)
//        //        if let modelEntity = modelEntity {
//        //            modelEntity.addChild(light)
//        //        }
////        let spotLight = CustomSpotLight()
////        let lightAnchor = AnchorEntity(world: [1,1,1])
////        lightAnchor.addChild(spotLight)
////        arView.scene.anchors.append(lightAnchor)
//        // Create an anchor to hold the light
//        let lightAnchor = AnchorEntity(world: SIMD3<Float>(0, 2, 0)) // Position above scene
//
//        // Create a directional light
//        let directionalLight = Entity()
//        let lightComponent = DirectionalLightComponent(
//            color: .white,
//            intensity: 10000,  // Adjust brightness
//            isRealWorldProxy: false
//        )
//
//        // Set the direction (e.g., from top-left to bottom-right)
//        directionalLight.look(at: SIMD3<Float>(0, -1, -1), from: SIMD3<Float>(0, 1, 1), relativeTo: nil)
//
//        // Assign the component
//        directionalLight.components[DirectionalLightComponent.self] = lightComponent
//
//        // Add light to anchor and scene
//        lightAnchor.addChild(directionalLight)
//        arView.scene.addAnchor(lightAnchor)
//    }
    
//    func addDirectionalLight() {
//        // Create a directional light
//        let light = DirectionalLight()
//        
//        // Set light properties
//        light.light.intensity = 10000 // Brightness of the light
//        light.light.color = .red // Light color
//        
//        // Set the light's orientation (e.g., shining from the top-left)
//        light.orientation = simd_quatf(angle: .pi / 4, axis: [1, -1, 0])
//        
//        // Add the light to the scene
//        let anchorEntity = AnchorEntity(world: [0, 0, 0])
//        anchorEntity.addChild(light)
//        arView.scene.addAnchor(anchorEntity)
//    }
    
//    func addSpotLight() {
//        // Create a spot light
//        let light = SpotLight()
//        
//        // Set light properties
//        light.light.intensity = 1000 // Brightness of the light
//        light.light.color = .white // Light color
//        light.light.innerAngleInDegrees = .pi / 6 // Inner cone angle
//        light.light.outerAngleInDegrees = .pi / 4 // Outer cone angle
//        
//        // Position the light (e.g., 1 meter above and in front of the model)
//        light.position = [0, 1, -1] // Adjust as needed
//        
//        // Orient the light to point at the model
//        light.look(at: [0, 0, 0], from: light.position, relativeTo: nil)
//        
//        // Add the light to the scene
//        let anchorEntity = AnchorEntity(world: [0, 0, 0])
//        anchorEntity.addChild(light)
//        arView.scene.addAnchor(anchorEntity)
//    }
}

//class CustomSpotLight: Entity, HasSpotLight {
//    required init() {
//        super.init()
//        self.light = SpotLightComponent(color: .white,
//                                    intensity: 2500000,
//                          innerAngleInDegrees: 70,
//                          outerAngleInDegrees: 120,
//                            attenuationRadius: 9.0)
//        self.shadow = SpotLightComponent.Shadow()
//        self.position.y = 5.0
//        self.orientation = simd_quatf(angle: -.pi/1.5,
//                                       axis: [1,0,0])
//    }
//}

extension simd_float4x4 {
    var position: SIMD3<Float> {
        return SIMD3(x: columns.3.x, y: columns.3.y, z: columns.3.z)
    }
}

extension ARViewController {
    
    @IBAction func onBackBtnTap(_ sender: UIButton) {
        self.closeARSession()
    }
    
    @IBAction func onPlace3DWindowBtnTap(_ sender: UIButton) {
//        self.placeWindow()
    }
    
    @IBAction func onPlaceWindowBtnTap(_ sender: UIButton) {
//        placeImageInAR(imageName: "awning oper left", sceneView: sceneView)
//        placeImageInCenter(imageName: "awning oper left", sceneView: sceneView)
//        self.placeWindow()
//        self.loadModel()
        if depthLabel.isHidden {
            
            if isWindowAdded {
                SVProgressHUD.show()
                print("Window already added. Ignoring touch.")
                isWindowAdded = false
                
                print("✅ AR session paused. Cleaning up objects...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.arView.scene.anchors.removeAll()
                    print("✅ AR session closed and all objects removed.")
                    
                    self.loadUszdModel(path: self.path)
                }
            }
            loadUszdModel(path: self.path)
        } else {
            depthLabel.text = "Please keep minimum 1 meter distance from wall"
        }
    }
    
    @IBAction func onSaveShareBtnTap(_ sender: UIButton) {
//        captureAndShareScreenshot(from: sceneView, in: self)
        captureAndShareScreenshot(from: arView, in: self)
    }
}



//MARK: Arkit Delegate Method...
extension ARViewController: ARSCNViewDelegate {
    
//    func placeWindow(){
//        if isWindowAdded {
//            print("Window already added. Ignoring touch.")
//            return // Exit if a window is already added
//        }
//        guard let query = sceneView.raycastQuery(from: sceneView.center, allowing: .existingPlaneGeometry, alignment: .vertical) else { return }
//            let results = sceneView.session.raycast(query)
//            
//        if let hitResults = results.first {
////            updateWallDetectionUI(detected: true) // Show UI message
////            showPlaneIndicator(at: hitResults)
//            let windowScene = SCNScene(named: "art.scnassets/Window_1_Green.scn")!
//            print("hitResults : \(hitResults)")
//
//            // Create a parent node to hold both "Glass" and "Window"
//            let parentNode = SCNNode()
////            parentNode.position = SCNVector3(
////                x: hitResults.worldTransform.columns.3.x,
////                y: -0.4, //hitResults.worldTransform.columns.3.y,
////                z: hitResults.worldTransform.columns.3.z
////            )
//            
//            // Extract the normal of the wall
//            let normal = SCNVector3(
//                x: hitResults.worldTransform.columns.2.x,
//                y: hitResults.worldTransform.columns.2.y,
//                z: hitResults.worldTransform.columns.2.z
//            )
//
//            // Define a small depth offset
//            let depthOffset: Float = -0.1
//
//            // Adjust position
//            parentNode.position = SCNVector3(
//                x: hitResults.worldTransform.columns.3.x + normal.x * depthOffset,
//                y: -0.03, //hitResults.worldTransform.columns.3.y + normal.y * depthOffset,
//                z: hitResults.worldTransform.columns.3.z + normal.z * depthOffset
//            )
//
//            // Align the window rotation with the wall
////            parentNode.simdOrientation = simd_quatf(hitResults.worldTransform)
//
//            // Load the "Window" node
////            if let windowNode = windowScene.rootNode.childNode(withName: "Window", recursively: true) {
////                parentNode.addChildNode(windowNode)
//                if let glassNode = windowScene.rootNode.childNode(withName: "window_1_green", recursively: true) {
//                    parentNode.addChildNode(glassNode)
//                    sceneView.scene.rootNode.addChildNode(parentNode)
////                    imageNode = parentNode
//                    isWindowAdded = true // Set flag to true after adding the window
//                    print("Window with glass added successfully.")
//                } else {
//                    print("Glass node not found")
//                }
//                
////            } else {
////                print("Window node not found")
////            }
//
////                // Load the "Glass" node
////                if let glassNode = windowScene.rootNode.childNode(withName: "Glass", recursively: true) {
////                    parentNode.addChildNode(glassNode)
////                } else {
////                    print("Glass node not found")
////                }
//            
//            // Rotate to face the camera properly
////                parentNode.eulerAngles.z = .pi / 2
//
//            // Add parentNode to the scene
//            
//        } else {
////            updateWallDetectionUI(detected: false) // Hide UI message
//        }
//        
////            if let hitResults = results.first {
////                
////            } else {
////                print("Not able to add glass.")
////            }
////        }
//    }
    
//    func loadUSDZModel() {
//        
//        if let path = Bundle.main.path(forResource: "sneaker_airforce", ofType: "usdz") {
//            print("✅ Model found at: \(path)")
//            
//            guard let scene = SCNScene(named: "sneaker_airforce.usdz") else {
//                print("Failed to load model: sneaker_airforce.usdz")
//                return
//            }
//            
////            // Clone the root node of the scene to manipulate it
//            let modelNode = scene.rootNode.clone()
//
//            // Position the model in front of the camera
//            modelNode.position = SCNVector3(0, -0.5, -2) // Adjust these values as needed
//
//            // Scale down the model (optional)
//            modelNode.scale = SCNVector3(0.5, 0.5, 0.5) // Adjust scaling as needed
//
//            // Add the model node to the scene
//            scene.rootNode.addChildNode(modelNode)
//
//            // Configure the scene view
////            sceneView.allowsCameraControl = true
//            sceneView.automaticallyUpdatesLighting = true
//
//            // Set the scene to the scene view
//            sceneView.scene = scene
//            
//        } else {
//            print("❌ Model not found!")
//        }
//
//    }
    
//    func showPlaneIndicator(at hitResults: ARRaycastResult) {
//        // Remove old indicators
//        sceneView.scene.rootNode.childNode(withName: "planeIndicator", recursively: true)?.removeFromParentNode()
//        
//        // Create a visual indicator (semi-transparent green box)
//        let indicator = SCNBox(width: 0.2, height: 0.2, length: 0.01, chamferRadius: 0)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.green.withAlphaComponent(0.5) // Semi-transparent
//        indicator.materials = [material]
//
//        let indicatorNode = SCNNode(geometry: indicator)
//        indicatorNode.name = "planeIndicator"
//        indicatorNode.position = SCNVector3(
//            x: hitResults.worldTransform.columns.3.x,
//            y: hitResults.worldTransform.columns.3.y,
//            z: hitResults.worldTransform.columns.3.z
//        )
//        
//        sceneView.scene.rootNode.addChildNode(indicatorNode)
//    }
//    
//    func updateWallDetectionUI(detected: Bool) {
//        DispatchQueue.main.async {
//            self.detectionLabel.isHidden = !detected
//        }
//    }
    
    
    // Add window in the center of the scene
//        private func addWindowInCenter() {
//            guard let windowScene = SCNScene(named: "art.scnassets/window_1Org.scn") else {
//                print("❌ Failed to load window scene")
//                return
//            }
//
//            // Create parent node to hold both window and glass
//            let parentNode = SCNNode()
//
//            // Position it slightly in front of the camera
//            parentNode.position = SCNVector3(0, -1.0, -3.0) // 1 meter in front
//
//            // Add the "Window" node
//            if let windowNode = windowScene.rootNode.childNode(withName: "Window", recursively: true) {
//                parentNode.addChildNode(windowNode)
//            } else {
//                print("❌ Window node not found")
//            }
//
//            // Add the "Glass" node
//            if let glassNode = windowScene.rootNode.childNode(withName: "Glass", recursively: true) {
//                parentNode.addChildNode(glassNode)
//            } else {
//                print("❌ Glass node not found")
//            }
//
//            // Add the window to the scene
//            sceneView.scene.rootNode.addChildNode(parentNode)
//            isWindowAdded = true
//            print("✅ Window with glass added in front of the camera.")
//        }

    // For a model with one or similar bounding box, Euler and position value
//    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        let touchLocation = sender.location(in: sceneView)
//        let hitTestResults = sceneView.hitTest(touchLocation, options: nil)
//
//        // Check if the pinch gesture hit any node
//        if let hitResult = hitTestResults.first {
//            let node = hitResult.node
//            let minScale: Float = 0.2
//            let maxScale: Float = 3.0
//
//
//            // Apply scaling based on the pinch scale
//            let scale = Float(sender.scale)
////            node.scale = SCNVector3(scale, scale, scale)
//
//            node.scale = SCNVector3(
//                max(minScale, min(maxScale, node.scale.x * scale)),
//                max(minScale, min(maxScale, node.scale.y * scale)),
//                max(minScale, min(maxScale, node.scale.z * scale))
//            )
//
//            // Reset the gesture's scale to avoid exponential scaling
////            sender.scale = 1.0
//        }
//    }
    
//    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        let touchLocation = sender.location(in: sceneView)
//        let hitTestResults = sceneView.hitTest(touchLocation, options: nil)
//
//        if let hitResult = hitTestResults.first {
//            let node = hitResult.node
//
//            // Find the parent node that contains both Glass and Window
//            guard let parentNode = node.parent else { return }
//
//            let minScale: Float = 0.2
//            let maxScale: Float = 3.0
//
//            let scale = Float(sender.scale)
//
//            // Apply scaling to the parent node
//            parentNode.scale = SCNVector3(
//                max(minScale, min(maxScale, parentNode.scale.x * scale)),
//                max(minScale, min(maxScale, parentNode.scale.y * scale)),
//                max(minScale, min(maxScale, parentNode.scale.z * scale))
//            )
//
//            sender.scale = 1.0 // Reset scale to prevent exponential growth
//        }
//    }
//    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
////        guard let node = imageNode else { return }
//
//        // Scale the node based on pinch
//        let scale = Float(gesture.scale)
//        
//        // Set minimum and maximum zoom limits
//        let minScale: Float = 0.5   // 50% of original size
//        let maxScale: Float = 3.0   // 300% of original size
//        
////        let newScale = SCNVector3(
////            max(min(node.scale.x * scale, maxScale), minScale),
////            max(min(node.scale.y * scale, maxScale), minScale),
////            max(min(node.scale.z * scale, maxScale), minScale)
////        )
////        
////        node.scale = newScale
////        
//        // Reset gesture scale to avoid exponential growth
//        gesture.scale = 1.0
//    }
    
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//        guard let sceneView = self.sceneView else { return }
//        guard let node = imageNode else { return }
//
//        // Get the touch location on the screen
//        let touchLocation = gesture.location(in: sceneView)
//
//        // Convert touch location to a 3D position in AR space
//        let hitTestResults = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
//
//        if let result = hitTestResults.first {
//            let newPosition = SCNVector3(
//                result.worldTransform.columns.3.x,
//                node.position.y, // Keep the y-position the same
//                result.worldTransform.columns.3.z
//            )
//            node.position = newPosition // Move image node to the new position
//        }
//    }
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//        guard let sceneView = gesture.view as? ARSCNView else { return }
//        guard let node = imageNode else { return }
//
//        // Get the touch location in 2D screen space
//        let touchLocation = gesture.location(in: sceneView)
//
//        // Convert the touch location to a 3D world position
//        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
//        
//        if let result = hitTestResults.first {
//            let newPosition = SCNVector3(
//                result.worldTransform.columns.3.x,
//                result.worldTransform.columns.3.y,
//                result.worldTransform.columns.3.z
//            )
//            
//            // Smooth movement using SCNAction
//            let moveAction = SCNAction.move(to: newPosition, duration: 0.1)
//            node.runAction(moveAction)
//        }
//    }
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let modelEntity = modelEntity else { return }
                
        // Get the translation of the pan gesture
        let translation = gesture.translation(in: arView)
        
        // Adjust rotation sensitivity
        let rotationAmount = Float(translation.x) * 0.01 // Adjust the multiplier for sensitivity
        
        // Create a quaternion for rotation around the Y-axis
        let rotation = simd_quatf(angle: rotationAmount, axis: [0, 1, 0])
        
        // Apply the rotation to the model's transform
        modelEntity.transform.rotation = rotation * modelEntity.transform.rotation
        
        // Reset translation to prevent excessive rotation
        gesture.setTranslation(.zero, in: arView)
//        guard let modelEntity = modelEntity else { return }
//
//            // Get the translation of the pan gesture
//            let translation = gesture.translation(in: arView)
//            
//            // Adjust rotation sensitivity
//            let rotationY = Float(translation.x) * 0.01  // Horizontal pan → Y-axis rotation
//            let rotationX = Float(translation.y) * 0.01  // Vertical pan → X-axis rotation
//
//            // Create rotation quaternions
//            let rotationQuatX = simd_quatf(angle: rotationX, axis: [1, 0, 0])  // X-axis (up/down)
//            let rotationQuatY = simd_quatf(angle: rotationY, axis: [0, 1, 0])  // Y-axis (left/right)
//
//            // Combine rotations and apply to model
//            modelEntity.transform.rotation = rotationQuatX * rotationQuatY * modelEntity.transform.rotation
//
//            // Reset translation to prevent excessive rotation
//            gesture.setTranslation(.zero, in: arView)

    }
    
    @objc func handleTranslationGesture(_ gesture: UIPanGestureRecognizer) {
        guard let modelEntity = modelEntity else { return }

        // Get the translation in the view's coordinate system
        let translation = gesture.translation(in: arView)
        gesture.setTranslation(.zero, in: arView)

        // Convert the 2D translation to 3D movement
        let currentPosition = modelEntity.position
        let translationFactor: Float = 0.003 // Adjust this factor as needed
        let newPosition = SIMD3<Float>(
            currentPosition.x + Float(translation.x) * translationFactor,
            currentPosition.y - Float(translation.y) * translationFactor,
            currentPosition.z
        )

        // Apply the new position t1o the model entity
        modelEntity.position = newPosition
    }
    
//    @objc func handleStretchGesture(_ gesture: UIPanGestureRecognizer) {
//        guard let modelEntity = modelEntity else { return }
//
//        // Translation in 2D screen space
//        let translation = gesture.translation(in: arView)
//        gesture.setTranslation(.zero, in: arView)
//
//        // Determine dominant direction
//        let absX = abs(translation.x)
//        let absY = abs(translation.y)
//
//        // Stretch factor (tweak for sensitivity)
//        let stretchFactor: Float = 0.003
//
//        var newScale = modelEntity.scale
//
//        if absX > absY {
//            // Horizontal drag → stretch in X-axis
//            newScale.x += Float(translation.x) * stretchFactor
//        } else {
//            // Vertical drag → stretch in Y-axis
//            newScale.y -= Float(translation.y) * stretchFactor // subtract Y to align drag up = stretch up
//        }
//
//        // Clamp to avoid flipping or invalid values
//        newScale.x = max(0.1, newScale.x)
//        newScale.y = max(0.1, newScale.y)
//
//        modelEntity.scale = newScale
//    }
    @objc func handleStretchGesture(_ gesture: UIPanGestureRecognizer) {
        guard let modelEntity = modelEntity else { return }

        let translation = gesture.translation(in: arView)
        let location = gesture.location(in: arView)

        let stretchFactor: Float = 0.003

        var newScale = modelEntity.scale
        var newPosition = modelEntity.position

        switch gesture.state {
        case .began:
            // Determine whether the user touched the left or right side
            let modelScreenPosition = arView.project(modelEntity.position) ?? .zero
            if location.x < modelScreenPosition.x {
                initialTouchSide = "left"
            } else {
                initialTouchSide = "right"
            }

        case .changed:
            guard let side = initialTouchSide else { return }
            let delta = Float(translation.x) * stretchFactor
            gesture.setTranslation(.zero, in: arView)

            if side == "left" {
                // Stretch/squeeze only the left side
                let newScaleX = max(0.1, newScale.x - delta)
                let scaleChange = newScale.x - newScaleX
                newScale.x = newScaleX
                newPosition.x += scaleChange / 2  // move right to squeeze left
            } else if side == "right" {
                // Stretch/squeeze only the right side
                let newScaleX = max(0.1, newScale.x + delta)
                let scaleChange = newScaleX - newScale.x
                newScale.x = newScaleX
                newPosition.x += scaleChange / 2  // move right to stretch right
            }

            modelEntity.scale = newScale
            modelEntity.position = newPosition

        case .ended, .cancelled:
            initialTouchSide = nil

        default:
            break
        }
    }

    func closeARSession() {
        guard arView.session.configuration != nil else { return }

        // Step 1: Pause the AR session safely
//        arView.session.pause()
        isWindowAdded = false
                
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
    
    func restartARSession() {
        self.isWindowAdded = false
        print("AR session restarted.")
        self.setupArkit()
    }
    
//    func captureAndShareScreenshot(from arView: ARSCNView, in viewController: UIViewController) {
//        let image = arView.snapshot()
//        
//        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
//        
//        // iPad support
//        if let popoverController = activityVC.popoverPresentationController {
//            popoverController.sourceView = viewController.view
//            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX,
//                                                  y: viewController.view.bounds.midY,
//                                                  width: 0,
//                                                  height: 0)
//            popoverController.permittedArrowDirections = []
//        }
//        
//        viewController.present(activityVC, animated: true, completion: nil)
//    }
    func captureAndShareScreenshot(from arView: ARView, in viewController: UIViewController) {
        // Capture a screenshot of the ARView
        arView.snapshot(saveToHDR: false) { image in
            // Ensure the image is not nil
            guard let image = image else {
                print("Failed to capture screenshot.")
                return
            }
            
            // Switch to the main thread to update the UI
            DispatchQueue.main.async {
                // Create a UIActivityViewController to share the screenshot
                let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                
                // iPad support
                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceView = viewController.view
                    popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                                          y: viewController.view.bounds.midY,
                                                          width: 0,
                                                          height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                // Present the UIActivityViewController
                viewController.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    func placeImageInAR(imageName: String, sceneView: ARSCNView) {
        if isWindowAdded {
            print("Window already added. Ignoring touch.")
            return // Exit if a window is already added
        }
        let image = UIImage(named: imageName)
        
        guard let query = sceneView.raycastQuery(from: sceneView.center, allowing: .existingPlaneGeometry, alignment: .vertical) else { return }
            let results = sceneView.session.raycast(query)
            
            if let hitResults = results.first {
                print("hitResults : \(hitResults)")
                
                
                let plane = SCNPlane(width: 0.5, height: 0.5) // Adjust size as needed
                plane.firstMaterial?.diffuse.contents = image
                plane.firstMaterial?.isDoubleSided = true // To make it visible from both sides
                
                let planeNode = SCNNode(geometry: plane)
                planeNode.position = SCNVector3(0, 0, -0.5)
//                SCNVector3(
//                    x: hitResults.worldTransform.columns.3.x,
//                    y: hitResults.worldTransform.columns.3.y,
//                    z: hitResults.worldTransform.columns.3.z
//                )
                planeNode.eulerAngles.x = -.pi / 2 // Rotate to lay flat
                
                // Rotate the plane to be vertical
               planeNode.eulerAngles.x = 0  // Keep it upright
               planeNode.eulerAngles.y = 0  // No rotation needed
               planeNode.eulerAngles.z = 0  // No rotation needed
                
                sceneView.scene.rootNode.addChildNode(planeNode)
                isWindowAdded = true // Set flag to true after adding the window
                print("Window with glass added successfully.")
            }
    }
    
    func placeImageInCenter(imageName: String, sceneView: ARSCNView) {
        guard let image = UIImage(named: imageName) else {
            print("Image not found!")
            return
        }

        let plane = SCNPlane(width: 0.3, height: 0.4) // Adjust size
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided = true

        let planeNode = SCNNode(geometry: plane)
        
        if let currentFrame = sceneView.session.currentFrame {
            let cameraTransform = currentFrame.camera.transform
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5 // Place image 0.5m in front of camera
            let finalTransform = simd_mul(cameraTransform, translation)

            planeNode.simdTransform = finalTransform
        }
        
       planeNode.eulerAngles.x = -.pi / 2
        // Rotate the plane to be vertical
       planeNode.eulerAngles.x = 0  // Keep it upright
       planeNode.eulerAngles.y = 0  // No rotation needed
       planeNode.eulerAngles.z = 0  // No rotation needed

        sceneView.scene.rootNode.addChildNode(planeNode)
//        imageNode = planeNode // ✅ Store reference
    }

}
