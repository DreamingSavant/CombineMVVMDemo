//
//  QuoteViewModel.swift
//  CombineMVVMDemo
//
//  Created by Roderick Presswood on 4/18/24.
//

import Foundation
import Combine

class QuoteViewModel {
    
    enum Input {
        case viewDidAppear
        case refreshButtonDidTap
    }
    
    enum Output {
        case fetchQuoteDidFail(error: Error)
        case fetchQuoteDidSucceed(quote: Quote)
        case toggleButton(isEnabled: Bool)
    }
    
    private let quoteServiceType: QuoteServiceType
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
//    private let output2: CurrentValueSubject<Output, Never> = .init(<#T##value: Output##Output#>)
    
    init(quoteServiceType: QuoteServiceType = QuoteService()) {
        self.quoteServiceType = quoteServiceType
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear:
                self?.handleGetRandomQuote()
            case .refreshButtonDidTap:
                self?.handleGetRandomQuote()
            }
                
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func handleGetRandomQuote() {
        output.send(.toggleButton(isEnabled: false))
        quoteServiceType.getRandomQuote()
            .sink { [weak self] completion in
                self?.output.send(.toggleButton(isEnabled: true))
                if case .failure(let error) = completion {
                    self?.output.send(.fetchQuoteDidFail(error: error))
                }
            } receiveValue: { [weak self] quote in
                self?.output.send(.fetchQuoteDidSucceed(quote: quote))
            }
            .store(in: &cancellables)

    }
}
