//
//  ImageService.swift
//  MostPopularMovies
//
//  Created by Alex Magalhaes on 08/16/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Alamofire

protocol ImageServiceProtocol {
    func requestImage(_ url: String?, completion: ((Data?) -> Void)?)
}

class ImageService {

}

extension ImageService: ImageServiceProtocol {
    func requestImage(_ url: String?, completion: ((Data?) -> Void)?) {
        guard let url = url else {
            completion?(nil)
            return
        }

        Alamofire.request(url).validate().responseData { response in
            switch response.result {
            case .success(let value):
                completion?(value)
            case .failure(let error):
                print("Error while requesting image from \(url). Error message: \(error.localizedDescription)")
                completion?(nil)
            }
        }
    }
}
