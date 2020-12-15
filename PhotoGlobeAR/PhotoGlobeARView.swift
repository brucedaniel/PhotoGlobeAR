import RealityKit
import ARKit
import Combine
import Photos

class PhotoGlobeARView: ARView, ARSessionDelegate {
  let coachingOverlay = ARCoachingOverlayView()
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.setup()
        
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.setup()
    }
    
    private func setup() {
        
        self.enableRealityUIGestures([.all])
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main)
        
        self.session.run(config, options: [])

        self.addCoaching()
        self.session.delegate = self
        //self.debugOptions.insert([.showSceneUnderstanding, .showWorldOrigin, .showAnchorOrigins])
        
        let status = PHPhotoLibrary.authorizationStatus()

        if (status != PHAuthorizationStatus.authorized) {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in })
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
  
    }
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let imageAnchor = anchors.first as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        print("found: \(referenceImage.name)")
    }
  var canTap = true
  var globe: PhotoGlobe? = nil

  var waitForAnchor: Cancellable?

    @IBAction func leftSwipe() {
        self.globe?.radialVelocity = -0.1
    }
    
    @IBAction func rightSwipe() {
        self.globe?.radialVelocity = 0.1
    }
    
  func addGlobe() {
      self.globe = PhotoGlobe(view: self)

      self.waitForAnchor = self.scene.subscribe(
        to: SceneEvents.AnchoredStateChanged.self,
        on: globe
      ) { event in
        if event.isAnchored {
          DispatchQueue.main.async {
            self.waitForAnchor?.cancel()
            self.waitForAnchor = nil
          }
        }
      }
    self.scene.anchors.append(globe!)
  }
}

extension PhotoGlobeARView: ARCoachingOverlayViewDelegate {
  func addCoaching() {
    self.coachingOverlay.delegate = self
    self.coachingOverlay.session = self.session
    self.coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    self.coachingOverlay.goal = .anyPlane
    self.coachingOverlay.frame = self.bounds
    self.addSubview(self.coachingOverlay)
  }
  public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    coachingOverlayView.activatesAutomatically = false
    self.addGlobe()
  }
}
