//
//  GenresService.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/13/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Alamofire

protocol GenresServiceProtocol {
    func requestGenres(completion: @escaping (([AnyHashable: Any]?, Error?) -> Void))
}

class GenresService {

}

extension GenresService: GenresServiceProtocol {
    func requestGenres(completion: @escaping (([AnyHashable: Any]?, Error?) -> Void)) {
        let parameters: Parameters = [
            "api_key": ServiceConstants.apiKey
        ]
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        let request = Alamofire.request(ServiceConstants.genresURL,
                                        parameters: parameters,
                                        encoding: URLEncoding.queryString,
                                        headers: headers)
        request.validate().responseJSON(queue: DispatchQueue.global()) { response in
            switch response.result {
            case .success(let data):
                completion(data as? [AnyHashable: Any], nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
