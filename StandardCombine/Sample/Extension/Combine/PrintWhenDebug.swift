//
//  PrintWhenDebug.swift
//  StandardCombine
//
//  Created by Woody on 2022/1/21.
//

import Combine
import Foundation

extension Publisher {
    func printIfDebug()-> Publishers.Print<Self> {
        #if DEBUG || Dev
        return self.print()
        #else
        return self
        #endif
    }
}

