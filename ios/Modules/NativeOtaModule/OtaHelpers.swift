//
//  OtaHelpers.swift
//  MendixNative
//
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc class OtaHelpers: NSObject {
    
    @objc static func resolveAppVersion() -> String {
        let info = Bundle.main.infoDictionary
        let shortVersion = info?["CFBundleShortVersionString"] as? String ?? ""
        let bundleVersion = info?["CFBundleVersion"] as? String ?? ""
        return "\(shortVersion)-\(bundleVersion)"
    }
    
    @objc static func getOtaDir() -> String {
        let supportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first ?? ""
        let bundleIdentifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        return "\(supportDirectory)/\(bundleIdentifier)/\(OTA_DIR_NAME)"
    }
    
    @objc static func getOtaManifestFilepath() -> String {
        return resolveAbsolutePathRelativeToOtaDir("/\(MANIFEST_FILE_NAME)")
    }
    
    @objc static func resolveAbsolutePathRelativeToOtaDir(_ path: String) -> String {
        return "\(getOtaDir())\(path)"
    }
    
    @objc static func readManifestAsDictionary() -> [String: Any]? {
        let manifestPath = getOtaManifestFilepath()
        
        guard let contents = NSData(contentsOfFile: manifestPath) else {
            return nil
        }
        
        do {
            let jsonOutput = try JSONSerialization.jsonObject(with: contents as Data, options: [])
            return jsonOutput as? [String: Any]
        } catch {
            return nil
        }
    }
    
    @objc static func getNativeDependencies() -> [String: Any] {
        guard let path = Bundle.main.path(forResource: "native_dependencies", ofType: "json") else {
            return [:]
        }
        
        return NativeFsModule.readJson(path, error: nil) as? [String: Any] ?? [:]
    }
}
