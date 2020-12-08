import SwiftUI
import RealityKit
import ARKit
import RealityUI

struct ContentView: View {
  var body: some View {
    return ARViewContainer().edgesIgnoringSafeArea(.all)
  }
}

/// This view is not currently used, instead the struct above is
struct ARViewContainer: UIViewRepresentable {
  func makeUIView(context: Context) -> CardFlipARView {

    let arView = CardFlipARView(frame: .zero)
    arView.enableRealityUIGestures(.all)
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = .horizontal
    arView.session.run(config, options: [])
    CardComponent.registerComponent()

    arView.addCoaching()
    arView.session.delegate = arView
    arView.debugOptions.insert([.showSceneUnderstanding, .showWorldOrigin, .showAnchorOrigins])
    return arView
  }
  func updateUIView(_ uiView: CardFlipARView, context: Context) {}

}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
