import RealityKit

enum GameStatus {
  case initCoaching
  case planeSearching
  case positioning
  case playing
  case finished
}

extension CardFlipARView {

  func changedFromPositioningStatus() {
    self.flipTable?.collision = nil
    self.confirmButton?.removeFromParent()
    self.installedGestures = self.installedGestures.filter({ (recogniser) -> Bool in
      recogniser.isEnabled = false
      return false
    })
  }
  func setToPositioningStatus() {
    guard let table = self.flipTable else {
      return
    }
    table.collision = CollisionComponent(shapes: [.generateBox(size: [4, 0.4, 4])])
    self.installedGestures.append(
      contentsOf: self.installGestures([.all], for: table)
    )

  }
}
