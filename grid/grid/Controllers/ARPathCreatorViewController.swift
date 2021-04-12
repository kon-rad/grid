/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import ARKit
import FirebaseStorage
import simd

class ARPathCreatorViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - IBOutlets
    
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var takeImageButton: RoundedButton!
    @IBOutlet weak var takeDestinationImageButton: RoundedButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var snapshotThumbnail: UIImageView!
    @IBOutlet weak var succesCheckmark: UIImageView!
    
    var pathId: String?
    var isCreatingPath: Bool = true
    var isLoadingData: Bool = true
    var startPointSnapshotAnchor: SnapshotAnchor?
    var destinationSnapshotAnchor: SnapshotAnchor?
    
    var delegate: ARPathCreatorViewControllerDelegate?
    
    // MARK: - View Life Cycle
    
    // Lock the orientation of the app to the orientation in which it is launched
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        succesCheckmark.isHidden = true
        
        if !isCreatingPath {
            self.loadExperience()
            self.saveButton.isHidden = true
            self.takeImageButton.isHidden = true
            self.takeDestinationImageButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If theho app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Start the view's AR session.
        sceneView.session.delegate = self
        sceneView.session.run(defaultConfiguration)
        sceneView.debugOptions = [ .showFeaturePoints ]
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func generateFlatDisk() -> SCNNode {
        let disk = SCNCylinder(radius: 0.05, height: 0.001);
        let diskNode = SCNNode()
        diskNode.position.y += Float(disk.radius)
        diskNode.geometry = disk
        disk.firstMaterial?.diffuse.contents = UIColor(red: 0.08, green: 0.61, blue: 0.92, alpha: 1.00)
        disk.firstMaterial?.lightingModel = .lambert
        disk.firstMaterial?.transparency = 0.80
        disk.firstMaterial?.transparencyMode = .dualLayer
        disk.firstMaterial?.fresnelExponent = 0.80
        disk.firstMaterial?.reflective.contents = UIColor(white:0.00, alpha:1.0)
        disk.firstMaterial?.specular.contents = UIColor(white:0.00, alpha:1.0)
        disk.firstMaterial?.shininess = 0.80
        return diskNode
    }
    // This is not used currently because could not get the arrow to point exactly away from the phone.
    // Leaving this here in case want to return this feature.
    func generateArrowNode() -> SCNNode {
        let vertcount = 48;
        let verts: [Float] = [ -1.4923, 1.1824, 2.5000, -6.4923, 0.000, 0.000, -1.4923, -1.1824, 2.5000, 4.6077, -0.5812, 1.6800, 4.6077, -0.5812, -1.6800, 4.6077, 0.5812, -1.6800, 4.6077, 0.5812, 1.6800, -1.4923, -1.1824, -2.5000, -1.4923, 1.1824, -2.5000, -1.4923, 0.4974, -0.9969, -1.4923, 0.4974, 0.9969, -1.4923, -0.4974, 0.9969, -1.4923, -0.4974, -0.9969 ];

        let facecount = 13;
        let faces: [CInt] = [  3, 4, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 0, 1, 2, 3, 4, 5, 6, 7, 1, 8, 8, 1, 0, 2, 1, 7, 9, 8, 0, 10, 10, 0, 2, 11, 11, 2, 7, 12, 12, 7, 8, 9, 9, 5, 4, 12, 10, 6, 5, 9, 11, 3, 6, 10, 12, 4, 3, 11 ];

        let vertsData  = NSData(
            bytes: verts,
            length: MemoryLayout<Float>.size * vertcount
        )

        let vertexSource = SCNGeometrySource(data: vertsData as Data,
                                             semantic: .vertex,
                                             vectorCount: vertcount,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Float>.size * 3)

        let polyIndexCount = 61;
        let indexPolyData  = NSData( bytes: faces, length: MemoryLayout<CInt>.size * polyIndexCount )

        let element1 = SCNGeometryElement(data: indexPolyData as Data,
                                          primitiveType: .polygon,
                                          primitiveCount: facecount,
                                          bytesPerIndex: MemoryLayout<CInt>.size)

        let geometry1 = SCNGeometry(sources: [vertexSource], elements: [element1])

        let material1 = geometry1.firstMaterial!

        // grid color pallete dark blue
        material1.diffuse.contents = UIColor(red: 0.08, green: 0.61, blue: 0.92, alpha: 1.00)
        material1.lightingModel = .lambert
        material1.transparency = 1.00
        material1.transparencyMode = .dualLayer
        material1.fresnelExponent = 1.00
        material1.reflective.contents = UIColor(white:0.00, alpha:1.0)
        material1.specular.contents = UIColor(white:0.00, alpha:1.0)
        material1.shininess = 1.00

        //Assign the SCNGeometry to a SCNNode, for example:
        let aNode = SCNNode()
        aNode.geometry = geometry1
        aNode.scale = SCNVector3(0.021, 0.021, 0.021)
        return aNode
    }
    
    /// - Tag: RestoreVirtualContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor.name == virtualObjectAnchorName
            else { return }
        
        let flatDisk = generateFlatDisk()
        DispatchQueue.main.async {
            node.addChildNode(flatDisk)
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable Save button only when the mapping status is good and an object has been placed
        switch frame.worldMappingStatus {
            case .extending, .mapped:
                saveButton.isEnabled =
                    virtualObjectAnchor != nil
                        && frame.anchors.contains(virtualObjectAnchor!)
                        && self.startPointSnapshotAnchor != nil
                        && self.destinationSnapshotAnchor != nil
            default:
                saveButton.isEnabled = false
        }
        statusLabel.text = """
            Mapping: \(frame.worldMappingStatus.description)
            Tracking: \(frame.camera.trackingState.description)
            """
        for anchor in frame.anchors {
            if (anchor.name == self.virtualObjectAnchorName) {
                let distance = simd_distance(anchor.transform.columns.3, (sceneView.session.currentFrame?.camera.transform.columns.3)!);
                let arNode = sceneView.node(for: anchor)
                // display only disks that are within three meters of the viewer
                if (distance < 3) {
                    arNode?.isHidden = false
                } else {
                    arNode?.isHidden = true
                }
            }
        }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking(nil)
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    // MARK: - Persistence: Saving and Loading
    lazy var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }()
    
    @IBAction func onBackButtonPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onStartPointImagePress(_ sender: Any) {
        // Add a snapshot image indicating where the map was captured.
        guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
            else { fatalError("Can't take snapshot") }
        self.startPointSnapshotAnchor = snapshotAnchor
        self.succesCheckmark.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.succesCheckmark.isHidden = true
        }
    }
    @IBAction func onDestinationImagePress(_ sender: Any) {
        guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
            else { fatalError("Can't take snapshot") }
        self.destinationSnapshotAnchor = snapshotAnchor
        self.succesCheckmark.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.succesCheckmark.isHidden = true
        }
    }
    
    /// - Tag: GetWorldMap
    @IBAction func saveExperience(_ button: UIButton) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { self.showAlert(title: "Can't get current world map", message: error!.localizedDescription); return }
            
            // Add a snapshot image indicating where the map was captured.
            map.anchors.append(self.startPointSnapshotAnchor!)
            
            do {
                let worldMapData = try NSKeyedArchiver.archivedData(
                    withRootObject: map, requiringSecureCoding: true
                )
                self.delegate?.completedARWorldMapCreation(
                    worldMapData: worldMapData,
                    startImage: self.startPointSnapshotAnchor!.imageData,
                    endImage: self.destinationSnapshotAnchor!.imageData
                )
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
        }
        
    }
    
    func loadExperience() {
        guard self.pathId != nil else {
            return
        }
        let storage = Storage.storage()
        let mapRefrence = storage.reference(withPath: "worldMaps/\(self.pathId ?? "")")
        // 100 MB max
        mapRefrence.getData(maxSize: 100 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error while downloading map data: ", error)
                fatalError("Error while downloading map data")
            }
            let worldMap: ARWorldMap = { () -> ARWorldMap in
                do {
                    guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data!)
                        else { fatalError("No ARWorldMap in archive.") }
                    
                    return worldMap
                } catch {
                    fatalError("Can't unarchive ARWorldMap from file data: \(error)")
                }
            }()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // delay by 0.5 seconds for cases where user has a high speed internet connection
                // the session update will have opportunity to run
                self.setWorldMap(worldMap: worldMap)
            }
        }
    }
    
    func setWorldMap(worldMap: ARWorldMap) {
        // Display the snapshot image stored in the world map to aid user in relocalizing.
        if let snapshotData = worldMap.snapshotAnchor?.imageData,
            let snapshot = UIImage(data: snapshotData) {
            self.snapshotThumbnail.image = snapshot
            self.snapshotThumbnail.layer.cornerRadius = 8.0
            self.snapshotThumbnail.clipsToBounds = true
            self.snapshotThumbnail.layer.masksToBounds = true
        } else {
            print("No snapshot image in world map")
        }
        // Remove the snapshot anchor from the world map since we do not need it in the scene.
        worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })
        
        let configuration = self.defaultConfiguration // this app's standard world tracking settings
        configuration.initialWorldMap = worldMap
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        self.isRelocalizingMap = true
        self.virtualObjectAnchor = nil
        self.isLoadingData = false
    }
    
    // Called opportunistically to verify that map data can be loaded from filesystem.
    var mapDataFromFile: Data? {
        return try? Data(contentsOf: mapSaveURL)
    }

    // MARK: - AR session management
    
    var isRelocalizingMap = false

    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        if #available(iOS 13.0, *), ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth)  {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            print("people occlusion is not supported")
        }
        return configuration
    }
    
    @IBAction func resetTracking(_ sender: UIButton?) {
        sceneView.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        isRelocalizingMap = false
        virtualObjectAnchor = nil
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        var message: String = ""
        
        snapshotThumbnail.isHidden = true
        switch (trackingState, frame.worldMappingStatus) {
            case (.normal, .mapped),
                 (.normal, .extending):
                if frame.anchors.contains(where: { $0.name == virtualObjectAnchorName }) {
                    if (!isCreatingPath) {
                        message = "Follow the disks to the destination"
                    } else {
                        // User has placed an object in scene and the session is mapped, prompt them to save the experience
                        message = "Tap 'Save Path' to save the current path"
                    }
                } else {
                    if (isCreatingPath) {
                        message = "Tap on the screen to place a disk"
                    } else {
                        message = "Move around to map the environment"
                    }
                }
                
            case (.normal, _) where mapDataFromFile != nil && !isRelocalizingMap:
                message = "Move around to map the environment"
                
            case (.normal, _) where mapDataFromFile == nil:
                message = "Move around to map the environment"
                
            case (.limited(.relocalizing), _) where isRelocalizingMap:
                message = "Move your device to the location shown in the image"
                snapshotThumbnail.isHidden = false
                
            default:
                message = trackingState.localizedFeedback
        }
        if (isLoadingData && !isCreatingPath) {
            message = "Downloading data"
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    // MARK: - Placing AR Content
    
    /// - Tag: PlaceObject
    @IBAction func handleSceneTap(_ sender: UITapGestureRecognizer) {
        // Disable placing objects when the session is still relocalizing
        if isRelocalizingMap && virtualObjectAnchor == nil {
            return
        }
        // Hit test to find a place for a virtual object.
        guard let hitTestResult = sceneView
            .hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first
            else { return }
        // 04/10/2021 - no longer doing arrows, rotation is not necessary - changed to disks
        // rotate to be the same direction as the phone and rotate the 3D arrow an additional 90 degrees (- 1.5708 radians)
        // so that it is not perpendicular, as it's default orientation
//        let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y - 1.5708, 0, 1, 0))
//        let rotateTransform = simd_mul(hitTestResult.worldTransform, rotate)
//        print("scene tap: name is ", virtualObjectAnchorName)

        virtualObjectAnchor = ARAnchor(name: virtualObjectAnchorName, transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: virtualObjectAnchor!)
    }

    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"
}

protocol ARPathCreatorViewControllerDelegate {
    func completedARWorldMapCreation(worldMapData: Data, startImage: Data, endImage: Data)
}
