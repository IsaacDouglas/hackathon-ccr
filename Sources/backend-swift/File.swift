//
//  File.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation

class File {
    static func pathDefault(lastPath: String? = nil) -> URL? {
        let manager = FileManager.default
        let documentsUrl = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let path = lastPath else { return documentsUrl }
        return documentsUrl?.appendingPathComponent(path)
    }
}
