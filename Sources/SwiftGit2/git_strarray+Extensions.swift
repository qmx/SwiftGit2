//
//  git_strarray+Extensions.swift
//  libgit2+Extensions
//
//  Created by Mathijs Bernson on 27/08/2021.
//

import Foundation
import libgit2

extension git_strarray {
    func filter(_ isIncluded: (String) -> Bool) -> [String] {
        return map { $0 }.filter(isIncluded)
    }

    func map<T>(_ transform: (String) throws -> T) rethrows -> [T] {
        return try (0 ..< count).map {
            let string = String(validatingUTF8: self.strings[$0]!)!
            return try transform(string)
        }
    }
}
