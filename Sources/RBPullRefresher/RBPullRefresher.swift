import UIKit

public protocol RBPullRefresherExtensionsProvider: AnyObject {
  associatedtype CompatibleType
  var refresher: CompatibleType { get }
}

extension RBPullRefresherExtensionsProvider {
  public var refresher: RBPullRefresher<Self> {
    return RBPullRefresher(self)
  }
}

public struct RBPullRefresher<Base> {
  public let base: Base
  
  fileprivate init(_ base: Base) {
    self.base = base
  }
}

extension UIScrollView: RBPullRefresherExtensionsProvider {}

