//
//  NetResponse.swift
//  NetROute
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
    public let response: URLResponse?
    
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
    public var string: String? {
        
        // Check if data is not nil.
        if data != nil {
            if let responseString = String(data: data!, encoding: encoding) {
                return responseString
            } else {
                
                // Notify about the eroor and return nil.
                print("The response data can not be parsed to string.")
                return nil
            }
        } else {
            
            // Notify about the eroor and return nil.
            print("The response data is nil.")
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
                
                // Notify about the eroor and return nil.
                print("The response data can not be parsed to dictionary.")
                return nil
            }
        } else {
            
            // Notify about the eroor and return nil.
            print("The response data is nil.")
            return nil
        }
    }
    
    
    
    // MARK: - Initialization
    
    
    
    /// Initializes a new instance from default `NSURLSession` output.
    public init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
    
}
