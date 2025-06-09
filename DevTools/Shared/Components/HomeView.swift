//
//  HomeView.swift
//  DevTools
//
//  Created by DevTools on 9/6/25.
//

import SwiftUI

/// Home page view displaying all available tools in a modern, adaptive grid layout
struct HomeView: View {
    @EnvironmentObject private var router: Router
    
    // MARK: - Layout Constants
    private enum Layout {
        static let horizontalPadding: CGFloat = 32
        static let verticalPadding: CGFloat = 24
        static let mainSpacing: CGFloat = 32
        static let categorySpacing: CGFloat = 20
        static let categoryHeaderSpacing: CGFloat = 12
        static let categoryIconSize: CGFloat = 40
        static let categoryIconCornerRadius: CGFloat = 8
        static let categoryIconFontSize: CGFloat = 20
        static let categoryTitleFontSize: CGFloat = 24
        static let categorySubtitleFontSize: CGFloat = 14
        static let categoryHeaderSubSpacing: CGFloat = 2
        static let footerSpacing: CGFloat = 60
        static let minCardWidth: CGFloat = 280
        static let cardSpacing: CGFloat = 20
        static let maxColumns: Int = 3
        static let totalHorizontalPadding: CGFloat = 64 // For adaptive columns calculation
    }
    
    // Group tools by category for better organization
    private var toolsByCategory: [ToolCategory: [DevTool]] {
        Dictionary(grouping: ToolRegistry.allTools) { $0.category }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: Layout.mainSpacing) {
                    
                    // Tools grid by category
                    ForEach(ToolCategory.allCases, id: \.self) { category in
                        if let tools = toolsByCategory[category], !tools.isEmpty {
                            categorySection(category: category, tools: tools, geometry: geometry)
                        }
                    }
                    
                    // Footer spacer
                    Spacer(minLength: Layout.footerSpacing)
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.vertical, Layout.verticalPadding)
            }
        }
        .navigationTitle("Home")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(NSColor.windowBackgroundColor),
                    Color(NSColor.windowBackgroundColor).opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Category Section
    private func categorySection(category: ToolCategory, tools: [DevTool], geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: Layout.categorySpacing) {
            // Category header with enhanced styling
            HStack(spacing: Layout.categoryHeaderSpacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: Layout.categoryIconCornerRadius)
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: Layout.categoryIconSize, height: Layout.categoryIconSize)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: Layout.categoryIconFontSize, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                
                VStack(alignment: .leading, spacing: Layout.categoryHeaderSubSpacing) {
                    Text(category.rawValue)
                        .font(.system(size: Layout.categoryTitleFontSize, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(tools.count) tool\(tools.count == 1 ? "" : "s") available")
                        .font(.system(size: Layout.categorySubtitleFontSize, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Adaptive grid based on screen width
            let columns = adaptiveColumns(for: geometry.size.width)
            
            LazyVGrid(columns: columns, spacing: Layout.cardSpacing) {
                ForEach(tools, id: \.id) { tool in
                    ModernToolCard(tool: tool) {
                        router.navigate(to: tool.route)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func featureHighlight(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentColor)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private func statCard(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.6))
        )
    }
    
    private func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let availableWidth = width - Layout.totalHorizontalPadding
        let maxColumns = max(1, Int(availableWidth / (Layout.minCardWidth + Layout.cardSpacing)))
        let actualColumns = min(Layout.maxColumns, maxColumns) // Cap at max columns for readability
        
        return Array(repeating: GridItem(.flexible(), spacing: Layout.cardSpacing), count: actualColumns)
    }
}

// MARK: - Modern Tool Card
struct ModernToolCard: View {
    let tool: DevTool
    let action: () -> Void
    
    @State private var isHovered = false
    
    // MARK: - Layout Constants
    private enum Layout {
        static let cardMinHeight: CGFloat = 140
        static let cardPadding: CGFloat = 24
        static let cardCornerRadius: CGFloat = 16
        static let cardContentSpacing: CGFloat = 16
        static let cardInfoSpacing: CGFloat = 8
        static let iconSize: CGFloat = 50
        static let iconCornerRadius: CGFloat = 12
        static let iconFontSize: CGFloat = 24
        static let titleFontSize: CGFloat = 20
        static let descriptionFontSize: CGFloat = 14
        static let actionIconSize: CGFloat = 14
        static let badgeIconSize: CGFloat = 8
        static let badgeFontSize: CGFloat = 10
        static let badgeHorizontalPadding: CGFloat = 8
        static let badgeVerticalPadding: CGFloat = 4
        static let shadowRadius: (normal: CGFloat, hovered: CGFloat) = (8, 20)
        static let shadowOffset: (normal: CGFloat, hovered: CGFloat) = (4, 8)
        static let shadowOpacity: (normal: Double, hovered: Double) = (0.06, 0.12)
        static let strokeWidth: CGFloat = 1.5
        static let scaleEffect: CGFloat = 1.02
        static let animationDuration: CGFloat = 0.25
        static let actionAnimationDuration: CGFloat = 0.2
        static let actionScaleEffect: CGFloat = 1.1
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Header section with icon and category
                VStack(alignment: .leading, spacing: Layout.cardContentSpacing) {
                    HStack {
                        // Tool icon with gradient background
                        ZStack {
                            RoundedRectangle(cornerRadius: Layout.iconCornerRadius)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.accentColor.opacity(0.15),
                                            Color.accentColor.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: Layout.iconSize, height: Layout.iconSize)
                            
                            Image(systemName: tool.icon)
                                .font(.system(size: Layout.iconFontSize, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        // Category badge
                        categoryBadge
                        
                        // Action indicator
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: Layout.actionIconSize, weight: .medium))
                            .foregroundColor(.secondary.opacity(isHovered ? 1.0 : 0.6))
                            .scaleEffect(isHovered ? Layout.actionScaleEffect : 1.0)
                            .animation(.easeInOut(duration: Layout.actionAnimationDuration), value: isHovered)
                    }
                    
                    // Tool information
                    VStack(alignment: .leading, spacing: Layout.cardInfoSpacing) {
                        Text(tool.name)
                            .font(.system(size: Layout.titleFontSize, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(tool.description)
                            .font(.system(size: Layout.descriptionFontSize, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(Layout.cardPadding)
                
                Spacer(minLength: 0)
            }
            .frame(minHeight: Layout.cardMinHeight)
            .background(
                RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(
                        color: Color.black.opacity(isHovered ? Layout.shadowOpacity.hovered : Layout.shadowOpacity.normal),
                        radius: isHovered ? Layout.shadowRadius.hovered : Layout.shadowRadius.normal,
                        x: 0,
                        y: isHovered ? Layout.shadowOffset.hovered : Layout.shadowOffset.normal
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isHovered ? Color.accentColor.opacity(0.3) : Color.clear,
                                isHovered ? Color.accentColor.opacity(0.1) : Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isHovered ? Layout.strokeWidth : 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? Layout.scaleEffect : 1.0)
        .animation(.easeInOut(duration: Layout.animationDuration), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: Layout.animationDuration)) {
                isHovered = hovering
            }
        }
    }
    
    private var categoryBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: tool.category.icon)
                .font(.system(size: Layout.badgeIconSize, weight: .medium))
            
            Text(tool.category.rawValue)
                .font(.system(size: Layout.badgeFontSize, weight: .medium))
        }
        .foregroundColor(.secondary.opacity(0.8))
        .padding(.horizontal, Layout.badgeHorizontalPadding)
        .padding(.vertical, Layout.badgeVerticalPadding)
        .background(
            Capsule()
                .fill(Color.secondary.opacity(0.1))
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(Router())
} 
