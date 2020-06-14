//
//  Date.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation

extension Date {
    static var timeInterval: CLong {
        return CLong(Date().timeIntervalSince1970.rounded())
    }
    
    var timeInterval: CLong {
        return CLong(self.timeIntervalSince1970.rounded())
    }
}
