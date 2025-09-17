
import Foundation
import React

@objc public class EncryptedStorage: NSObject {
  
  @objc public static let isEncrypted = true
  
  @objc public func setItem(key: String, value: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    guard let dataFromValue = value.data(using: .utf8) else {
      rejectPromise("An error occured while saving value", errorCode: 0, reject: reject)
      return
    }
    
    let storeQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: dataFromValue
    ]
    
    SecItemDelete(storeQuery as CFDictionary)
    
    let status = SecItemAdd(storeQuery as CFDictionary, nil)
    
    if status == noErr {
      resolve(value)
    } else {
      rejectPromise("An error occured while saving value", errorCode: Int(status), reject: reject)
    }
  }
  
  @objc public func clear() {
    let secureItems: [CFString] = [
      kSecClassGenericPassword,
      kSecClassInternetPassword,
      kSecClassCertificate,
      kSecClassKey,
      kSecClassIdentity
    ]
    
    for item in secureItems {
      let query: [String: Any] = [
        kSecClass as String: item
      ]
      SecItemDelete(query as CFDictionary)
    }
  }
  
  @objc public func getItem(key: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: kCFBooleanTrue as Any,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var dataRef: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &dataRef)
    if status == errSecSuccess {
      guard let data = dataRef as? Data, let value = String(data: data, encoding: .utf8) else {
        rejectPromise("An error occured while retrieving value", errorCode: Int(status), reject: reject)
        return
      }
      resolve(value)
    } else if status == errSecItemNotFound {
      resolve(nil)
    } else {
      rejectPromise("An error occured while retrieving value", errorCode: Int(status), reject: reject)
    }
  }
  
  @objc public func removeItem(key: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: kCFBooleanTrue as Any
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    
    if status == noErr || status == errSecItemNotFound {
      resolve(key)
    } else {
      rejectPromise("An error occured while removing value", errorCode: Int(status), reject: reject)
    }
  }
  
  func rejectPromise(_ message: String, errorCode: Int, reject: RCTPromiseRejectBlock) {
    let error = mapError(code: errorCode)
    let errorCode = "\(error.code)"
    let errorMessage = "RNEncryptedStorageError: \(message)"
    reject(errorCode, errorMessage, error)
  }
  
  func mapError(code: Int) -> NSError {
    return NSError(domain: Bundle.main.bundleIdentifier ?? "EncryptedStorage", code: code, userInfo: nil)
  }
}


