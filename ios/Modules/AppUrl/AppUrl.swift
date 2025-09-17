//
//  AppUrl.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc class AppUrl: NSObject {
    
    // MARK: - Constants
    private static let defaultPackagerPortValue = 8083
    private static let queryStringForDevMode = "platform=ios&dev=true&minify=false"
    private static let queryStringProduction = "platform=ios&dev=false&minify=true"
    private static let defaultUrlString = "http://localhost:8080"
    private static let bundlePath = "/index.bundle"
    
    // MARK: - Public Methods
    @objc static func defaultPackagerPort() -> Int {
        return defaultPackagerPortValue
    }
    
    @objc static func forBundle(_ url: String, port: Int, isDebuggingRemotely: Bool, isDevModeEnabled: Bool) -> URL? {
        guard var urlComponents = createUrlComponents(url) else { return nil }
        
        let actualPort = port != 0 ? port : defaultPackagerPortValue
        urlComponents.port = actualPort
        urlComponents.path = (urlComponents.path ?? "") + bundlePath
        urlComponents.query = isDevModeEnabled ? queryStringForDevMode : queryStringProduction
        
        return urlComponents.url
    }
    
    @objc static func forRuntime(_ url: String) -> URL? {
        guard var urlComponents = createUrlComponents(url) else { return nil }
        
        urlComponents.path = "/"
        return URL(string: urlComponents.string ?? "")
    }
    
    @objc static func forValidation(_ url: String) -> URL? {
        guard var urlComponents = createUrlComponents(url) else { return nil }
        
        urlComponents.path = "/components.json"
        return URL(string: urlComponents.string ?? "")
    }
    
    @objc static func forRuntimeInfo(_ url: String) -> URL? {
        guard var urlComponents = createUrlComponents(url) else { return nil }
        
        urlComponents.path = "/xas/"
        return URL(string: urlComponents.string ?? "")
    }
    
    @objc static func forPackagerStatus(_ url: String, port: Int) -> URL? {
        guard var urlComponents = createUrlComponents(url) else { return nil }
        
        let actualPort = port != 0 ? port : defaultPackagerPortValue
        urlComponents.path = "/status"
        urlComponents.port = actualPort
        
        return URL(string: urlComponents.string ?? "")
    }
    
    @objc static func isValid(_ url: String) -> Bool {
        let trimmedUrl = url.trimmingCharacters(in: .whitespaces)
        
        if trimmedUrl.count < 1 {
            return false
        }
        
        let processedUrl = ensureProtocol(removeTrailingSlash(trimmedUrl))
        guard let urlComponents = URLComponents(string: processedUrl) else {
            return false
        }
        
        return (urlComponents.queryItems?.isEmpty ?? true) && (urlComponents.path.isEmpty || urlComponents.path == "/")
    }
    
    // MARK: - Private Helper Methods
    private static func createUrlComponents(_ url: String) -> URLComponents? {
        let processedUrl = ensureProtocol(removeTrailingSlash(url))
        return URLComponents(string: processedUrl) ?? URLComponents(string: defaultUrlString)
    }
    
    private static func ensureProtocol(_ url: String) -> String {
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return url
        }
        return "http://" + url
    }
    
    private static func removeTrailingSlash(_ url: String) -> String {
        let trimmedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedUrl.hasSuffix("/") {
            return String(trimmedUrl.dropLast())
        }
        return trimmedUrl
    }
}
