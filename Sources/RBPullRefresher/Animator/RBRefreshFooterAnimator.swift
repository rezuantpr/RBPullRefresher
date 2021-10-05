import UIKit

open class RBRefreshFooterAnimator: UIView, RBRefreshProtocol, RBRefreshAnimatorProtocol {
  open var view: UIView { return self }
  open var duration: TimeInterval = 0.3
  open var insets: UIEdgeInsets = UIEdgeInsets.zero
  open var trigger: CGFloat = 42.0
  open var executeIncremental: CGFloat = 42.0
  open var state: RBRefreshViewState = .pullToRefresh
  
  fileprivate let indicatorView: UIActivityIndicatorView = {
    let indicatorView = UIActivityIndicatorView.init(style: .gray)
    indicatorView.isHidden = true
    return indicatorView
  }()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    isHidden = true
    addSubview(indicatorView)
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
    // do nothing
  }
  
  open func refresh(view: RBRefreshComponent, stateDidChange state: RBRefreshViewState) {
    guard self.state != state else {
      return
    }
    self.state = state
    
    self.setNeedsLayout()
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    let s = self.bounds.size
    let w = s.width
    let h = s.height
    
    indicatorView.center = CGPoint.init(x: w / 2.0 - 18.0, y: h / 2.0 - 5.0)
  }
}
