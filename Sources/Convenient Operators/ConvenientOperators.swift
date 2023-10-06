//  Created by Roman Suvorov (kikiwora)

import Foundation

// MARK: - Perform After

infix operator =>: MultiplicationPrecedence
/// **perform after** operator for reference types
/// # Example for new reference-type object
/// ```
/// let label = UILabel() => {          // A new object is created, updated and then reference to it is returned
///     $0.backgroundColor = .black     // Immediate initial configuration shall be done like, instead of doing it in life cycle methods
/// }
/// lazy var button = UIButton() => {   // Can also be lazy
///     $0.title = "Done"
/// }
/// ```
/// # Example for existing reference-type object
/// ```
/// var label = UILabel()               // Subviews are created once and reused instead of being created anew every render
/// ...
/// func render(with props: Props) {
///     self.view.subviews = [
///         label => {                  // This will change original label and return reference to it after update
///             $0.backgroundColor  = props.backgroundColor
///             $0.title            = props.label
///         },
///         ...
///     ]
/// }
/// ```
/// - Parameters:
///   - object: reference-type `Object`, on which further operations will be performed by `Closure`
///   - closure: `Closure` with a set of operations to be performed on reference-type `Object`
/// - Returns: reference to updated `Object`
@discardableResult
public func => <T>(object: T, closure: (T) -> Void) -> T {
  closure(object)
  return object
}

infix operator ==>: MultiplicationPrecedence
/// **perform after** operator for value types
/// # Example for value type object
/// ```
/// struct Context {
///     var name: String = .empty
/// }
///
/// var originalContext = Context()
/// let newContext = originalContext => {   // This will not update originalContext but return an updated copy of it
///     $0.name = "Garry"
/// }
/// ```
/// - Parameters:
///   - object: value-type `Object`, on which further operations will be performed by `Closure`
///   - closure: `Closure` with a set of operations to be performed on value-type `Object`
/// - Returns: New `Object` copy with updated state
public func ==> <T>(object: T, closure: (inout T) -> Void) -> T {
  var object = object
  closure(&object)
  return object
}

// MARK: - Optional Perform After

infix operator ?=>: MultiplicationPrecedence
/// **optional perform after** operator for reference-types
/// ⚠️ `Closure` is executed only if `Object` exists
/// # Example for reference-types
/// ```
/// class Badge: UIView {
///     var badgeSize: Size
///     var badgeName: String
///     ...
/// }
/// let badge: Badge? = ...
/// let badgeToRender = badge ?=> { // This scope is executed only when badge != nil, otherwise badgeToRender will be nil
///     $0.badgeSize = .huge
///     $0.badgeName = .empty
/// }
/// // Original reference-type objects is changed and reference to it is returned
/// ```
/// - Parameters:
///   - object: `Optional` reference-type `Object`, on which further operations may be performed by `Closure` if this reference-type `Object` is not `nil`
///   - closure: `Closure` with a set of operations to be performed on reference-type `Object`
/// - Returns: `Optional` reference-type `Object` on which `Closure` was performed if the `Object` is not `nil`, otherwise, returns `nil`
@discardableResult
public func ?=> <T>(object: T?, closure: (T) -> Void) -> T? {
  guard let object else { return nil }
  return object => closure
}

infix operator ?==>: MultiplicationPrecedence
/// **optional perform after** operator for value-types
/// ⚠️ `Closure` is executed only if `Object` exists
/// # Example for value-types
/// ```
/// struct Item {
///      var name: String
/// }
/// var originalItem: Item? = ...
/// let updatedItem = originalItem ?==> { // This scope is executed only when originalItem != nil, otherwise updatedItem will be nil
///     $0.name = .empty
/// }
/// // Only updatedItem has updated state, while originalItem remains unchanged
/// ```
/// - Parameters:
///   - object: `Optional` value-type `Object`, on which further operations may be performed by `Closure` if this `Object` is not `nil`
///   - closure: `Closure` with a set of operations to be performed on value-type `Object`
/// - Returns: `Optional` value-type `Object` on which closure was performed if the `Object` was not `nil`, otherwise, returns `nil`
public func ?==> <T>(object: T?, closure: (inout T) -> Void) -> T? {
  guard let object else { return nil }
  return object ==> closure
}

// MARK: - Optional Negattion

prefix operator ¬
/// **optional negation** operator
/// Negates `Bool ` value of `Optional` if not `nil`
/// # Example
/// ```
/// // Instead of this
/// var isDisabledOptional? = ...
/// if let isDisabled = isDisabledOptional {
///      config.isEnabled = !isDisabled
/// }
/// // Do this
/// config.isEnabled = ¬isDisabledOptional   // Use ⌥ + L to insert ¬ symbol
/// ```
/// - Parameter right: `Bool?`
/// - Returns: **Negated** `right: Bool` or `nil` if **right** is `nil`
public prefix func ¬ (right: Bool?) -> Bool? {
  guard let right else { return nil }
  return !right
}

// MARK: - Conditional Optional

infix operator ~?: TernaryPrecedence
/// **conditional optional** operator to use with **sparse** arrays *(arrays with optional elements)*
/// Allows for element being present in array **only** when it is **necessary** and be **absent** **otherwise**
/// ⚠️ Behaves like Ternary operator. Has the same precedence,  right associative
/// # Example for Optional
/// ```
/// let badgeName: String? = ...
/// view.subviews  = .compact([
///     nameLabel,                  // nameLabel is not under any condition and will be always present
///     badgeName ~? badgeView => { // The badgeView is shown only when badgeName is not nil
///         $0.badge =? badgeName   // badgeName can be applied immediately, though it is still optional
///     }
/// ])
/// ```
/// # Example for Bool
/// ```
/// let props: Props = ...
/// view.subviews  = .compact([
///     nameLabel,                          // nameLabel is not under any condition and will be always present
///     props.shouldShowBadge ~? badgeView  // The badgeView is shown only when shouldShowBadge is true
/// ])
/// ```
/// - Parameters:
///   - left: `Optional` or `Bool?` - the condition of **right** to be returned
///   - right: `Optional` to be returned depending on `left: Optional` being `true` if `Bool` type or `.some` if `Optional` type
/// - Returns: `right: Optional` if `left: Optional` is not `nil` or `left: Bool?` is `true`, otherwise, returns `nil`
public func ~? <T>(left: (some Any)?, right: T?) -> T? {
  switch left {
  case let .some(someLeft):
    if let checkup = someLeft as? Bool {
      return checkup ? right : nil
    } else {
      return right
    }
  case .none:
    return nil
  }
}

// MARK: - Optional Assign

infix operator =?: AssignmentPrecedence
/// **optional assign** operator
/// # Example
/// ```
/// // Instead of this
/// var optionalText: String? = ...
/// if let text = optionalText {
///      label.text = text
/// }
/// // Do this
/// label.text =? optionalText  // label.text will change only when optionalText is not nil
/// ```
/// - Parameters:
///   - left: WIll be assigned **unwrapped** value of `right: Optional` if `right` is not `nil`
///   - right: `Optional` `object` to assign into `left` if not `nil`
public func =? <T>(left: inout T, right: T?) {
  guard let newLeft = right else { return }
  left = newLeft
}

// swiftlint:enable identifier_name
