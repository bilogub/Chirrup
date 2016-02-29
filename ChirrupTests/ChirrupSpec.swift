//
//  ChirrupSpec.swift
//  Chirrup
//
//  Created by Yuriy Bilogub on 2016-01-25.
//  Copyright © 2016 Yuriy Bilogub. All rights reserved.
//

import Quick
import Nimble
import Chirrup

class ChirrupSpec: QuickSpec {

  override func spec() {
    let chirrup = Chirrup()
    var fieldName = ""
    
    describe("Single validation rule") {
      
      describe(".isTrue") {
        beforeEach {
          fieldName = "Activate"
        }
        
        context("When `Activate` is switched Off") {
          it("should return an error") {
            let error = chirrup.validate(fieldName, value: false,
              with: ValidationRule(.IsTrue))
            
            expect(error!.errorMessageFor(fieldName))
              .to(equal("Activate should be true"))
          }
          
          context("When rule evaluation is skipped") {
            it("should not return an error") {
              let error = chirrup.validate(fieldName, value: false,
                with: ValidationRule(.IsTrue, on: { false }))
              
              expect(error).to(beNil())
            }
          }
        }

        context("When `Activate` is switched On") {
          it("should not return an error") {
            let error = chirrup.validate(fieldName, value: true,
              with: ValidationRule(.IsTrue))
            
            expect(error).to(beNil())
          }
        }
      }
      
      describe(".NonEmpty") {
        beforeEach {
          fieldName = "Greeting"
        }
        
        context("When `Greeting` is empty") {
          it("should return an error") {
            let error = chirrup.validate(fieldName, value: "",
              with: ValidationRule(.NonEmpty))
            
            expect(error!.errorMessageFor(fieldName))
              .to(equal("Greeting should not be empty"))
          }
        }
        
        context("When `Greeting` is set to value") {
          it("should not return an error") {
            let error = chirrup.validate(fieldName, value: "hey there!",
              with: ValidationRule(.NonEmpty))
            
            expect(error).to(beNil())
          }
        }
      }
      
      describe(".Greater") {
        beforeEach {
          fieldName = "Min. Price"
        }
        
        context("When `Min. Price` is empty") {
          context("When rule evaluation is skipped") {
            it("should not return an error because validation is skipped") {
              let val = ""
              let error = chirrup.validate(fieldName, value: val,
                with: ValidationRule(.Greater(than: "5499.98"), on: { !val.isEmpty }))
              
              expect(error).to(beNil())
            }
          }
          
          context("When rule evaluation is not skipped") {
            it("should return an error") {
              let error = chirrup.validate(fieldName, value: "",
                with: ValidationRule(.Greater(than: "5499.98")))
              
              expect(error!.errorMessageFor(fieldName))
                .to(equal("Min. Price should be a number"))
            }
          }
        }
        
        context("When `Min. Price` is set to a NaN value") {
          it("should return an error") {
            let error = chirrup.validate(fieldName, value: "two hundred",
              with: ValidationRule(.Greater(than: "5499.98")))
            
            expect(error!.errorMessageFor(fieldName))
              .to(equal("Min. Price should be a number"))
          }
        }
        
        context("When `Min. Price` is set to a equal value") {
          it("should return an error") {
            let val = "5499.98"
            let error = chirrup.validate(fieldName, value: val,
              with: ValidationRule(.Greater(than: val)))
            
            expect(error!.errorMessageFor(fieldName))
              .to(equal("Min. Price should be greater than \(val)"))
          }
        }
        
        context("When `Min. Price` is set to a greater value") {
          it("should return an error") {
            let error = chirrup.validate(fieldName, value: "5499.99",
              with: ValidationRule(.Greater(than: "5499.98")))
            
            expect(error).to(beNil())
          }
        }
      }
    }
    
    describe(".Lower") {
      beforeEach {
        fieldName = "Max. Price"
      }
      
      context("When `Max. Price` is empty") {
        context("When rule evaluation is skipped") {
          it("should not return an error") {
            let val = ""
            let error = chirrup.validate(fieldName, value: val,
              with: ValidationRule(.Lower(than: "10000.00"), on: { !val.isEmpty }))
            
            expect(error).to(beNil())
          }
        }
        
        context("When rule evaluation is not skipped") {
          it("should return an error") {
            let error = chirrup.validate(fieldName, value: "",
              with: ValidationRule(.Lower(than: "10000.00")))
            
            expect(error!.errorMessageFor(fieldName))
              .to(equal("Max. Price should be a number"))
          }
        }
      }
      
      context("When `Max. Price` is set to a NaN value") {
        it("should return an error") {
          let error = chirrup.validate(fieldName, value: "ten thousand",
            with: ValidationRule(.Lower(than: "10000.00")))
          
          expect(error!.errorMessageFor(fieldName))
            .to(equal("Max. Price should be a number"))
        }
      }
      
      context("When `Max. Price` is set to a equal value") {
        it("should return an error") {
          let val = "10000.00"
          let error = chirrup.validate(fieldName, value: val,
            with: ValidationRule(.Lower(than: val)))
          
          expect(error!.errorMessageFor(fieldName))
            .to(equal("Max. Price should be lower than \(val)"))
        }
      }
      
      context("When `Max. Price` is set to a greater value") {
        it("should return an error") {
          let error = chirrup.validate(fieldName, value: "9999.99",
            with: ValidationRule(.Lower(than: "10000.00")))
          
          expect(error).to(beNil())
        }
      }
    }
    
    describe(".Between") {
      beforeEach {
        fieldName = "Gear Number"
      }
      
      context("When `Gear Number` is set to a lower value than possible") {
        it("should return an error") {
          let error = chirrup.validate(fieldName, value: "0",
            with: ValidationRule(.Between(from: "4", to: "6")))
          
          expect(error!.errorMessageFor(fieldName))
            .to(equal("Gear Number should be between 4 and 6"))
        }
        
        it("should not return an error") {
          let error = chirrup.validate(fieldName, value: "5",
            with: ValidationRule(.Between(from: "4", to: "6")))
          
          expect(error).to(beNil())
        }

      }
    }
    
    describe(".IsNumeric") {
      beforeEach {
        fieldName = "Gear Number"
      }
      
      context("When `Gear Number` is set to a NaN value") {
        it("should return an error") {
          let error = chirrup.validate(fieldName, value: "five",
            with: ValidationRule(.IsNumeric))
          
          expect(error!.errorMessageFor(fieldName))
            .to(equal("Gear Number should be a number"))
        }
      }
      
      context("When `Gear Number` is empty") {
        it("should return an error") {
          let error = chirrup.validate(fieldName, value: "",
            with: ValidationRule(.IsNumeric))
          
          expect(error!.errorMessageFor(fieldName, should: "be a positive number"))
            .to(equal("Gear Number should be a positive number"))
        }
      }
      
      context("When `Gear Number` is a number") {
        it("should not return an error") {
          let error = chirrup.validate(fieldName, value: "5",
            with: ValidationRule(.IsNumeric))
          
          expect(error).to(beNil())
        }
      }
    }
  
    describe("Multiple validation rules") {
  
      describe(".Contains .NonBlank") {
        beforeEach {
          fieldName = "Greeting"
        }

        it("should return .Contains and .NonEmpty errors") {
          let errors = chirrup.validate(fieldName, value: "",
            with: [ValidationRule(.NonEmpty, message: "Couple greeting words here?"),
                  ValidationRule(.Contains(value: "hey there!"))])
          
          expect(chirrup.formatMessagesFor(fieldName, from: errors))
            .to(equal("Couple greeting words here?\nGreeting should contain `hey there!`"))
        }
        
        context("When we have a greeting but not the one we expect") {
          it("should return .Contains error only") {
            let errors = chirrup.validate(fieldName, value: "hey!",
              with: [ValidationRule(.NonEmpty),
                ValidationRule(.Contains(value: "hey there!"))])
            
            expect(chirrup.formatMessagesFor(fieldName, from: errors))
              .to(equal("Greeting should contain `hey there!`"))
          }
          
          context("When rule evaluation is skipped") {
            it("should return empty error array") {
              let errors = chirrup.validate(fieldName, value: "hey!",
                with: [ValidationRule(.NonEmpty),
                  ValidationRule(.Contains(value: "hey there!"), on: { 1 < 0 })])
              
              expect(errors).to(beEmpty())
            }
          }
          
          context("When rule evaluation is not skipped") {
            it("should return .Contains error only") {
              let errors = chirrup.validate(fieldName, value: "hey!",
                with: [ValidationRule(.NonEmpty),
                  ValidationRule(.Contains(value: "hey there!"), on: { 1 > 0 })])
              
              expect(chirrup.formatMessagesFor(fieldName, from: errors))
                .to(equal("Greeting should contain `hey there!`"))

            }
          }
        }
      }
    }
  }
}