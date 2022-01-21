//
//  ViewController.swift
//  StandardCombine
//
//  Created by Woody on 2022/1/21.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private var bag = Set<AnyCancellable>()
    @Published
    private var int: Int = 0
    
    private var inn: PassthroughSubject<Int, Never> = PassthroughSubject()
    
    deinit {
        print("\(#file) \(String(describing: self)) is deinit")
    }
    
    var viewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        $int.dropFirst().print().sink(receiveValue: {_ in}).store(in: &bag)
        

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goto)))
        
        
    }

    @objc func goto() {
        let vc = TimerViewController(duration: 10)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
}

