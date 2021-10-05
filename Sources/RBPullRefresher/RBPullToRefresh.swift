import UIKit

public enum Direction {
  case vertical
  case horizontal // ONLY FOR UICollectionView !
}

private var kRBRefreshHeaderKey: Void?
private var kRBRefreshFooterKey: Void?
private var kRBDirectionKey: Void?

public extension UIScrollView {
  
  var header: RBRefreshHeaderView? {
    get { return (objc_getAssociatedObject(self, &kRBRefreshHeaderKey) as? RBRefreshHeaderView) }
    set(newValue) { objc_setAssociatedObject(self, &kRBRefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
  }
  
  var footer: RBRefreshFooterView? {
    get { return (objc_getAssociatedObject(self, &kRBRefreshFooterKey) as? RBRefreshFooterView) }
    set(newValue) { objc_setAssociatedObject(self, &kRBRefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
  }
  
  var direction: Direction? {
    get { return (objc_getAssociatedObject(self, &kRBDirectionKey) as? Direction) ?? .vertical}
    set(newValue) { objc_setAssociatedObject(self, &kRBDirectionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
  }
  
}

public extension RBPullRefresher where Base: UIScrollView {
  @discardableResult
  func addPullToRefresh(handler: @escaping RBRefreshHandler) -> RBRefreshHeaderView {
    removeRefreshHeader()
    switch base.direction! {
    case .vertical:
      let header = RBRefreshHeaderView(direction: base.direction!, frame: CGRect.zero, handler: handler)
      let headerH = header.animator.executeIncremental
      header.frame = CGRect.init(x: 0.0,
                                 y: -headerH /* - contentInset.top */,
                                 width: base.bounds.size.width,
                                 height: headerH)
      base.addSubview(header)
      base.header = header
      return header
    case .horizontal:
      let header = RBRefreshHeaderView(direction: base.direction!, frame: CGRect.zero, handler: handler)
      let headerW = header.animator.executeIncremental
      header.frame = CGRect.init(x: -headerW,
                                 y: 0.0 /* - contentInset.top */,
                                 width: headerW,
                                 height: base.bounds.size.height)
      base.addSubview(header)
      base.header = header
      return header
    }
  }
  
  func set(_ direction: Direction) {
    assert(base is UICollectionView)
    base.direction = direction
  }
  
  @discardableResult
  func addInfiniteScrolling(handler: @escaping RBRefreshHandler) -> RBRefreshFooterView {
    removeRefreshFooter()
    switch base.direction! {
    case .horizontal:
      let footer = RBRefreshFooterView(direction: base.direction!, frame: CGRect.zero, handler: handler)
      let footerW = footer.animator.executeIncremental
      footer.frame = CGRect(x: base.contentSize.width + base.contentInset.right,
                            y: 0.0,
                            width: footerW,
                            height: base.bounds.size.height)
      base.addSubview(footer)
      base.footer = footer
      return footer
    case .vertical:
      let footer = RBRefreshFooterView(direction: base.direction!, frame: CGRect.zero, handler: handler)
      let footerH = footer.animator.executeIncremental
      footer.frame = CGRect(x: 0.0,
                            y: base.contentSize.height + base.contentInset.bottom,
                            width: base.bounds.size.width,
                            height: footerH)
      base.addSubview(footer)
      base.footer = footer
      return footer
    }
  }
  
  @discardableResult
  func addInfiniteScrolling(animator: RBRefreshProtocol & RBRefreshAnimatorProtocol, handler: @escaping RBRefreshHandler) -> RBRefreshFooterView {
    removeRefreshFooter()
    let footer = RBRefreshFooterView(direction: base.direction!, frame: CGRect.zero, handler: handler)
    let footerH = footer.animator.executeIncremental
    footer.frame = CGRect(x: 0.0, y: base.contentSize.height + base.contentInset.bottom, width: base.bounds.size.width, height: footerH)
    base.footer = footer
    base.addSubview(footer)
    return footer
  }
  
  /// Remove
  func removeRefreshHeader() {
    base.header?.stopRefreshing()
    base.header?.removeFromSuperview()
    base.header = nil
  }
  
  func removeRefreshFooter() {
    base.footer?.stopRefreshing()
    base.footer?.removeFromSuperview()
    base.footer = nil
  }
  
  /// Manual refresh
  func startPullToRefresh() {
    DispatchQueue.main.async { [weak base] in
      base?.header?.startRefreshing(isAuto: false)
    }
  }
  
  /// Auto refresh if expired.
  func autoPullToRefresh() {
    if self.base.expired == true {
      DispatchQueue.main.async { [weak base] in
        base?.header?.startRefreshing(isAuto: true)
      }
    }
  }
  
  /// Stop pull to refresh
  func stopPullToRefresh(ignoreDate: Bool = false, ignoreFooter: Bool = false) {
    self.base.header?.stopRefreshing()
    if ignoreDate == false {
      if let key = base.header?.refreshIdentifier {
        RBRefreshDataManager.sharedManager.setDate(Date(), forKey: key)
      }
      base.footer?.resetNoMoreData()
    }
    base.footer?.isHidden = ignoreFooter
  }
  
  /// Footer notice method
  func noticeNoMoreData() {
    base.footer?.stopRefreshing()
    base.footer?.noMoreData = true
  }
  
  func resetNoMoreData() {
    base.footer?.noMoreData = false
  }
  
  func stopLoadingMore() {
    base.footer?.stopRefreshing()
  }
}

public extension UIScrollView /* Date Manager */ {
  
  /// Identifier for cache expired timeinterval and last refresh date.
  var refreshIdentifier: String? {
    get { return header?.refreshIdentifier }
    set { header?.refreshIdentifier = newValue }
  }
  
  /// If you setted refreshIdentifier and expiredTimeInterval, return nearest refresh expired or not. Default is false.
  var expired: Bool {
    get {
      if let key = header?.refreshIdentifier {
        return RBRefreshDataManager.sharedManager.isExpired(forKey: key)
      }
      return false
    }
  }
  
  var expiredTimeInterval: TimeInterval? {
    get {
      if let key = header?.refreshIdentifier {
        let interval = RBRefreshDataManager.sharedManager.expiredTimeInterval(forKey: key)
        return interval
      }
      return nil
    }
    set {
      if let key = header?.refreshIdentifier {
        RBRefreshDataManager.sharedManager.setExpiredTimeInterval(newValue, forKey: key)
      }
    }
  }
  
  var lastRefreshDate: Date? {
    get {
      if let key = header?.refreshIdentifier {
        return RBRefreshDataManager.sharedManager.date(forKey: key)
      }
      return nil
    }
  }
}

open class RBRefreshHeaderView: RBRefreshComponent {
  fileprivate var previousOffset: CGFloat = 0.0
  fileprivate var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
  fileprivate var scrollViewBounces: Bool = true
  
  fileprivate var direction: Direction
  open var lastRefreshTimestamp: TimeInterval?
  open var refreshIdentifier: String?
  
  public init(direction: Direction, frame: CGRect, handler: @escaping RBRefreshHandler) {
    self.direction = direction
    super.init(frame: frame)
    self.handler = handler
    self.animator = RBRefreshHeaderAnimator.init()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    DispatchQueue.main.async {
      [weak self] in
      self?.scrollViewBounces = self?.scrollView?.bounces ?? true
      self?.scrollViewInsets = self?.scrollView?.contentInset ?? UIEdgeInsets.zero
    }
  }
  
  open override func offsetChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
    guard let scrollView = scrollView else {
      return
    }
    
    super.offsetChangeAction(object: object, change: change)
    
    guard self.isRefreshing == false && self.isAutoRefreshing == false else {
      switch direction {
      case .vertical:
        let top = scrollViewInsets.top
        let offsetY = scrollView.contentOffset.y
        let height = frame.size.height
        var scrollingTop = (-offsetY > top) ? -offsetY : top
        scrollingTop = (scrollingTop > height + top) ? (height + top) : scrollingTop
        
        scrollView.contentInset.top = scrollingTop
      case .horizontal:
        let left = scrollViewInsets.left
        let offsetX = scrollView.contentOffset.x
        let width = frame.size.width
        var scrollingLeft = (-offsetX > left ) ? -offsetX : left
        scrollingLeft = (scrollingLeft > width + left) ? (width + left) : scrollingLeft
        
        scrollView.contentInset.left = scrollingLeft
      }
      return
    }
    
    // Check needs re-set animator's progress or not.
    var isRecordingProgress = false
    defer {
      if isRecordingProgress == true {
        switch direction {
        case .vertical:
          let percent = -(previousOffset + scrollViewInsets.top) / self.animator.trigger
          self.animator.refresh(view: self, progressDidChange: percent)
        case .horizontal:
          let percent = -(previousOffset + scrollViewInsets.left) / self.animator.trigger
          self.animator.refresh(view: self, progressDidChange: percent)
        }
      }
    }
    
    switch direction {
    case .vertical:
      let offsets = previousOffset + scrollViewInsets.top
      if offsets < -self.animator.trigger {
        // Reached critical
        if isRefreshing == false && isAutoRefreshing == false {
          if scrollView.isDragging == false {
            // Start to refresh...
            self.startRefreshing(isAuto: false)
            self.animator.refresh(view: self, stateDidChange: .refreshing)
          } else {
            // Release to refresh! Please drop down hard...
            self.animator.refresh(view: self, stateDidChange: .releaseToRefresh)
            isRecordingProgress = true
          }
        }
      } else if offsets < 0 {
        // Pull to refresh!
        if isRefreshing == false && isAutoRefreshing == false {
          self.animator.refresh(view: self, stateDidChange: .pullToRefresh)
          isRecordingProgress = true
        }
      } else {
        // Normal state
      }
      
      previousOffset = scrollView.contentOffset.y
    case .horizontal:
      let offsets = previousOffset + scrollViewInsets.left
      if offsets < -self.animator.trigger {
        // Reached critical
        if isRefreshing == false && isAutoRefreshing == false {
          if scrollView.isDragging == false {
            // Start to refresh...
            self.startRefreshing(isAuto: false)
            self.animator.refresh(view: self, stateDidChange: .refreshing)
          } else {
            // Release to refresh! Please drop down hard...
            self.animator.refresh(view: self, stateDidChange: .releaseToRefresh)
            isRecordingProgress = true
          }
        }
      } else if offsets < 0 {
        // Pull to refresh!
        if isRefreshing == false && isAutoRefreshing == false {
          self.animator.refresh(view: self, stateDidChange: .pullToRefresh)
          isRecordingProgress = true
        }
      } else {
        // Normal state
      }
      
      previousOffset = scrollView.contentOffset.x
    }
  }
  
  open override func start() {
    guard let scrollView = scrollView else { return }
    
    self.ignoreObserver(true)
    
    scrollView.bounces = false
    
    super.start()
    
    self.animator.refreshAnimationBegin(view: self)

    switch direction {
    case .vertical:
      var insets = scrollView.contentInset
      self.scrollViewInsets.top = insets.top
      insets.top += animator.executeIncremental
      
      scrollView.contentInset = insets
      scrollView.contentOffset.y = previousOffset
      previousOffset -= animator.executeIncremental
      UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
        scrollView.contentOffset.y = -insets.top
      }, completion: { (finished) in
        self.handler?()
        self.ignoreObserver(false)
        scrollView.bounces = self.scrollViewBounces
      })
    case .horizontal:
      var insets = scrollView.contentInset
      self.scrollViewInsets.left = insets.left
      insets.left += animator.executeIncremental
      
      scrollView.contentInset = insets
      scrollView.contentOffset.x = previousOffset
      previousOffset -= animator.executeIncremental
      UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
        scrollView.contentOffset.x = -insets.left
      }, completion: { (finished) in
        self.handler?()
        self.ignoreObserver(false)
        scrollView.bounces = self.scrollViewBounces
      })
    }
  }
  
  open override func stop() {
    guard let scrollView = scrollView else {
      return
    }
    
    self.ignoreObserver(true)
    
    self.animator.refreshAnimationEnd(view: self)
        
    switch direction {
    case .vertical:
      scrollView.contentInset.top = scrollViewInsets.top
      scrollView.contentOffset.y = previousOffset
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
        scrollView.contentOffset.y = -self.scrollViewInsets.top
      }, completion: { (finished) in
        self.animator.refresh(view: self, stateDidChange: .pullToRefresh)
        super.stop()
        scrollView.contentInset.top = self.scrollViewInsets.top
        self.previousOffset = scrollView.contentOffset.y
        self.ignoreObserver(false)
      })
    case .horizontal:
      scrollView.contentInset.left = scrollViewInsets.left
      scrollView.contentOffset.x = previousOffset
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
        scrollView.contentOffset.x = -self.scrollViewInsets.left
      }, completion: { (finished) in
        self.animator.refresh(view: self, stateDidChange: .pullToRefresh)
        super.stop()
        scrollView.contentInset.left = self.scrollViewInsets.left
        self.previousOffset = scrollView.contentOffset.x
        // un-ignore observer
        self.ignoreObserver(false)
      })
    }
    
  }
  
}

