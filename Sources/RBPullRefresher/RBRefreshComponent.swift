import UIKit

public typealias RBRefreshHandler = (() -> ())

open class RBRefreshComponent: UIView {
  
  open weak var scrollView: UIScrollView?
  
  /// @param handler Refresh callback method
  open var handler: RBRefreshHandler?
  
  /// @param animator Animated view refresh controls, custom must comply with the following two protocol
  open var animator: (RBRefreshProtocol & RBRefreshAnimatorProtocol)!
  
  /// @param refreshing or not
  fileprivate var _isRefreshing = false
  open var isRefreshing: Bool {
    get {
      return _isRefreshing
    }
  }
  
  /// @param auto refreshing or not
  fileprivate var _isAutoRefreshing = false
  open var isAutoRefreshing: Bool {
    get {
      return _isAutoRefreshing
    }
  }
  
  /// @param tag observing
  fileprivate var isObservingScrollView = false
  fileprivate var isIgnoreObserving = false
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin]
  }
  
  public convenience init(frame: CGRect, handler: @escaping RBRefreshHandler) {
    self.init(frame: frame)
    self.handler = handler
    self.animator = RBRefreshAnimator.init()
  }
  
  public convenience init(frame: CGRect, handler: @escaping RBRefreshHandler, animator: RBRefreshProtocol & RBRefreshAnimatorProtocol) {
    self.init(frame: frame)
    self.handler = handler
    self.animator = animator
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    removeObserver()
  }
  
  open override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    /// Remove observer from superview immediately
    self.removeObserver()
    DispatchQueue.main.async { [weak self, newSuperview] in
      /// Add observer to new superview in next runloop
      self?.addObserver(newSuperview)
    }
  }
  
  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    self.scrollView = self.superview as? UIScrollView
    if let _ = animator {
      let v = animator.view
      if v.superview == nil {
        let inset = animator.insets
        self.addSubview(v)
        v.frame = CGRect.init(x: inset.left,
                              y: inset.right,
                              width: self.bounds.size.width - inset.left - inset.right,
                              height: self.bounds.size.height - inset.top - inset.bottom)
        v.autoresizingMask = [
          .flexibleWidth,
          .flexibleTopMargin,
          .flexibleHeight,
          .flexibleBottomMargin
        ]
      }
    }
  }
  
  // MARK: - Action
  
  public final func startRefreshing(isAuto: Bool = false) -> Void {
    guard isRefreshing == false && isAutoRefreshing == false else {
      return
    }
    
    _isRefreshing = !isAuto
    _isAutoRefreshing = isAuto
    
    self.start()
  }
  
  public final func stopRefreshing() -> Void {
    guard isRefreshing == true || isAutoRefreshing == true else {
      return
    }
    
    self.stop()
  }
  
  public func start() {
    
  }
  
  public func stop() {
    _isRefreshing = false
    _isAutoRefreshing = false
  }
  
  //  ScrollView contentSize change action
  public func sizeChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
    
  }
  
  //  ScrollView offset change action
  public func offsetChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
    
  }  
}

extension RBRefreshComponent /* KVO methods */ {
  fileprivate static var context = "RBRefreshKVOContext"
  fileprivate static let offsetKeyPath = "contentOffset"
  fileprivate static let contentSizeKeyPath = "contentSize"
  
  public func ignoreObserver(_ ignore: Bool = false) {
    if let scrollView = scrollView {
      scrollView.isScrollEnabled = !ignore
    }
    isIgnoreObserving = ignore
  }
  
  fileprivate func addObserver(_ view: UIView?) {
    if let scrollView = view as? UIScrollView, !isObservingScrollView {
      scrollView.addObserver(self, forKeyPath: RBRefreshComponent.offsetKeyPath, options: [.initial, .new], context: &RBRefreshComponent.context)
      scrollView.addObserver(self, forKeyPath: RBRefreshComponent.contentSizeKeyPath, options: [.initial, .new], context: &RBRefreshComponent.context)
      isObservingScrollView = true
    }
  }
  
  fileprivate func removeObserver() {
    if let scrollView = superview as? UIScrollView, isObservingScrollView {
      scrollView.removeObserver(self, forKeyPath: RBRefreshComponent.offsetKeyPath, context: &RBRefreshComponent.context)
      scrollView.removeObserver(self, forKeyPath: RBRefreshComponent.contentSizeKeyPath, context: &RBRefreshComponent.context)
      isObservingScrollView = false
    }
  }
  
  override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if context == &RBRefreshComponent.context {
      guard isUserInteractionEnabled == true && isHidden == false else {
        return
      }
      if keyPath == RBRefreshComponent.contentSizeKeyPath {
        if isIgnoreObserving == false {
          sizeChangeAction(object: object as AnyObject?, change: change)
        }
      } else if keyPath == RBRefreshComponent.offsetKeyPath {
        if isIgnoreObserving == false {
          offsetChangeAction(object: object as AnyObject?, change: change)
        }
      }
    } else {
      
    }
  }
  
}

