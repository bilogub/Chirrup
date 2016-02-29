//
//  Chirrup.swift
//  Chirrup
//
//  Created by Yuriy Bilogub on 2016-01-25.
//  Copyright © 2016 Yuriy Bilogub. All rights reserved.
//

public class Chirrup {
  
  public init() {}
  
  public typealias validationCallback       = (errors: [ValidationRule],  fieldName: String) -> ()
  public typealias validationCallbackSingle = (error:  ValidationRule?,   fieldName: String) -> ()
  
  /// Format message for `field` from all `failedRules` it has after `validate`
  /// method completed
  public func formatMessagesFor(field: String,
      from failedRules: [ValidationRule], _ separator: String = "\n") -> String {
      
    return failedRules.map { $0.errorMessageFor(field) }.joinWithSeparator(separator)
  }
  
  /// Validates String value.
  ///
  /// Accepts multiple rules and a `callback` to run after validation
  /// Available validations: NonEmpty, Contains, Greater, Lower, Between
  public func validate(fieldName: String, value: String, with rules: [ValidationRule],
      _ callback: validationCallback? = nil) -> [ValidationRule] {
      
    var failedRules = [ValidationRule]()
    
    for rule in rules {
      if let error = validate(fieldName, value: value, with: rule) {
        failedRules.append(error)
      }
    }
        
    callback?(errors: failedRules, fieldName: fieldName)
    
    return failedRules
  }

  /// Validates String value.
  ///
  /// Accepts single rule and a `callback` to run after validation
  /// Available validations: NonEmpty, Contains, Greater, Lower, Between
  public func validate(fieldName: String, value: String, with rule: ValidationRule,
      _ callback: validationCallbackSingle? = nil) -> ValidationRule? {
        
    if rule.evaluateIf != nil && !rule.evaluateIf!() {
      return nil
    }
    
    var failedRule: ValidationRule?
    
    switch rule.type {
    case .NonEmpty:
      if value.isEmpty {
        failedRule = rule
      }
      
    case .Contains(let searched):
      if value.rangeOfString(searched, options: .CaseInsensitiveSearch) == nil {
        failedRule = rule
      }
      
    case .Greater(let other):
      if let val = Double(value), comparedTo = Double(other) {
        if val <= comparedTo {
          failedRule = rule
        }
      }
      else {
        failedRule = ValidationRule(.IsNumeric)
      }
      
    case .Lower(let other):
      if let val = Double(value), comparedTo = Double(other) {
        if val >= comparedTo {
          failedRule = rule
        }
      }
      else {
        failedRule = ValidationRule(.IsNumeric)
      }
      
    case .Between(let from, let to):
      validate(fieldName, value: value,
        with: [ValidationRule(.Greater(than: from)),
               ValidationRule(.Lower(than: to))]) { errors, _ in

          if !errors.isEmpty  { failedRule = rule }
      }
    
    case .IsNumeric:
      if Double(value) == nil {
        failedRule = ValidationRule(.IsNumeric)
      }
    default: break
    }

    callback?(error: failedRule, fieldName: fieldName)
      
    return failedRule
  }

  /// Validates Bool value.
  ///
  /// Accepts single rule and a `callback` to run after validation
  /// Available validations: IsTrue
  public func validate(fieldName: String, value: Bool, with rule: ValidationRule,
      _ callback: validationCallbackSingle? = nil) -> ValidationRule? {

    var failedRule: ValidationRule?
        
    if rule.evaluateIf == nil || rule.evaluateIf!() {
      if !value { failedRule = rule }
    }
      
    callback?(error: failedRule, fieldName: fieldName)
    
    return failedRule
  }
}
