//
//  NativeFsModule.swift
//  MendixNative
//
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation
import React

@objc public class NativeFsModule: NSObject {
  
  private static var enableEncryption = false
  
  // Error constants
  private static let ERROR_SAVE_FAILED = "ERROR_SAVE_FAILED"
  private static let ERROR_READ_FAILED = "ERROR_READ_FAILED"
  private static let ERROR_MOVE_FAILED = "ERROR_MOVE_FAILED"
  private static let ERROR_DELETE_FAILED = "ERROR_DELETE_FAILED"
  private static let ERROR_SERIALIZATION_FAILED = "ERROR_SERIALIZATION_FAILED"
  private static let INVALID_PATH = "INVALID_PATH"
  
  private static let NativeFsErrorDomain = "com.mendix.mendixnative.nativefsmodule"
  
  @objc static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc static func setEncryptionEnabled(_ enabled: Bool) {
    enableEncryption = enabled
  }
  
  private static func formatError(_ message: String) -> String {
    return "\(String(describing: NativeFsModule.self)): \(message)"
  }
  
  private static func readBlobRefAsData(_ blob: [String: Any]) -> Data? {
    guard let bridge = ReactNative.instance.getBridge(),
          let blobManager = bridge.module(for: RCTBlobManager.self) as? RCTBlobManager else {
      return nil
    }
    return blobManager.resolve(blob)
  }
  
  private static func readDataAsBlobRef(_ data: Data) -> [String: Any]? {
    guard let bridge = ReactNative.instance.getBridge(),
          let blobManager = bridge.module(for: RCTBlobManager.self) as? RCTBlobManager else {
      return nil
    }
    
    let blobId = blobManager.store(data)
    return [
      "blobId": blobId as Any,
      "offset": 0,
      "length": data.count
    ]
  }
  
