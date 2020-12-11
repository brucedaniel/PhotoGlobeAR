import ARKit
import UIKit

extension PhotoGlobeARView: ARCoachingOverlayViewDelegate {
  func addCoaching() {
    self.coachingOverlay.delegate = self
    self.coachingOverlay.session = self.session
    self.coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    self.coachingOverlay.goal = .horizontalPlane
    
    self.addSubview(self.coachingOverlay)
  }
  public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    coachingOverlayView.activatesAutomatically = false
    self.addGlobe()
  }
}
