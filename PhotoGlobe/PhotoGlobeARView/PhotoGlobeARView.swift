import RealityKit
import ARKit
import Combine

struct GameData {
  var dimensions: SIMD2<Int> = [4,4]
  var cardsFound: Int = 0
  var totalCards: Int {
    dimensions[0] * dimensions[1]
  }
}

class PhotoGlobeARView: ARView, ARSessionDelegate {
  let coachingOverlay = ARCoachingOverlayView()
  var tableAdded = false

  var status: GameStatus = .initCoaching {
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
        // Do something with the new transform
        //let currentTransform = frame.camera.transform
        //print(currentTransform)
    }
    
  // MARK: - Touch Gesture Variables
  var touchStartedOn: FlipCard? = nil
  var currentlyFlipped: FlipCard? = nil
  var canTap = true
  var flipTable: FlipTable? = nil
  var confirmButton: ARButton?
  var installedGestures: [EntityGestureRecognizer] = []

  var waitForAnchor: Cancellable?

  var gameData = GameData()

  /// Add the FlipTable object
  func addFlipTable() {
    
  
      self.flipTable = FlipTable()
      self.tableAdded = true
      self.status = .planeSearching

      // Subscribe to the AnchoredStateChanged event for flipTable
      self.waitForAnchor = self.scene.subscribe(
        to: SceneEvents.AnchoredStateChanged.self,
        on: flipTable
      ) { event in
        if event.isAnchored {
          self.status = .positioning
          DispatchQueue.main.async {
            self.waitForAnchor?.cancel()
            self.waitForAnchor = nil
          }
        }
      }
    self.scene.anchors.append(flipTable!)
   
  }
 
}
