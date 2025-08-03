//
//  SecondaryButton.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .normal
    
    enum ButtonStyle {
        case normal
        case destructive
    }
    
    private let sageGreen = Color(red: 0.51, green: 0.60, blue: 0.57) // #819A91
    private let sageMedium = Color(red: 0.65, green: 0.76, blue: 0.66) // #A7C1A8
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(style == .destructive ? .red : sageGreen)
                .frame(maxWidth: .infinity, maxHeight: 44)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style == .destructive ? Color.red : sageMedium, lineWidth: 1)
                )
        }
    }
}