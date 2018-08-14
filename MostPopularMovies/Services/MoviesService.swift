//
//  MoviesService.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/13/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Alamofire

enum MoviesServiceError: Error {
    case invalidPage
}

protocol MoviesServiceProtocol {
    func requestMovies(page: Int, completion: @escaping (([AnyHashable: Any]?, Error?) -> Void))
}

class MoviesService {
    
}

extension MoviesService: MoviesServiceProtocol {
    func requestMovies(page: Int = 1, completion: @escaping (([AnyHashable: Any]?, Error?) -> Void)) {
        guard page >= 1 && page <= 1000 else {
            completion(nil, MoviesServiceError.invalidPage)
            return
        }
        
        let parameters: Parameters = [
            "api_key": ServiceConstants.apiKey,
            "page": page
        ]
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        let request = Alamofire.request(ServiceConstants.moviesURL,
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
