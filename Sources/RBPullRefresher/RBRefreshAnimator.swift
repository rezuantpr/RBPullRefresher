import UIKit

open class RBRefreshAnimator: RBRefreshProtocol, RBRefreshAnimatorProtocol {
  // The view that called when component refresh, returns a custom view or self if 'self' is the customized views.
  open var view: UIView
  // Customized inset.
  open var insets: UIEdgeInsets
  // Refresh event is executed threshold required y offset, set a value greater than 0.0, the default is 60.0
  open var trigger: CGFloat = 60.0
  // Offset y refresh event executed by this parameter you can customize the animation to perform when you refresh the view of reservations height
  open var executeIncremental: CGFloat = 60.0
  // Current refresh state, default is .pullToRefresh
  open var state: RBRefreshViewState = .pullToRefresh
  
  public init() {
    view = UIView()
    insets = UIEdgeInsets.zero
  }
  
  open func refreshAnimationBegin(view: RBRefreshComponent) {
    /// Do nothing!
  }
  
  open func refreshAnimationWillEnd(view: RBRefreshComponent) {
    /// Do nothing!
  }
  
  open func refreshAnimationEnd(view: RBRefreshComponent) {
    /// Do nothing!
  }
  
  open func refresh(view: RBRefreshComponent, progressDidChange progress: CGFloat) {
    /// Do nothing!
  }
  
  open func refresh(view: RBRefreshComponent, stateDidChange state: RBRefreshViewState) {
    /// Do nothing!
  }
}
