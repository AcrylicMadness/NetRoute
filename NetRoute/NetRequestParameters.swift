//
//  NetRequestParameters.swift
//  NetRoute
//
//  Created by Kirill Averkiev on 18.04.16.
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

/// Parameters for the request.
open class NetRequestParameters: NetRouteObject {
    
    
    
    // MARK: - Variables
    
    
    
    // MARK: Public
    
    
    
    /// Dictionary with parameters.
    public var dictionary: Dictionary<String, String>
    
    /// Custom string that can be appended to URL in `.GET` requests.
    override open var description: String {
        
        // Return HTML-standard parameters string.
        return dictionary.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
    }
    
    
    
    // MARK: - Lifecycle
    
    
    
    /// Initializes a new instancw from a given dictionary.
    public init(dictionary: Dictionary<String, String>) {
        self.dictionary = dictionary
    }
    
}
    