open class RBRefreshFooterView: RBRefreshComponent {
  fileprivate var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
  var direction: Direction!
  
  open var noMoreData = false {
    didSet {
      if noMoreData != oldValue {
        self.animator.refresh(view: self, stateDidChange: noMoreData ? .noMoreData : .pullToRefresh)
      }
    }
  }
  
  open override var isHidden: Bool {
    didSet {
      switch direction! {
      case .vertical:
        
        if isHidden == true {
          scrollView?.contentInset.bottom = scrollViewInsets.bottom
          var rect = self.frame
          rect.origin.y = scrollView?.contentSize.height ?? 0.0
          self.frame = rect
        } else {
          scrollView?.contentInset.bottom = scrollViewInsets.bottom + animator.executeIncremental
          var rect = self.frame
          rect.origin.y = scrollView?.contentSize.height ?? 0.0
          self.frame = rect
        }
      case .horizontal:
        
        if isHidden == true {
          scrollView?.contentInset.right = scrollViewInsets.right
          var rect = self.frame
          rect.origin.x = scrollView?.contentSize.width ?? 0.0
          rect.origin.y = (scrollView?.bounds.height ?? 0) * 0.5
          self.frame = rect
        } else {
          scrollView?.contentInset.right = scrollViewInsets.right + animator.executeIncremental
          var rect = self.frame
          rect.origin.x = scrollView?.contentSize.width ?? 0.0
          rect.origin.y = (scrollView?.bounds.height ?? 0) * 0.5
          self.frame = rect
        }
      }
    }
  }
  
