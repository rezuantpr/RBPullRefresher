import QuartzCore
import UIKit

open class RBRefreshHeaderAnimator: UIView, RBRefreshProtocol, RBRefreshAnimatorProtocol, RBRefreshImpactProtocol {
  
  open var view: UIView { return self }
  open var insets: UIEdgeInsets = UIEdgeInsets.zero
  open var trigger: CGFloat = 60.0
  open var executeIncremental: CGFloat = 60.0
  open var state: RBRefreshViewState = .pullToRefresh
  
  fileprivate let indicatorView: UIActivityIndicatorView = {
    let indicatorView = UIActivityIndicatorView.init(style: .gray)
    indicatorView.isHidden = true
    return indicatorView
  }()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.isHidden = true
    self.addSubview(indicatorView)
  }
  
  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func refreshAnimationBegin(view: RBRefreshComponent) {
    indicatorView.startAnimating()
    indicatorView.isHidden = false
  }
  
  open func refreshAnimationEnd(view: RBRefreshComponent) {
    indicatorView.stopAnimating()
    indicatorView.isHidden = true
  }
  
  open func refresh(view: RBRefreshComponent, progressDidChange progress: CGFloat) {
    // Do nothing
  }
  
  open func refresh(view: RBRefreshComponent, stateDidChange state: RBRefreshViewState) {
    guard self.state != state else {
      return
    }
    self.state = state
    
    switch state {
    case .refreshing, .autoRefreshing:
      self.setNeedsLayout()
    case .releaseToRefresh:
      self.setNeedsLayout()
      self.impact()
    case .pullToRefresh:
      self.setNeedsLayout()
    default:
      break
    }
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    let s = self.bounds.size
    let w = s.width
    let h = s.height
    
    UIView.performWithoutAnimation {
      indicatorView.center = CGPoint.init(x: titleLabel.frame.origin.x - 16.0, y: h / 2.0)
    }
  }
  
}
