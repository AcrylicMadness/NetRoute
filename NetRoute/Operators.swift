//
//  Operators.swift
//  NetRoute
//
//  Created by Кирилл Аверкиев on 08.09.16.
//  Copyright © 2016 Kirill Averkiev. All rights reserved.
//

import Foundation

func += <K, V> (left: inout [K: V], right: [K: V]) {
    for (key, value) in right {
        left.updateValue(value, forKey: key)
    }
}

func + <K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    
    var result = left
    
    for (key, value) in right {
        result.updateValue(value, forKey: key)
    }
    
    return result
}
