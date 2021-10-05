import Foundation

open class RBRefreshDataManager {
  
  static let sharedManager = RBRefreshDataManager.init()
  
  static let lastRefreshKey: String = "com.rbpulltorefresh.lastRefreshKey"
  static let expiredTimeIntervalKey: String = "com.rbpulltorefresh.expiredTimeIntervalKey"
  open var lastRefreshInfo = [String: Date]()
  open var expiredTimeIntervalInfo = [String: TimeInterval]()
  
  public required init() {
    if let lastRefreshInfo = UserDefaults.standard.dictionary(forKey: RBRefreshDataManager.lastRefreshKey) as? [String: Date] {
      self.lastRefreshInfo = lastRefreshInfo
    }
    if let expiredTimeIntervalInfo = UserDefaults.standard.dictionary(forKey: RBRefreshDataManager.expiredTimeIntervalKey) as? [String: TimeInterval] {
      self.expiredTimeIntervalInfo = expiredTimeIntervalInfo
    }
  }
  
  open func date(forKey key: String) -> Date? {
    let date = lastRefreshInfo[key]
    return date
  }
  
  open func setDate(_ date: Date?, forKey key: String) {
    lastRefreshInfo[key] = date
    UserDefaults.standard.set(lastRefreshInfo, forKey: RBRefreshDataManager.lastRefreshKey)
    UserDefaults.standard.synchronize()
  }
  
  open func expiredTimeInterval(forKey key: String) -> TimeInterval? {
    let interval = expiredTimeIntervalInfo[key]
    return interval
  }
  
  open func setExpiredTimeInterval(_ interval: TimeInterval?, forKey key: String) {
    expiredTimeIntervalInfo[key] = interval
    UserDefaults.standard.set(expiredTimeIntervalInfo, forKey: RBRefreshDataManager.expiredTimeIntervalKey)
    UserDefaults.standard.synchronize()
  }
  
  open func isExpired(forKey key: String) -> Bool {
    guard let date = date(forKey: key) else {
      return true
    }
    guard let interval = expiredTimeInterval(forKey: key) else {
      return false
    }
    if date.timeIntervalSinceNow < -interval {
      return true // Expired
    }
    return false
  }
  
  open func isExpired(forKey key: String, block: ((Bool) -> ())?) {
    DispatchQueue.global().async {
      [weak self] in
      let result = self?.isExpired(forKey: key) ?? true
      DispatchQueue.main.async(execute: {
        block?(result)
      })
    }
  }
  
  public static func clearAll() {
    self.clearLastRefreshInfo()
    self.clearExpiredTimeIntervalInfo()
  }
  
  public static func clearLastRefreshInfo() {
    UserDefaults.standard.set(nil, forKey: RBRefreshDataManager.lastRefreshKey)
  }
  
  public static func clearExpiredTimeIntervalInfo() {
    UserDefaults.standard.set(nil, forKey: RBRefreshDataManager.expiredTimeIntervalKey)
  }
  
}
