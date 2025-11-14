//
//  View+HideKeyboard.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/14/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
