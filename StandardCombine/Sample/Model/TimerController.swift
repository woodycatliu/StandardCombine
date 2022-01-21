//
//  TimerController.swift
//  StandardCombine
//
//  Created by Woody on 2022/1/21.
//

import Foundation
import Combine
import UIKit

class TimerController {
    
    deinit {
        print("\(#file): \(type(of: self)) - is deinit")
    }
    
    private var bag = Set<AnyCancellable>()
    
    private var timer: Cancellable?
    
    private var _lockedSelf: TimerController?
    
    @Published
    private(set) var countime: TimeInterval = 0
    
    let timeup: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private(set) var every: TimeInterval = 1 {
        didSet {
            start(duration)
        }
    }
    
    private(set) var duration: TimeInterval = 10
    
    private(set) var releaseWhenTimeup: Bool = true {
        didSet {
            start(duration)
        }
    }
    
    init(_ duration: TimeInterval? = nil, _ every: TimeInterval? = nil) {
        if let every = every {
            self.every = every
        }
        
        if let duration = duration {
            self.duration = duration
        }
        binnding()
    }
    
    func setEvery(_ value: TimeInterval)-> TimerController {
        every = value
        return self
    }
    
    func setDuration(_ value: TimeInterval)-> TimerController {
        self.duration = value
        return self
    }
    
    func setReleaseWhenTimeup(_ bool: Bool) {
        releaseWhenTimeup = bool
    }
}

extension TimerController {
    private func binnding() {
        $countime.filter({[unowned self] in self.duration <= $0 })
            .print()
            .share()
            .map{ _ in }
            .assign(to: \.timeup, on: self)
            .store(in: &bag)
        
        timeup.filter({ [unowned self] in self.releaseWhenTimeup })
            .sink(receiveValue: {[unowned self] _ in self.release()})
            .store(in: &bag)

        timeup.sink(receiveValue: { [unowned self] in self.close() })
            .store(in: &bag)
    }
}

extension TimerController {
    
    func startAndLockInstance() {
        _lockedSelf = self
        start()
    }
    
    func lockInstance() {
        _lockedSelf = self
    }
    
    func release() {
        _lockedSelf = nil
    }
}
 
extension TimerController {
    
    private func close() {
        timer?.cancel()
    }
    
    private func start(_ beginTime: TimeInterval?) {
        close()
        
        if let beginTime = beginTime {
            duration = beginTime
        }
        timer = Timer.publish(every: every, on: .current, in: .default)
            .autoconnect()
            .scan(countime) { [unowned self] value, _ in value + self.every }
            .map { [unowned self] in $0 >= self.duration ? self.duration : $0 }
            .assign(to: \.countime, on: self)
        
    }
    
    func start() {
        start(nil)
    }
    
    func restart() {
        start(0)
    }
    
    @objc func c() {
        if timer != nil {
            timer = nil
        }
        else {
            start()
        }
    }
}




