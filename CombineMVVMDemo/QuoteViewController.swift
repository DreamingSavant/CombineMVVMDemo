//
//  ViewController.swift
//  CombineMVVMDemo
//
//  Created by Roderick Presswood on 4/15/24.
//

import UIKit
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


class QuoteViewController: UIViewController {
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    private let vm = QuoteViewModel()
    private let input: PassthroughSubject<QuoteViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        quoteLabel.numberOfLines = 0
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    private func bind() {
        let output = vm.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
//            DispatchQueue.main.async {
                guard let self = self else { return }
                switch event {
                case .fetchQuoteDidFail(let error):
                    self.quoteLabel.text = error.localizedDescription
                case .fetchQuoteDidSucceed(let quote):
                    self.quoteLabel.text = quote.content
                case .toggleButton(let isEnabled):
                    self.refreshButton.isEnabled = isEnabled
                }
//            }
        }.store(in: &cancellables)
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        input.send(.refreshButtonDidTap)
    }
    
    //api below
    // https:/api.quotable.io/random
}

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


struct Quote: Decodable {
    let content: String
    let author: String
}
