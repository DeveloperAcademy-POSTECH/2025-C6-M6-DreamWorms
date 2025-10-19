//
//  CaseSuspectNameHeader.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

struct CaseSuspectNameHeader: View {
    let suspectName: String
    
    var body: some View {
        HStack {
            Image("icn_my18")
         
            Text(suspectName)
                .font(.pretendardRegular(size: 14))
                .foregroundStyle(Color(.gray8B))
        }
    }
}

#Preview {
    CaseSuspectNameHeader(suspectName: "왕꿈틀")
}