  @objc static func readData(_ filePath: String) -> Data? {
    guard FileManager.default.fileExists(atPath: filePath) else {
      return nil
    }
    
    do {
      return try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedRead)
    } catch {
      return nil
    }
  }
  
  @objc static func readJson(_ filePath: String, error: NSErrorPointer) -> [String: Any]? {
    guard let data = readData(filePath) else {
      return nil
    }
    
    do {
      let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
      return result as? [String: Any]
    } catch let jsonError {
      error?.pointee = jsonError as NSError
      return nil
    }
  }
  
  @objc static func save(_ data: Data, filepath: String, error: NSErrorPointer) -> Bool {
    let directoryURL = URL(fileURLWithPath: (filepath as NSString).deletingLastPathComponent)
    
    do {
      try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    } catch let directoryError {
      error?.pointee = directoryError as NSError
      return false
    }
    
    var options: Data.WritingOptions = .atomic
    if enableEncryption {
      options = [.atomic, .completeFileProtection]
    }
    
    do {
      try data.write(to: URL(fileURLWithPath: filepath), options: options)
      return true
    } catch let writeError {
      error?.pointee = writeError as NSError
      return false
    }
  }
  
  @objc static func move(_ filepath: String, newPath: String, error: NSErrorPointer) -> Bool {
    let fileManager = FileManager.default
    
    guard fileManager.fileExists(atPath: filepath) else {
      error?.pointee = NSError(domain: NativeFsErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "File does not exist"])
      return false
    }
    
    let directoryURL = URL(fileURLWithPath: (newPath as NSString).deletingLastPathComponent)
    
    do {
      try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    } catch let directoryError {
      error?.pointee = directoryError as NSError
      return false
    }
    
    do {
      try fileManager.moveItem(atPath: filepath, toPath: newPath)
      return true
    } catch let moveError {
      error?.pointee = moveError as NSError
      return false
    }
  }
  
  @objc static func remove(_ filepath: String, error: NSErrorPointer) -> Bool {
    let fileManager = FileManager.default
    
    guard fileManager.fileExists(atPath: filepath) else {
      return false
    }
    
    do {
      try fileManager.removeItem(atPath: filepath)
      return true
    } catch let removeError {
      error?.pointee = removeError as NSError
      return false
    }
  }
  
  @objc static func ensureWhiteListedPath(_ paths: [String], error: NSErrorPointer) -> Bool {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
    let tempPath = (NSTemporaryDirectory() as NSString).standardizingPath
    
    for path in paths {
      if !path.hasPrefix(documentsPath) &&
          !path.hasPrefix(cachesPath) &&
          !path.hasPrefix(tempPath) {
        error?.pointee = NSError(
          domain: NativeFsErrorDomain,
          code: 999,
          userInfo: [NSLocalizedDescriptionKey: "The path \(path) does not point to the documents directory"]
        )
        return false
      }
    }
    return true
  }
  
  @objc static func list(_ dirPath: String) -> [String] {
    guard let enumerator = FileManager.default.enumerator(atPath: dirPath) else {
      return []
    }
    return enumerator.allObjects as? [String] ?? []
  }
  
  // MARK: - React Native Bridge Methods
  
  @objc(setEncryptionEnabled:)
  func setEncryptionEnabled(_ enabled: Bool) {
    NativeFsModule.setEncryptionEnabled(enabled)
  }
  
  @objc(save:filepath:resolver:rejecter:)
  func save(_ blob: [String: Any],
            filepath: String,
            resolver resolve: @escaping RCTPromiseResolveBlock,
            rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([filepath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, NativeFsModule.formatError("Path not accessible"), error)
      return
    }
    
    guard let data = NativeFsModule.readBlobRefAsData(blob) else {
      reject(NativeFsModule.ERROR_READ_FAILED, NativeFsModule.formatError("Failed to read blob"), nil)
      return
    }
    
    if !NativeFsModule.save(data, filepath: filepath, error: &error) {
      reject(NativeFsModule.ERROR_SAVE_FAILED, NativeFsModule.formatError("Save failed"), error)
      return
    }
    
    resolve(nil)
  }
  
  @objc(read:resolver:rejecter:)
  func read(_ filepath: String,
            resolver resolve: @escaping RCTPromiseResolveBlock,
            rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([filepath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, NativeFsModule.formatError("Path not accessible"), error)
      return
    }
    
    guard let data = NativeFsModule.readData(filepath) else {
      resolve(nil)
      return
    }
    
    guard let blob = NativeFsModule.readDataAsBlobRef(data) else {
      reject(NativeFsModule.ERROR_READ_FAILED, NativeFsModule.formatError("Failed to create blob"), nil)
      return
    }
    
    resolve(blob)
  }
  
  @objc(move:newPath:resolver:rejecter:)
  func move(_ filepath: String,
            newPath: String,
            resolver resolve: @escaping RCTPromiseResolveBlock,
            rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([filepath, newPath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, NativeFsModule.formatError("Path not accessible"), error)
      return
    }
    
    if !NativeFsModule.move(filepath, newPath: newPath, error: &error) {
      reject(NativeFsModule.ERROR_MOVE_FAILED, NativeFsModule.formatError("Failed to move file"), error)
      return
    }
    
    resolve(nil)
  }
  
  @objc public func remove(_ filepath: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([filepath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, NativeFsModule.formatError("Path not accessible"), error)
      return
    }
    
    if !NativeFsModule.remove(filepath, error: &error) {
      reject(NativeFsModule.ERROR_DELETE_FAILED, NativeFsModule.formatError("Failed to delete file"), error)
      return
    }
    
    resolve(nil)
  }
  
  @objc(list:resolver:rejecter:)
  func list(_ dirPath: String,
            resolver resolve: @escaping RCTPromiseResolveBlock,
            rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([dirPath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, NativeFsModule.formatError("Path not accessible"), error)
      return
    }
    
    resolve(NativeFsModule.list(dirPath))
  }
  
  @objc(readAsDataURL:resolver:rejecter:)
  func readAsDataURL(_ filePath: String,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([filePath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, NativeFsModule.formatError("Path not accessible"), error)
      return
    }
    
    guard let data = NativeFsModule.readData(filePath) else {
      resolve(nil)
      return
    }
    
    let base64String = data.base64EncodedString()
    let dataURL = "data:application/octet-stream;base64,\(base64String)"
    resolve(dataURL)
  }
  
  @objc(fileExists:resolver:rejecter:)
  func fileExists(_ filepath: String,
                  resolver resolve: @escaping RCTPromiseResolveBlock,
                  rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([filepath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, NativeFsModule.formatError("Path not accessible"), error)
      return
    }
    
    let exists = FileManager.default.fileExists(atPath: filepath)
    resolve(NSNumber(value: exists))
  }
  
  @objc(readJson:resolver:rejecter:)
  func readJson(_ filepath: String,
                resolver resolve: @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([filepath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, NativeFsModule.formatError("Path not accessible"), error)
      return
    }
    
    guard let data = NativeFsModule.readJson(filepath, error: &error) else {
      if let error = error {
        reject(NativeFsModule.ERROR_SERIALIZATION_FAILED, NativeFsModule.formatError("Failed to deserialize JSON"), error)
      } else {
        resolve(nil)
      }
      return
    }
    
    resolve(data)
  }
  
  @objc(writeJson:filepath:resolver:rejecter:)
  func writeJson(_ data: [String: Any],
                 filepath: String,
                 resolver resolve: @escaping RCTPromiseResolveBlock,
                 rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    var error: NSError?
    if !NativeFsModule.ensureWhiteListedPath([filepath], error: &error) {
      reject(NativeFsModule.INVALID_PATH, "Path not accessible", error)
      return
    }
    
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
      
      if !NativeFsModule.save(jsonData, filepath: filepath, error: &error) {
        reject(NativeFsModule.ERROR_SAVE_FAILED, NativeFsModule.formatError("Failed to write JSON"), error)
        return
      }
      
      resolve(nil)
    } catch {
      reject(NativeFsModule.ERROR_SERIALIZATION_FAILED, NativeFsModule.formatError("Failed to serialize JSON"), error)
    }
  }
  
  @objc func constantsToExport() -> [String: Any] {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    
    return [
      "DocumentDirectoryPath": documentsPath,
      "SUPPORTS_DIRECTORY_MOVE": true,
      "SUPPORTS_ENCRYPTION": true
    ]
  }
}
