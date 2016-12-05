//
//  NetRequestQueue.swift
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

/// Queue of requests.
public class NetRequestQueue: NetRouteObject {

    
    
    /// MARK: Variables
    
    
    
    /// Array of requests.
    private var requests: Array<NetRequest> = []
    
    /// Status of the queue.
    private var status = NetRequestQueueStatus.stopped
    
    /// Descriprion for converting to string.
    public override var description: String {
        return "\(requests)"
    }
    
    
    
    // MARK: - Working with requests.
    
    
    
    /// Adds a new request to the queue. 
    /// - Warning: This method should not be used to add requests. Use `passToQueue(queue: NRRequestQueue)` of a request object.
    /// - Parameter request: A request to add to the queue.
    
    internal func add(request: NetRequest) {
        
        // Blocking the method if queue if executing.
        if status == .stopped {
            
            // Check the priority.
            switch request.priority {
            
            // If it is low, just add the request to the end of the queue.
            case .low:
                requests.append(request)
                
            // Find a place to put the request depending on its priority.
            default:
                
                let index = index(for: request.priority)
                requests.insert(request, at: index)
            }
            
        } else {
            
            // Notify about the eroor.
            print("The queue is already executing!")
        }

    }
    
    /// Runs all requests in the queue.
    public func run() {
        
        // Get the request.
        for request in requests {
            
            // Set the right executing status for the queue.
            switch request.priority {
                
            case .background:
                status = .inBackgroundExecution
            case .high:
                status = .executingHigh
            case .medium:
                status = .executingDefault
            case .low:
                status = .executingLow
            }
            
            // Run the request remove it from the queue.
            request.run(completionHandler: nil)
            requests.remove(at: requests.index(of: request)!)
        }
        
        // Clear the status to make the queue reusable.
        status = .stopped
    }
    
    
    
    // MARK: - Getting the position
    
    
    
    /// Gets the position for the request in the queue based on priority.
    /// - Parameter priority: Priority that is used to find the right position.
    /// - Returns: An index of the requests array to insert the request with given priority.
    
    private func index(for priority: NetRequestPriority) -> Int {
        
        // A flag to know when the place is found.
        var found = false
        
        // Do the search.
        for index in 0..<requests.count {
            if requests[index].priority.rawValue < priority.rawValue {
                found = true
                return index
            }
        }
        
        // Handle if a place not found.
        if !found {
            return requests.count - 1
        }
        
    }
    
    
    
}
