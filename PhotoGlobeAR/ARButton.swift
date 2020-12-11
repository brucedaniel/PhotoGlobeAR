import RealityKit

class ARButton: Entity, HasCollision, HasModel {
  var tapAction: (() -> Void)?

  init(transform: Transform, model: ModelComponent, tapAction: (() -> Void)? = nil) {
    self.tapAction = tapAction
    super.init()
    self.model = model
    self.transform = transform
    self.generateCollisionShapes(recursive: false)
  }

  required init() {
    super.init()
  }
}
