//
//  TimerViewController.swift
//  StandardCombine
//
//  Created by Woody on 2022/1/21.
//

import UIKit
import Combine

class TimerViewController: UIViewController {
    
    deinit {
        print("\(#file) \(String(describing: self)) is deinit")
    }
    
    private var bag = Set<AnyCancellable>()

    let formatter: DateFormatter = {
       let f = DateFormatter()
        f.dateFormat = "mm:ss:SSS"
        return f
    }()
    
    private let clock: ColockView = {
        let c = ColockView()
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    private let closeBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(.init(systemName: "xmark.circle.fill"), for: .normal)
        btn.imageView?.contentMode = .scaleToFill
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let duration: TimeInterval
    
    
    convenience init(duration: TimeInterval) {
        self.init(nibName: nil, bundle: nil, duration: duration)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, duration: TimeInterval) {
        self.duration = duration
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        view.addSubview(clock)
        
        NSLayoutConstraint.activate([
            clock.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4 / 5),
            clock.heightAnchor.constraint(equalTo: clock.widthAnchor, multiplier: 3 / 7 ),
            clock.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clock.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.centerXAnchor.constraint(equalTo: clock.centerXAnchor),
            closeBtn.topAnchor.constraint(equalTo: clock.bottomAnchor, constant: 20),
            closeBtn.heightAnchor.constraint(equalTo: closeBtn.widthAnchor),
            closeBtn.heightAnchor.constraint(equalTo: clock.widthAnchor, multiplier: 1 / 5)
        ])
        
        closeBtn.addTarget(self, action: #selector(disVC), for: .touchUpInside)
        closeBtn.tintColor = .red
    }
    
    fileprivate func createTimer() {
        let timer = TimerController(duration, 0.001)
        
        timer.timeup.receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] _ in  self.dismiss(animated: false, completion: nil)} )
            .store(in: &bag)
        
        
        timer.$countime
            .map({ [unowned self] in return self.formatter.string(from: Date(timeIntervalSince1970: $0))})
            .assign(to: \.text, on: clock)
            .store(in: &bag)
        
        timer.startAndLockInstance()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: timer, action: #selector(timer.c)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createTimer()
    }
    
    @objc private func disVC() {
        self.dismiss(animated: false, completion: nil)
    }

}

extension TimerViewController {
    
    class ColockView: UIView {
        override var bounds: CGRect {
            didSet {
                corners()
                shadowPath()
                font()
            }
        }
        
        let label: UILabel = {
            let lb = UILabel()
            lb.backgroundColor = .clear
            lb.textAlignment = .center
            lb.text = "--:--.---"
            lb.adjustsFontSizeToFitWidth = true
            return lb
        }()
        
        var text: String? {
            didSet {
                label.text = text
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configure()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configure() {
            backgroundColor = .white
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor),
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        private func corners() {
            layer.cornerRadius = bounds.height/5
        }
        
        private func shadowPath() {
            let rect = bounds.insetBy(dx: -0.15, dy: -0.15)
            layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 5).cgPath
            layer.shadowColor = UIColor.systemGray3.cgColor
            layer.shadowOpacity = 0.8
        }
        
        private func font() {
            label.font = .monospacedSystemFont(ofSize: bounds.height, weight: .bold)
        }
        
    }
    
    
}


