//
//  RuntimeInfoProvider.swift
//  MendixNative
//
//  Created by Yogendra Shelke on 05/09/25.
//  Copyright (c) Mendix, Inc. All rights reserved.
//

import Foundation

@objc class RuntimeInfoProvider: NSObject {
    
    // MARK: - Public Methods
    @objc static func getRuntimeInfo(_ runtimeURL: URL?, completionHandler: @escaping (RuntimeInfoResponse) -> Void) {
        guard let runtimeURL = runtimeURL else {
            return runCallBackInMainThread(makeInaccessibleResponse(), completionHandler: completionHandler)
        }
        
        var request = URLRequest(url: runtimeURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpBody = "{\"action\": \"info\"}".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                return runCallBackInMainThread(makeInaccessibleResponse(), completionHandler: completionHandler)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return runCallBackInMainThread(makeFailedResponse(), completionHandler: completionHandler)
            }
            
            if !isSuccessStatusCode(httpResponse.statusCode) {
                return runCallBackInMainThread(makeFailedResponse(), completionHandler: completionHandler)
            }
            
            guard let data = data else {
                return runCallBackInMainThread(makeFailedResponse(), completionHandler: completionHandler)
            }
            
            do {
                guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    return runCallBackInMainThread(makeFailedResponse(), completionHandler: completionHandler)
                }
                
                let runtimeInfo = runtimeInfoFromJSONDictionary(jsonDictionary)
                return runCallBackInMainThread(makeSuccessResponse(runtimeInfo), completionHandler: completionHandler)
            } catch {
                return runCallBackInMainThread(makeFailedResponse(), completionHandler: completionHandler)
            }
        }.resume()
    }
    
    // MARK: - Private Helper Methods
    private static func runCallBackInMainThread(_ response: RuntimeInfoResponse, completionHandler: @escaping (RuntimeInfoResponse) -> Void) {
        DispatchQueue.main.async {
            completionHandler(response)
        }
    }
    
    private static func makeInaccessibleResponse() -> RuntimeInfoResponse {
        return RuntimeInfoResponse(status: "INACCESSIBLE", runtimeInfo: nil)
    }
    
    private static func makeFailedResponse() -> RuntimeInfoResponse {
        return RuntimeInfoResponse(status: "FAILED", runtimeInfo: nil)
    }
    
    private static func makeSuccessResponse(_ runtimeInfo: RuntimeInfo) -> RuntimeInfoResponse {
        return RuntimeInfoResponse(status: "SUCCESS", runtimeInfo: runtimeInfo)
    }
    
    private static func isSuccessStatusCode(_ statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode <= 299
    }
    
    private static func runtimeInfoFromJSONDictionary(_ dictionary: [String: Any]) -> RuntimeInfo {
        let version = dictionary["version"] as? String ?? ""
        let cacheburst = dictionary["cachebust"] as? String ?? ""
        let nativeBinaryVersion = dictionary["nativeBinaryVersion"] as? Int ?? 0
        let packagerPort = dictionary["packagerPort"] as? Int ?? 0
        
        return RuntimeInfo(version: version, 
                          cacheburst: cacheburst, 
                          nativeBinaryVersion: nativeBinaryVersion, 
                          packagerPort: packagerPort)
    }
}
