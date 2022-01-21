//
//  AssignToPassthoughSubject.swift
//  StandardCombine
//
//  Created by Woody on 2022/1/21.
//

import Combine

extension Publisher where Self.Failure == Never {
    
    func assign<Root: AnyObject>(to keyPath: KeyPath<Root, PassthroughSubject<Self.Output, Self.Failure>>, on object: Root) -> AnyCancellable {
        return sink(receiveValue: { [weak object] output in
            object?[keyPath: keyPath].send(output)
        })
    }
    
   
}
