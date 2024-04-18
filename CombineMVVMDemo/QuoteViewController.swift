//
//  ViewController.swift
//  CombineMVVMDemo
//
//  Created by Roderick Presswood on 4/15/24.
//

import UIKit
import Combine

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

