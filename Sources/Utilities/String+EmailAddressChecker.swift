//
//  String+EmailAddressChecker.swift
//  
//
//  Created by Georg Tuparev on 29/01/2022.
//  Copyright © See Framework's LICENSE file
//

import Foundation

// A simple `String` extension, checking the validity of an email address

extension String {

    /// Checks if `self` is a valid email address format
    ///
    /// **Note:** This method does not check if the email address exists or not. It only validates the format
    /// of `self`.
    public func isValidEmailAddress() -> Bool {
        guard self.lengthOfBytes(using: .utf8) > 5 else { return false }

        let emailRegEx = "[A-Z0-9a-z.\\-_]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: self)
    }

}
