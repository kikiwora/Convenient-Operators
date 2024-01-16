//  Created by Roman Suvorov (kikiwora)

@testable import Convenient_Operators
import Nimble
import XCTest

private class UILabelMock: NSObject {
  var text: String = .empty

  override init() {}
}

final class ConvenientOperators_Tests: XCTestCase {
  func test_performAfter_mutates_referenceTypes() {
    let originalLabel = UILabelMock()
    originalLabel.text = "Original"

    let newLabel = originalLabel => {
      $0.text = "New"
    }

    let resultingNewLabelText = newLabel.text
    let resultingOriginalLabelText = originalLabel.text

    expect(resultingNewLabelText).to(
      equal("New"),
      description: "=> operator shall return reference-type object updated by closure"
    )

    expect(resultingOriginalLabelText).to(
      equal("New"),
      description: "=> operator shall update original reference-type object"
    )

    expect(originalLabel === newLabel).to(
      beTrue(),
      description: "=> operator shall return the same reference as original object is"
    )
  }

  func test_performAfter_mutates_valueTypes_withoutAffectingOriginal() {
    struct Label {
      var text: String = .empty
    }

    var originalLabel = Label()
    originalLabel.text = "Original"

    let newLabel = originalLabel ==> {
      $0.text = "New"
    }

    let resultingNewLabelText = newLabel.text
    let resultingOriginalLabelText = originalLabel.text

    expect(resultingNewLabelText).to(
      equal("New"),
      description: "==> operator shall return an updated copy of value-type object"
    )

    expect(resultingOriginalLabelText).to(
      equal("Original"),
      description: "==> operator shall not change original value-type object"
    )
  }

  func test_optional_performAfter_mutates_referenceTypes() {
    let originalLabel: UILabelMock? = .init()
    originalLabel?.text = "Original"

    let newLabel = originalLabel ?=> {
      $0.text = "New"
    }

    let resultingNewLabelText = newLabel?.text
    let resultingOriginalLabelText = originalLabel?.text

    expect(resultingNewLabelText).to(
      equal("New"),
      description: "?=> operator shall return reference-type object updated by closure"
    )

    expect(resultingOriginalLabelText).to(
      equal("New"),
      description: "?=> operator shall update original reference-type object"
    )

    expect(originalLabel === newLabel).to(
      beTrue(),
      description: "?=> operator shall return the same reference as original object is"
    )
  }

  func test_optional_performAfter_doesNotExecuteClosure_whenLeftIsNil_onReferenceTypes() {
    let originalLabel: UILabelMock? = nil

    var didExecuteClosure = false
    originalLabel ?=> { _ in
      didExecuteClosure = true
    }

    expect(didExecuteClosure).to(
      beFalse(),
      description: "?=> operator shall not execute closure when left is nil"
    )
  }

  func test_optional_performAfter_mutates_valueTypes_withoutAffectingOriginal() {
    struct Label {
      var text: String = .empty
    }

    var originalLabel: Label? = .init()
    originalLabel?.text = "Original"

    let newLabel = originalLabel ?==> {
      $0.text = "New"
    }

    let resultingNewLabelText = newLabel?.text
    let resultingOriginalLabelText = originalLabel?.text

    expect(resultingNewLabelText).to(
      equal("New"),
      description: "?==> operator shall return an updated copy of value-type object"
    )

    expect(resultingOriginalLabelText).to(
      equal("Original"),
      description: "?==> operator shall not change original value-type object"
    )
  }

  func test_optional_performAfter_doesNotExecuteClosure_whenLeftIsNil_onValueTypes() {
    struct Label {}
    let originalLabel: Label? = nil

    var didExecuteClosure = false
    _ = originalLabel ?==> { _ in
      didExecuteClosure = true
    }

    expect(didExecuteClosure).to(
      beFalse(),
      description: "?==> operator shall not execute closure when left is nil"
    )
  }

  func test_optionalNegation_negates_optionalTrue() {
    let optionalTrue: Bool? = true
    let negatedOptional = ¬optionalTrue
    expect(negatedOptional).to(
      beFalse(),
      description: "¬ operator shall invert optional true to false"
    )
  }

  func test_optionalNegation_negates_optionalFalse() {
    let optionalFalse: Bool? = false
    let negatedOptional = ¬optionalFalse
    expect(negatedOptional).to(
      beTrue(),
      description: "¬ operator shall invert optional false to true"
    )
  }

  func test_optionalNegation_returnNil_ifOptionalIsNil() {
    let optionalNil: Bool? = nil
    let negatedOptional = ¬optionalNil
    expect(negatedOptional).to(
      beNil(),
      description: "¬ operator shall return nil if argument is nil"
    )
  }

  func test_optionalAssignment_doesNothing_withNil() {
    let optionalNil: String? = nil

    var result = "Test"
    result =? optionalNil

    expect(result).to(
      equal("Test"),
      description: "=? operator shall not assign if argument is nil"
    )
  }

  func test_optionalAssignment_doesAssign_nonNil() {
    let optionalNil: String? = "New"

    var result = "Test"
    result =? optionalNil

    expect(result).to(
      equal("New"),
      description: "=? operator shall assign if argument is not nil"
    )
  }

  func test_optionalAssignment_doesNothing_withNil_whenLeftIsOptional() {
    let optionalNil: String? = nil

    var result: String? = "Test"
    result =? optionalNil

    expect(result).to(
      equal("Test"),
      description: "=? operator shall not assign if argument is nil"
    )
  }

  func test_optionalAssignment_doesAssign_nonNil_whenLeftIsOptional() {
    let optionalNil: String? = "New"

    var result: String? = "Test"
    result =? optionalNil

    expect(result).to(
      equal("New"),
      description: "=? operator shall assign if argument is not nil"
    )
  }

  func test_optionalConditional_returnsValue_whenBool_isTrue() {
    let condition = true
    let result = condition ~? "Value"

    expect(result).to(
      equal("Value"),
      description: "~? operator shall return value when condition is true"
    )
  }

  func test_optionalConditional_returnsNil_whenBool_isFalse() {
    let condition = false
    let result = condition ~? "Value"

    expect(result).to(
      beNil(),
      description: "~? operator shall return nil when condition is false"
    )
  }

  func test_optionalConditional_returnsValue_whenOptional_isSome() {
    let optional: String? = "Some"
    let result = optional ~? "Value"

    expect(result).to(
      equal("Value"),
      description: "~? operator shall return value when optional is some"
    )
  }

  func test_optionalConditional_returnsNil_whenOptional_isNone() {
    let optional: String? = nil
    let result = optional ~? "Value"

    expect(result).to(
      beNil(),
      description: "~? operator shall return nil when optional is none"
    )
  }
}
