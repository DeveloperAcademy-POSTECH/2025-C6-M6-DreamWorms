//
//  DashboardSectionHeader.swift
//  SUSA24-iOS
//
//  Created by mini on 11/3/25.
//

import SwiftUI

struct DashboardSectionHeader: View {
    let title: String
    var description: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.titleSemiBold18)
                .foregroundStyle(.black)
            
            if let description {
                Text(description)
                    .font(.bodyMedium12)
                    .foregroundStyle(.labelAlternative)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension DashboardSectionHeader {
    @discardableResult
    func setupDescription(_ text: String) -> Self {
        var v = self; v.description = text; return v
    }
}
