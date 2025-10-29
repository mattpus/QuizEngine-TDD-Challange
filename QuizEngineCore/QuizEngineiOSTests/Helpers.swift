//
//  Helpers.swift
//  QuizEngineCore
//
//  Created by Matt on 28/10/2025.
//

import XCTest
import Foundation

extension XCTestCase {
    @MainActor
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
