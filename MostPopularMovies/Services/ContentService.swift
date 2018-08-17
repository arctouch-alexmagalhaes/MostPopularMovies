//
//  ContentService.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/16/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Alamofire

enum ContentRoute: String {
    case configuration
    case popularMovies = "movie/popular"
    case movieGenres = "genre/movie/list"
}

enum ContentServiceError: Error {
    case invalidPage
}

protocol ContentServiceProtocol {
    func request(_ route: ContentRoute, completion: @escaping (([AnyHashable: Any]?, Error?) -> Void))
    func request(_ route: ContentRoute, page: Int, completion: @escaping (([AnyHashable: Any]?, Error?) -> Void))
}

class ContentService {
    private let minimumPageNumber: Int = 1
    private let maximumPageNumber: Int = 1000

    private func request(_ route: ContentRoute, additionalParameters: Parameters, completion: @escaping (([AnyHashable : Any]?, Error?) -> Void)) {
        var parameters: Parameters = [
            "api_key": ServiceConstants.apiKey
        ]
        additionalParameters.forEach({ parameters[$0.key] = $0.value })

        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]

        let url = "\(ServiceConstants.baseURL)/\(route.rawValue)"
        let request = Alamofire.request(url,
                                        parameters: parameters,
                                        encoding: URLEncoding.queryString,
                                        headers: headers)
        request.validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                completion(data as? [AnyHashable: Any], nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

extension ContentService: ContentServiceProtocol {
    func request(_ route: ContentRoute, completion: @escaping (([AnyHashable : Any]?, Error?) -> Void)) {
        request(route, additionalParameters: [:], completion: completion)
    }

    func request(_ route: ContentRoute, page: Int, completion: @escaping (([AnyHashable : Any]?, Error?) -> Void)) {
        guard page >= minimumPageNumber && page <= maximumPageNumber else {
            completion(nil, ContentServiceError.invalidPage)
            return
        }

        let parameters: Parameters = [
            "page": page
        ]
        request(route, additionalParameters: parameters, completion: completion)
    }
}
