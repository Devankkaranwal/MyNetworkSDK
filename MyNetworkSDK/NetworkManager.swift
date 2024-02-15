//
//  NetworkManager.swift
//  MyNetworkSDK
//
//  Created by Devank on 16/02/24.
//

import Foundation


public class NetworkManager {
    public static let shared = NetworkManager()
    
    private init() {}
    
    public func fetchData<T: Decodable>(from url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decodedData))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NetworkError.noData))
                }
            default:
                completion(.failure(NetworkError.httpError(code: httpResponse.statusCode)))
            }
        }.resume()
    }
}

public enum NetworkError: Error {
    case noData
    case invalidResponse
    case httpError(code: Int)
}
