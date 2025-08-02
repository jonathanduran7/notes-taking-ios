//
//  Cards.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct Cards: View {
    var body: some View {
        VStack {
            Text("Card")
        }
        .frame(width: 150, height: 150)
        .background(Color.red)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}