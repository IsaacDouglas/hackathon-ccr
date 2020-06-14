//
//  Encodable.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation

extension Encodable {
    func prettyPrinted() -> String? {
        return isPrettyPrinted(true)
    }
    
    func encode() -> String? {
        return isPrettyPrinted(false)
    }
    
    fileprivate func isPrettyPrinted(_ value: Bool) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = value ? .prettyPrinted : .init(rawValue: 0)
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
