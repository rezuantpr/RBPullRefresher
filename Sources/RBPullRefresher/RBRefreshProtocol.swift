import UIKit

public enum RBRefreshViewState {
  case pullToRefresh
  case releaseToRefresh
  case refreshing
  case autoRefreshing
  case noMoreData
}

public protocol RBRefreshProtocol {
  
  /**
   Refresh operation begins execution method
   You can refresh your animation logic here, it will need to start the animation each time a refresh
   */
  mutating func refreshAnimationBegin(view: RBRefreshComponent)
  
  /**
   Refresh operation stop execution method
   Here you can reset your refresh control UI, such as a Stop UIImageView animations or some opened Timer refresh, etc., it will be executed once each time the need to end the animation
   */
  mutating func refreshAnimationEnd(view: RBRefreshComponent)
  
  /**
   Pulling status callback , progress is the percentage of the current offset with trigger, and avoid doing too many tasks in this process so as not to affect the fluency.
   */
  mutating func refresh(view: RBRefreshComponent, progressDidChange progress: CGFloat)
  
  mutating func refresh(view: RBRefreshComponent, stateDidChange state: RBRefreshViewState)
}


public protocol RBRefreshAnimatorProtocol {
  
  // The view that called when component refresh, returns a custom view or self if 'self' is the customized views.
  var view: UIView {get}
  
  // Customized inset.
  var insets: UIEdgeInsets {set get}
  
  // Refresh event is executed threshold required y offset, set a value greater than 0.0, the default is 60.0
  var trigger: CGFloat {set get}
  
  // Offset y refresh event executed by this parameter you can customize the animation to perform when you refresh the view of reservations height
  var executeIncremental: CGFloat {set get}
  
  // Current refresh state, default is .pullToRefresh
  var state: RBRefreshViewState {set get}
  
}

