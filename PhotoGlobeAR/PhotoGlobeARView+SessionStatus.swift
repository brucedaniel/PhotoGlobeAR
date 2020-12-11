import RealityKit

enum SessionStatus {
  case initCoaching
  case planeSearching
  case positioning
  case playing
  case finished
}

extension PhotoGlobeARView {

  func changedFromPositioningStatus() {
    self.globe?.collision = nil
    self.installedGestures = self.installedGestures.filter({ (recogniser) -> Bool in
      recogniser.isEnabled = false
      return false
    })
  }
  func setToPositioningStatus() {
    guard let table = self.globe else {
      return
    }
    table.collision = CollisionComponent(shapes: [.generateBox(size: [4, 0.4, 4])])
    self.installedGestures.append(
      contentsOf: self.installGestures([.all], for: table)
    )

  }
}