  public init(direction: Direction, frame: CGRect, handler: @escaping RBRefreshHandler) {
    self.direction = direction
    super.init(frame: frame)
    self.handler = handler
    self.animator = RBRefreshFooterAnimator(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    DispatchQueue.main.async {
      [weak self] in
      guard let self = self else { return }
      self.scrollViewInsets = self.scrollView?.contentInset ?? UIEdgeInsets.zero
      switch self.direction! {
      case .vertical:
        self.scrollView?.contentInset.bottom = self.scrollViewInsets.bottom + self.bounds.size.height
        var rect = self.frame
        rect.origin.y = self.scrollView?.contentSize.height ?? 0.0
        self.frame = rect
      case .horizontal:
        self.scrollView?.contentInset.right = self.scrollViewInsets.right + self.bounds.size.width
        var rect = self.frame
        rect.origin.x = self.scrollView?.contentSize.width ?? 0.0
        self.frame = rect
      }
    }
  }
  
  open override func sizeChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
    guard let scrollView = scrollView else { return }
    super.sizeChangeAction(object: object, change: change)
    switch direction! {
    case .vertical:
      let targetY = scrollView.contentSize.height + scrollViewInsets.bottom
      if frame.origin.y != targetY {
        var rect = frame
        rect.origin.y = targetY
        frame = rect
      }
    case .horizontal:
      let targetX = scrollView.contentSize.width + scrollViewInsets.right
      if frame.origin.x != targetX {
        var rect = frame
        rect.origin.x = targetX
        frame = rect
      }
    }
  }
  
