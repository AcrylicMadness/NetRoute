//
//  NRRequestQueue.swift
//  NRKit
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
public class NRRequestQueue: NRObject {

    
    
    /// MARK: Variables
    
    
    
    /// Array of requests.
    private var requestsInQueue: Array<NRRequest> = []
    
    /// Status of the queue.
    private var status = NRRequestQueueStatus.NotExecuting
    
    /// Descriprion for converting to string.
    public override var description: String {
        return "\(requestsInQueue)"
    }
    
    
    
    // MARK: - Working with requests.
    
    
    
    /// Adds a new request to the queue. 
    /// - Warning: This method should not be used to add requests. Use `passToQueue(queue: NRRequestQueue)` of a request object.
    /// - Parameter request: A request to add to the queue.
    
    internal func addRequest(request: NRRequest) {
        
        // Blocking the method if queue if executing.
        if status == .NotExecuting {
            
            // Check the priority.
            switch request.priority {
            
            // If it is low, just add the request to the end of the queue.
            case .Low:
                requestsInQueue.append(request)
                
            // Find a place to put the request depending on its priority.
            default:
                
                let index = getIndexForPriority(request.priority)
                requestsInQueue.insert(request, atIndex: index)
            }
            
        } else {
            
            // Notify about the eroor.
            print("The queue is already executing!")
        }

    }
    
    /// Runs all requests in the queue.
    internal func runRequests() {
        
        // Get the request.
        for request in requestsInQueue {
            
            // Set the right executing status for the queue.
            switch request.priority {
                
            case .BackgroundTask:
                status = .InBackgroundExecution
            case .High:
                status = .ExecutingHigh
            case .Default:
                status = .ExecutingDefault
            case .Low:
                status = .ExecutingLow
            }
            
            // Run the request remove it from the queue.
            request.runWithCompletion(nil)
            requestsInQueue.removeAtIndex(requestsInQueue.indexOf(request)!)
        }
        
        // Clear the status to make the queue reusable.
        status = .NotExecuting
    }
    
    
    
    // MARK: - Getting the position
    
    
    
    /// Gets the position for the request in the queue based on priority.
    /// - Parameter priority: Priority that is used to find the right position.
    /// - Returns: An index of the requests array to insert the request with given priority.
    
    private func getIndexForPriority(priorityForPosition: NRRequestPriority) -> Int {
        
        // A flag to know when the place is found.
        var found = false
        
        // Do the search.
        for index in 0..<requestsInQueue.count {
            if requestsInQueue[index].priority.rawValue < priorityForPosition.rawValue {
                found = true
                return index
            }
        }
        
        // Handle if a place not found.
        if !found {
            return requestsInQueue.count - 1
        }
        
    }
    
    
    
}