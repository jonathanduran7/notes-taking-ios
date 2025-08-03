//
//  PrimaryButton.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    

    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isEnabled ? .sageGreen : Color.gray)
                .cornerRadius(8)
        }
        .disabled(!isEnabled)
    }
}