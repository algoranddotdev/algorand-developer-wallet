//
//  Indexer.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/23/22.
//

import Foundation

struct Indexer {
  let host: String
  
  func fetch(
    path: String,
    method: String = "GET",
    body: Data? = nil
  ) async throws -> Data {
    let url = URL(string: "\(host)\(path)")!
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let body = body {
      request.httpBody = body
    }
    
    let (data, response) = try await URLSession.shared.data(for: request) as! (Data, HTTPURLResponse)
    let responseDecoded = String(data: data, encoding: .utf8)!
    print(response)
    print(responseDecoded)
    
    return data
  }
}
