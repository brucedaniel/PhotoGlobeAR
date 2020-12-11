import RealityKit
import ARKit
import Combine

class PhotoGlobeARView: ARView, ARSessionDelegate {
  let coachingOverlay = ARCoachingOverlayView()
  var tableAdded = false
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.setup()
        
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.setup()
    }
    
    private func setup() {
        self.enableRealityUIGestures(.all)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        self.session.run(config, options: [])

        self.addCoaching()
        self.session.delegate = self
        self.debugOptions.insert([.showSceneUnderstanding, .showWorldOrigin, .showAnchorOrigins])
    }
    
  var status: SessionStatus = .initCoaching {
    didSet {
      switch oldValue {
      case .positioning:
        changedFromPositioningStatus()
      default:
        break
        //print("status was: \(status)")
      }
      switch status {
      case .positioning:
        setToPositioningStatus()
      default:
        break
        //print("status is: \(status)")
      }
    }
  }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
  
    }
    
  // MARK: - Touch Gesture Variables
  var canTap = true
  var globe: PhotoGlobe? = nil
  var installedGestures: [EntityGestureRecognizer] = []

  var waitForAnchor: Cancellable?

  func addGlobe() {
    
  
      self.globe = PhotoGlobe()
      self.tableAdded = true
      self.status = .planeSearching

      self.waitForAnchor = self.scene.subscribe(
        to: SceneEvents.AnchoredStateChanged.self,
        on: globe
      ) { event in
        if event.isAnchored {
          self.status = .positioning
          DispatchQueue.main.async {
            self.waitForAnchor?.cancel()
            self.waitForAnchor = nil
          }
        }
      }
    self.scene.anchors.append(globe!)
   
  }
 
}
