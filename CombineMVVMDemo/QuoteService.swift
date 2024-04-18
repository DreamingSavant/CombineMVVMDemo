//
//  QuoteService.swift
//  CombineMVVMDemo
//
//  Created by Roderick Presswood on 4/18/24.
//

import Foundation
import Combine

protocol QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<Quote, Error>
}

class QuoteService: QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<Quote, any Error> {
        guard let url = URL(string: "https:/api.quotable.io/random") else {
            return Empty().eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .map { $0.data }
            .decode(type: Quote.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
        
    }
}
