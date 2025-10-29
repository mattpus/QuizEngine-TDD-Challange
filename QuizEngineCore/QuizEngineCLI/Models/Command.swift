//
//  Command.swift
//  QuizEngineCore
//
//  Created by Matt on 29/10/2025.
//

import Foundation

enum Command: String {
   case exit
   case quit
   case retry

   static func from(_ input: String) -> Command? {
       Command(rawValue: input.lowercased())
   }
}
