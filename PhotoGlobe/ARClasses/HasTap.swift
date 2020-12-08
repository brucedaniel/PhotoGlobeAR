import Foundation

protocol HasTap {
  var tapAction: (() -> Void)? { get set }
}
