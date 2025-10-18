//
//  ContentView.swift
//  DreamWorms-iOS
//
//  Created by Moo on 10/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text(.test)
                .font(.pretendardBold(size: 28))
            Text(.test)
                .font(.pretendardSemiBold(size: 28))
            Text(.test)
                .font(.pretendardMedium(size: 28))
            Text(.test)
                .font(.pretendardRegular(size: 28))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
