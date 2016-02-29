# Chirrup

Chirrup is a value validator for Swift.

### Available validation rules(or <a name="validationType">types</a>)

- `IsTrue` -- check if value is True
- `Greater(than: String)` -- check if value is strictly greater than
- `Lower(than: String)` -- check if value is strictly lower than
- `NonEmpty` -- check if value is not empty, uses Swift's `isEmpty`
- `Between(from: String, to: String)`  -- check if value is between two other values. Uses `Greater` and `Lower` rules in its implementation
- `Contains(value: String)` -- check if string contains the value. Case insensitive
- `IsNumeric` -- check if value is numeric one. Tries to convert to `Double?`

Usage
-
![ChirrupDemo](ChirrupDemo.gif)

First create the Chirrup instance

```swift
let chirrup = Chirrup()
```
Then the following metahods are available for use:
```swift
public func validate(fieldName: String, value: String, with rules: [ValidationRule], _ callback: validationCallback? = nil) -> [ValidationRule]
```
```swift
public func validate(fieldName: String, value: String, with rule: ValidationRule,
      _ callback: validationCallbackSingle? = nil) -> ValidationRule?
```
- `fieldName: String` is passed to `callback` if such is provided as the last argument
- `value` to be validated
- `rules` [validation types](#validationType) to validate value with
- and optional `callback` which runs no matter what if passed as an argument. It gets the `errors` array and the field name(`field` below) or just one error - it depends on callback type:
```swift
  public typealias validationCallback       = (errors: [ValidationRule],  fieldName: String) -> ()
  public typealias validationCallbackSingle = (error:  ValidationRule?,   fieldName: String) -> ()
```
Examples:
-
```swift
chirrup.validate("Search field", value: sender.text!,
      with: [ValidationRule(.NonEmpty),
             ValidationRule(.Contains(value: "UberCar"))]) { errors, field in
        let errorMessages = self.chirrup.formatMessagesFor(field, from: errors)
        self.errorLabelSearchField.text = errorMessages
}
// errorMessages == "Search field should not be empty\nSearch field should contain `UberCar`"
```
or instead of closure callback one can use `errors` returned by `validate` method
```swift
let errors = chirrup.validate("Search field", value: sender.text!,
      with: [ValidationRule(.NonEmpty),
             ValidationRule(.Contains(value: "UberCar"))])
expect(chirrup.formatMessagesFor(fieldName, from: errors))
            .to(equal("Search field should not be empty\nSearch field should contain `UberCar`"))
```
or call `validate` with single validation rule(one can use callback closure here as well)
```swift
let error = chirrup.validate("Activator", value: false,
    with: ValidationRule(.IsTrue))

expect(error!.errorMessageFor(fieldName))
    .to(equal("Activate should be true"))
```

### `validate` return value

`errors` and `error` returned above are validation rules themselves and could be initialized with several options and have following constructor
```swift
public init(_ type: ValidationRuleType,
    message: String? = nil, on: (() -> Bool)? = nil)
```
where
- `type` is one of [rules described above](#validationType)
- `message:String?` is optional and represents full error message, e.g. "This field should include 'hey there!' "
- `on` is optional too and you can pass some code which returns `Bool`. In case it returns `true` the validation rule is evaluated otherwise skipped
```swift
let val = ""
let error = chirrup.validate(fieldName, value: val,
              with: ValidationRule(.Lower(than: "10000.00"), on: { !val.isEmpty }))
```
Above validation is skipped.
