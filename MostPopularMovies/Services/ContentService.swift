//
//  ContentService.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/16/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Alamofire

enum ContentRoute {
    case configuration
    case popularMovies
    case searchMovies
    case movieGenres
    case movie(id: Int)

    var rawValue: String {
        switch self {
        case .configuration: return "/configuration"
        case .popularMovies: return "/movie/popular"
        case .searchMovies: return "/search/movie"
        case .movieGenres: return "/genre/movie/list"
        case .movie(let id): return "/movie/\(id)"
        }
    }
}

enum ContentServiceError: Error {
    case invalidPage
}

protocol ContentServiceProtocol {
    func request(_ route: ContentRoute, completion: @escaping (([AnyHashable: Any]?, Error?) -> Void))
    func request(_ route: ContentRoute, page: Int, completion: @escaping (([AnyHashable: Any]?, Error?) -> Void))
    func request(_ route: ContentRoute, query: String, completion: @escaping (([AnyHashable: Any]?, Error?) -> Void))
    func request(_ route: ContentRoute, query: String?, page: Int?, completion: @escaping (([AnyHashable: Any]?, Error?) -> Void))
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

        let url = "\(ServiceConstants.baseURL)\(route.rawValue)"
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
        request(route, query: nil, page: page, completion: completion)
    }

    func request(_ route: ContentRoute, query: String, completion: @escaping (([AnyHashable : Any]?, Error?) -> Void)) {
        request(route, query: query, page: nil, completion: completion)
    }

    func request(_ route: ContentRoute, query: String?, page: Int?, completion: @escaping (([AnyHashable : Any]?, Error?) -> Void)) {
        var additionalParameters: Parameters = [:]

        if let page = page {
            guard page >= minimumPageNumber && page <= maximumPageNumber else {
                completion(nil, ContentServiceError.invalidPage)
                return
            }
            additionalParameters["page"] = page
        }

        if let query = query {
            additionalParameters["query"] = query
        }

        request(route, additionalParameters: additionalParameters, completion: completion)
    }
}
