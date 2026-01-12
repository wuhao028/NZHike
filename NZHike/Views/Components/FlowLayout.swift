//
//  FlowLayout.swift
//  NZHike
//
//  Created by wuhao028 on 12/01/2026.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        if rows.isEmpty { return .zero }
        
        let width = proposal.width ?? 0
        let height = rows.last!.maxY
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        
        for row in rows {
            for element in row.elements {
                element.subview.place(
                    at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + element.y),
                    proposal: .unspecified
                )
            }
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        guard !subviews.isEmpty else { return [] }
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var currentRow = Row(y: 0, elements: [])
        var currentX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && !currentRow.elements.isEmpty {
                // Move to next row
                rows.append(currentRow)
                currentRow = Row(y: currentRow.maxY + spacing, elements: [])
                currentX = 0
            }
            
            currentRow.elements.append(RowElement(x: currentX, y: currentRow.y, subview: subview, size: size))
            currentX += size.width + spacing
        }
        
        if !currentRow.elements.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    struct Row {
        let y: CGFloat
        var elements: [RowElement]
        
        var maxY: CGFloat {
            guard let maxElementHeight = elements.map({ $0.size.height }).max() else { return y }
            return y + maxElementHeight
        }
    }
    
    struct RowElement {
        let x: CGFloat
        let y: CGFloat
        let subview: LayoutSubview
        let size: CGSize
    }
}

struct ChipView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(16)
    }
}
