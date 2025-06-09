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
    
    // Group tools by category for better organization
    private var toolsByCategory: [ToolCategory: [DevTool]] {
        Dictionary(grouping: ToolRegistry.allTools) { $0.category }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Hero Header Section
                    heroHeaderSection
                    
                    // Quick Stats Section
                    quickStatsSection
                    
                    // Tools grid by category
                    ForEach(ToolCategory.allCases, id: \.self) { category in
                        if let tools = toolsByCategory[category], !tools.isEmpty {
                            categorySection(category: category, tools: tools, geometry: geometry)
                        }
                    }
                    
                    // Footer spacer
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
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
    
    // MARK: - Hero Header Section
    private var heroHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Developer Tools")
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    Text("Professional utilities for modern development workflows")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Decorative element
                Image(systemName: "hammer.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.accentColor.opacity(0.3))
                    .rotationEffect(.degrees(15))
            }
            
            // Feature highlights
            HStack(spacing: 24) {
                featureHighlight(icon: "bolt.fill", text: "Lightning Fast")
                featureHighlight(icon: "shield.fill", text: "Privacy First")
                featureHighlight(icon: "paintbrush.fill", text: "Native Design")
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        HStack(spacing: 20) {
            statCard(title: "\(ToolRegistry.allTools.count)", subtitle: "Developer Tools", icon: "wrench.and.screwdriver")
            statCard(title: "\(ToolCategory.allCases.count)", subtitle: "Categories", icon: "folder.fill")
            statCard(title: "100%", subtitle: "Privacy Focused", icon: "lock.shield")
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Category Section
    private func categorySection(category: ToolCategory, tools: [DevTool], geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Category header with enhanced styling
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(tools.count) tool\(tools.count == 1 ? "" : "s") available")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Adaptive grid based on screen width
            let columns = adaptiveColumns(for: geometry.size.width)
            
            LazyVGrid(columns: columns, spacing: 20) {
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
        let minCardWidth: CGFloat = 280
        let spacing: CGFloat = 20
        let padding: CGFloat = 64 // Total horizontal padding
        
        let availableWidth = width - padding
        let maxColumns = max(1, Int(availableWidth / (minCardWidth + spacing)))
        let actualColumns = min(3, maxColumns) // Cap at 3 columns for readability
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: actualColumns)
    }
}

// MARK: - Modern Tool Card
struct ModernToolCard: View {
    let tool: DevTool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Header section with icon and category
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        // Tool icon with gradient background
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
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
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: tool.icon)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        // Category badge
                        categoryBadge
                        
                        // Action indicator
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary.opacity(isHovered ? 1.0 : 0.6))
                            .scaleEffect(isHovered ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isHovered)
                    }
                    
                    // Tool information
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tool.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(tool.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(24)
                
                Spacer(minLength: 0)
            }
            .frame(minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(
                        color: Color.black.opacity(isHovered ? 0.12 : 0.06),
                        radius: isHovered ? 20 : 8,
                        x: 0,
                        y: isHovered ? 8 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isHovered ? Color.accentColor.opacity(0.3) : Color.clear,
                                isHovered ? Color.accentColor.opacity(0.1) : Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isHovered ? 1.5 : 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.25), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.25)) {
                isHovered = hovering
            }
        }
    }
    
    private var categoryBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: tool.category.icon)
                .font(.system(size: 8, weight: .medium))
            
            Text(tool.category.rawValue)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.secondary.opacity(0.8))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
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