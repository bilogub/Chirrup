//
//  ValidationRule.swift
//  Chirrup
//
//  Created by Yuriy Bilogub on 2016-01-27.
//  Copyright © 2016 Yuriy Bilogub. All rights reserved.
//

public struct ValidationRule {
  let type: ValidationRuleType
  let message: String?
  let evaluateIf: (() -> Bool)?
  
  public init(_ type: ValidationRuleType,
    message: String? = nil, on: (() -> Bool)? = nil) {
      self.type = type
      self.message = message
      self.evaluateIf = on
  }
  
  public func errorMessageFor(field: String, should: String? = nil) -> String {
    if let message = message {
      return message
    } else {
      return type.errorMessageFor(field, should: should)
    }
  }
  
  public enum ValidationRuleType {
    case IsTrue
    case Greater(than: String)
    case Lower(than: String)
    case NonEmpty
    case Between(from: String, to: String)
    case Contains(value: String)
    case IsNumeric
    
    /// Human-readable messages for failed `ValidationRule`
    public func errorMessageFor(field: String, should: String? = nil) -> String {
      switch self {
      case .IsTrue:                     return "\(field) should \(should ?? "be true")"
      case .Greater(let than):          return "\(field) should \(should ?? "be greater than \(than)")"
      case .Lower(let than):            return "\(field) should \(should ?? "be lower than \(than)")"
      case .NonEmpty:                   return "\(field) should \(should ?? "not be empty")"
      case .Between(let from, let to):  return "\(field) should \(should ?? "be between \(from) and \(to)")"
      case .Contains(let value):        return "\(field) should \(should ?? "contain `\(value)`")"
      case .IsNumeric:                  return "\(field) should \(should ?? "be a number")"
      }
    }
  }
}