  open override func offsetChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
    guard let scrollView = scrollView else {
      return
    }
    
    super.offsetChangeAction(object: object, change: change)
    
    guard isRefreshing == false &&
            isAutoRefreshing == false &&
            noMoreData == false &&
            isHidden == false else { return }
    
    switch direction! {
    case .vertical:
      if scrollView.contentSize.height <= 0.0 || scrollView.contentOffset.y + scrollView.contentInset.top <= 0.0 {
        self.alpha = 0.0
        return
      } else {
        self.alpha = 1.0
      }
      
      if scrollView.contentSize.height + scrollView.contentInset.top > scrollView.bounds.size.height {
        if scrollView.contentSize.height - scrollView.contentOffset.y + scrollView.contentInset.bottom  <= scrollView.bounds.size.height {
          animator.refresh(view: self, stateDidChange: .refreshing)
          startRefreshing()
        }
      } else {
        if scrollView.contentOffset.y + scrollView.contentInset.top >= animator.trigger / 2.0 {
          animator.refresh(view: self, stateDidChange: .refreshing)
          startRefreshing()
        }
      }
    case .horizontal:
      if scrollView.contentSize.width <= 0.0 || scrollView.contentOffset.x + scrollView.contentInset.left <= 0.0 {
        self.alpha = 0.0
        return
      } else {
        self.alpha = 1.0
      }
      
      if scrollView.contentSize.width + scrollView.contentInset.left > scrollView.bounds.size.width {
        if scrollView.contentSize.width - scrollView.contentOffset.x + scrollView.contentInset.right  <= scrollView.bounds.size.width {
          animator.refresh(view: self, stateDidChange: .refreshing)
          startRefreshing()
        }
      } else {
        if scrollView.contentOffset.x + scrollView.contentInset.left >= animator.trigger / 2.0 {
          animator.refresh(view: self, stateDidChange: .refreshing)
          startRefreshing()
        }
      }
    }
    
  }
  
  open override func start() {
    guard let scrollView = scrollView else {
      return
    }
    super.start()
    
    self.animator.refreshAnimationBegin(view: self)
    
    switch direction! {
    case .vertical:
      let x = scrollView.contentOffset.x
      let y = max(0.0, scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
      
      UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
        scrollView.contentOffset = CGPoint.init(x: x, y: y)
      }, completion: { (animated) in
        self.handler?()
      })
    case .horizontal:
      let y = scrollView.contentOffset.y
      let x = max(0.0, scrollView.contentSize.width - scrollView.bounds.size.width + scrollView.contentInset.right)
      
      UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
        scrollView.contentOffset = CGPoint.init(x: x, y: y)
      }, completion: { (animated) in
        self.handler?()
      })
    }
  }
  
  open override func stop() {
    guard let scrollView = scrollView else {
      return
    }
    
    self.animator.refreshAnimationEnd(view: self)
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
    }, completion: { (finished) in
      if self.noMoreData == false {
        self.animator.refresh(view: self, stateDidChange: .pullToRefresh)
      }
      super.stop()
    })
    
    if scrollView.isDecelerating {
      switch direction! {
      case .vertical:
        var contentOffset = scrollView.contentOffset
        contentOffset.y = min(contentOffset.y, scrollView.contentSize.height - scrollView.frame.size.height)
        if contentOffset.y < 0.0 {
          contentOffset.y = 0.0
          UIView.animate(withDuration: 0.1, animations: {
            scrollView.setContentOffset(contentOffset, animated: false)
          })
        } else {
          scrollView.setContentOffset(contentOffset, animated: false)
        }
      case .horizontal:
        var contentOffset = scrollView.contentOffset
        contentOffset.x = min(contentOffset.x, scrollView.contentSize.width - scrollView.frame.size.width)
        if contentOffset.x < 0.0 {
          contentOffset.x = 0.0
          UIView.animate(withDuration: 0.1, animations: {
            scrollView.setContentOffset(contentOffset, animated: false)
          })
        } else {
          scrollView.setContentOffset(contentOffset, animated: false)
        }
      }
    }
    
  }
  
  open func noticeNoMoreData() {
    noMoreData = true
  }
  
  open func resetNoMoreData() {
    noMoreData = false
  }
  
}

