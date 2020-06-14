//
//  HTTPResponse.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import PerfectHTTP

extension HTTPResponse {
    func sendJSON<T: Encodable>(_ json: T, status: HTTPResponseStatus = .ok) {
        do {
            try setBody(json: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: status)
        } catch {
            setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
}
