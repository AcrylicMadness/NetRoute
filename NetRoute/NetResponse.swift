//
//  NetResponse.swift
//  NetRoute
//
//  Created by Kirill Averkiev on 15.04.16.
//  Copyright © 2016 Kirill Averkiev. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

/// The response of the request.
public class NetResponse: NetRouteObject {
    
    
    
    // MARK: - Constants
    
    
    
    /// Response data.
    public let data: Data?
    
    /// HTTP response.
    public let httpResponse: URLResponse?
    
    /// Error.
    public let error: Error?
    
    
    
    // MARK: - Variables
    
    
    
    /// Encoding for the string conversion. Default is `NSUTF8StringEncoding`.
    public var encoding = String.Encoding.utf8
    
    /// String conversion.Returns nil if the data can not be presented as `String`.
    public override var description: String {
        if let dictionary = dictionary {
            var finalString = "{\n"
            for (key, value) in dictionary {
                finalString += "    " + "\(key): \(value)\n"
            }
            finalString += "}"
            return finalString
        }
        return "Response"
    }
    
    /// String value of the data. Returns nil if the data can not be presented as `String`.
    public var stringValue: String? {
        
        // Check if data is not nil.
        if data != nil {
            if let responseString = String(data: data!, encoding: encoding) {
                return responseString
            } else {
                
                return nil
            }
        } else {
            
            return nil
        }
    }
    
    
    /// Dictionary of the data. Returns nil if the data can not be presented as `Dictionary`.
    public var dictionary: Dictionary<String, AnyObject>? {
        
        // Check if data is not nil.
        if data != nil {
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                return responseJSON as? Dictionary
            } catch _ {
                
                return nil
            }
        } else {
            
            return nil
        }
    }
    
    
    
    // MARK: - Initialization
    
    
    
    /// Initializes a new instance from default `NSURLSession` output.
    public init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.httpResponse = response
        self.error = error
    }
    
    
    
    // MARK: - Header Values
    
    
    
    /// Get a header value from response.
    ///
    /// - Parameter forHeader: Name of the header.
    ///
    /// - Returns: Value for provided header. Nil if no response or the provided header is wrong.
    public func value(for header: String) -> Any? {
        if let response = httpResponse as? HTTPURLResponse {
            return response.allHeaderFields[header]
        } else {
            return nil
        }
    }
    
    /// Get a header value from response.
    ///
    /// - Parameter forHeader: Name of the header.
    ///
    /// - Returns: String for provided header converted to String. Nil if no response, the provided header is wrong or the data cannot be converted to String.
    public func string(for header: String) -> String? {
        return self.value(forHeader: header) as? String

    }
}
