import RealityKit
import ARKit
import Combine
import Photos

class PhotoGlobeARView: ARView, ARSessionDelegate {
    let coachingOverlay = ARCoachingOverlayView()
    var detectionReferances = Dictionary<ARReferenceImage,PHAsset>()
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        let status = PHPhotoLibrary.authorizationStatus()

        if (status != PHAuthorizationStatus.authorized) {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in })
        } else {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
            let photos = PHAsset.fetchAssets(with: fetchOptions)
                  
            let dispatch = DispatchGroup()
            
            for index in 0...20 {
                dispatch.enter()
                let asset = photos.object(at: index)
                let manager = PHImageManager.default()
                    let option = PHImageRequestOptions()
                option.isSynchronous = true
         
                manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    if let result = result {
                        //print("width: \(asset.pixelWidth)")
                        self.detectionReferances[ARReferenceImage(result.cgImage!, orientation: .up, physicalWidth: 0.3)] = asset
                        //print("ADDED DETECTION IMAGE")
                    }
                    dispatch.leave()
                })
                
                
            }
            
            dispatch.notify(queue: .main) {
                self.setup()
            }
        }
        
        
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.setup()
    }
    
    private func setup() {
        
        
        self.enableRealityUIGestures([.all])
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.detectionImages = Set(self.detectionReferances.keys)
        
        self.session.run(config, options: [])

        self.addCoaching()
        self.session.delegate = self
        //self.debugOptions.insert([.showSceneUnderstanding, .showWorldOrigin, .showAnchorOrigins])
        
       
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
  
    }
    
    let frontDepth = Float(0.01)
    let formatter = DateFormatter()
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let imageAnchor = anchor as? ARImageAnchor else { continue }
            
            let photo = Photo()
            photo.defaultCardSize = 0.25
            let newAnchor = AnchorEntity(anchor: imageAnchor)
            newAnchor.addChild(photo.base!)
            photo.asset = self.detectionReferances[imageAnchor.referenceImage]
            
            self.scene.addAnchor(newAnchor)
            
        }
        
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
    //self.addGlobe()
  }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        }
    }
}
extension UIImage.Orientation {
    init(_ cgOrientation: UIImage.Orientation) {
        switch cgOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        }
    }
}


class Ping: Entity, HasAnchoring, HasCollision {
}
