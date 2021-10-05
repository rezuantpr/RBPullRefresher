import UIKit

fileprivate class RBRefreshImpacter {
  static private var impacter: AnyObject? = {
    if NSClassFromString("UIFeedbackGenerator") != nil {
      let generator = UIImpactFeedbackGenerator(style: .light)
      generator.prepare()
      return generator
    }
    return nil
  }()
  
  static public func impact() -> Void {
    if let impacter = impacter as? UIImpactFeedbackGenerator {
      impacter.impactOccurred()
    }
  }
}

public protocol RBRefreshImpactProtocol {}

public extension RBRefreshImpactProtocol {
  func impact() -> Void {
    RBRefreshImpacter.impact()
  }
}
