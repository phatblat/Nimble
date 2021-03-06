import Foundation

/// A Nimble matcher that succeeds when the actual string satisfies the regular expression
/// described by the expected string.
public func match(_ expectedValue: String?) -> Predicate<String> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        failureMessage.postfixMessage = "match <\(stringify(expectedValue))>"

        if let actual = try actualExpression.evaluate() {
            if let regexp = expectedValue {
                return actual.range(of: regexp, options: .regularExpression) != nil
            }
        }

        return false
    }.requireNonNil
}

#if _runtime(_ObjC)

extension NMBObjCMatcher {
    @objc public class func matchMatcher(_ expected: NSString) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let actual = actualExpression.cast { $0 as? String }
            return try! match(expected.description).matches(actual, failureMessage: failureMessage)
        }
    }
}

#endif
