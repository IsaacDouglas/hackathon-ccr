//
//  TimeIntervalType.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation

enum TimeIntervalType<T: Numeric> {
    case seconds(T)
    case minutes(T)
    case hour(T)
    
    var totalSeconds: T {
        switch self {
        case .seconds(let time):
            return time
        case .minutes(let time):
            return time * 60
        case .hour(let time):
            return time * 60 * 60
        }
    }
}
