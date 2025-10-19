//
//  CaseCellDataLocationCount.swift
//  DreamWorms-iOS
//
//  Created by Demian Yoo on 10/19/25.
//

import SwiftUI

struct CaseCellDataLocationCount: View {
    let dataLocationCount: Int
    
    var body: some View {
        HStack {
            Image("icn_pin18")
            
            Text(.pinCount(dataLocationCount: dataLocationCount))
                .font(.pretendardRegular(size: 14))
                .foregroundStyle(Color(.gray8B))
        }
    }
}

#Preview {
    CaseCellDataLocationCount(dataLocationCount: 27)
}
