//
//  TopBar.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct TopBar : View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .padding()
            Spacer()
        }.frame(maxWidth: .infinity).background(Color.gray.opacity(0.2))
    }
}
