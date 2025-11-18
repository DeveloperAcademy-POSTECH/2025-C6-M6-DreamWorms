//
//  DWBottomToolbar.swift
//  SUSA24-iOS
//
//  Created by taeni on 11/13/25.
//

import SwiftUI

// MARK: - Toolbar Item Configuration

struct DWBottomToolbarItem: Identifiable {
    let id = UUID()
    let type: ItemType
    
    enum ItemType {
        case button(systemImage: String, action: () -> Void)
        case imageButton(image: Image, action: () -> Void)
        case menu(image: Image, menuItems: [MenuItem])
        case divider
        case spacer
        case fixedSpace(CGFloat)
    }
    
    struct MenuItem: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        let role: ButtonRole?
        let action: () -> Void
    }
    
    // MARK: - Configurable Params
    
    var isEnabled: Bool = true
    var iconSize: CGFloat = 16
    var frameSize: CGFloat = 44
    var iconColor: Color = .black
    var padding: EdgeInsets = .init()
}

// MARK: - Factory Methods

extension DWBottomToolbarItem {
    static func button(_ systemImage: String, action: @escaping () -> Void) -> Self {
        Self(type: .button(systemImage: systemImage, action: action))
    }
    
    /// 새로운 size 오버로드
    static func button(
        _ systemImage: String,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> Self {
        Self(type: .button(systemImage: systemImage, action: action))
            .iconSize(size)
    }
    
    static func button(image: Image, action: @escaping () -> Void) -> Self {
        Self(type: .imageButton(image: image, action: action))
    }
    
    static func menu(image: Image, items: [MenuItem]) -> Self {
        Self(type: .menu(image: image, menuItems: items))
    }
    
    static var divider: Self {
        Self(type: .divider)
    }
    
    static var spacer: Self {
        Self(type: .spacer)
    }
    
    static func fixedSpace(_ width: CGFloat) -> Self {
        Self(type: .fixedSpace(width))
    }
}

// MARK: - Progressive Parameters

extension DWBottomToolbarItem {
    @discardableResult
    func disabled(_ condition: Bool) -> Self {
        var copy = self
        copy.isEnabled = !condition
        return copy
    }
    
    @discardableResult
    func iconSize(_ size: CGFloat) -> Self {
        var copy = self
        copy.iconSize = size
        return copy
    }
    
    @discardableResult
    func frameSize(_ size: CGFloat) -> Self {
        var copy = self
        copy.frameSize = size
        return copy
    }
    
    @discardableResult
    func iconColor(_ color: Color) -> Self {
        var copy = self
        copy.iconColor = color
        return copy
    }
    
    @discardableResult
    func setupPadding(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) -> Self {
        var copy = self
        copy.padding = EdgeInsets(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )
        return copy
    }
}

// MARK: - Dynamic Builder Example

extension DWBottomToolbarItem {
    static func pinButton(
        hasPinned: Bool,
        onAddPin: @escaping () -> Void,
        onRemovePin: @escaping () -> Void
    ) -> DWBottomToolbarItem {
        if hasPinned {
            .button("pin.fill", action: onRemovePin)
        } else {
            .button("pin", action: onAddPin)
        }
    }
}

// MARK: - Toolbar View

struct DWBottomToolbar: View {
    let items: [DWBottomToolbarItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                switch item.type {
                    // MARK: Button
                    
                case let .button(systemImage, action):
                    Button(action: action) {
                        Image(systemName: systemImage)
                            .renderingMode(.template)
                            .font(.system(size: item.iconSize))
                            .foregroundStyle(item.iconColor)
                            .frame(width: item.frameSize, height: item.frameSize)
                    }
                    .padding(item.padding)
                    .buttonStyle(.borderless)
                    .disabled(!item.isEnabled)
                    
                    // MARK: Image Button
                    
                case let .imageButton(image, action):
                    Button(action: action) {
                        image
                            .renderingMode(.template)
                            .font(.system(size: item.iconSize))
                            .foregroundStyle(item.iconColor)
                            .frame(width: item.frameSize, height: item.frameSize)
                    }
                    .padding(item.padding)
                    .buttonStyle(.borderless)
                    .disabled(!item.isEnabled)
                    
                    // MARK: Menu
                    
                case let .menu(image, menuItems):
                    Menu {
                        ForEach(menuItems) { menuItem in
                            Button(role: menuItem.role) {
                                menuItem.action()
                            } label: {
                                Label(menuItem.title, systemImage: menuItem.systemImage)
                            }
                        }
                    } label: {
                        image
                            .renderingMode(.template)
                            .font(.system(size: item.iconSize))
                            .foregroundStyle(item.iconColor)
                            .frame(width: item.frameSize, height: item.frameSize)
                            .contentShape(Rectangle())
                            .padding(item.padding)
                    }
                    .buttonStyle(.borderless)
                    .menuOrder(.fixed)
                    .menuActionDismissBehavior(.automatic)
                    .disabled(!item.isEnabled)
                    
                    // MARK: Divider
                    
                case .divider:
                    Divider()
                        .frame(height: 24)
                    
                    // MARK: Spacer
                    
                case .spacer:
                    Spacer(minLength: 0)
                    
                    // MARK: Fixed space
                    
                case let .fixedSpace(width):
                    Spacer()
                        .frame(width: width)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

// MARK: - Modifier

struct DWBottomToolbarModifier: ViewModifier {
    let alignment: Alignment
    let padding: EdgeInsets
    let items: [DWBottomToolbarItem]
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                DWBottomToolbar(items: items)
                    .padding(padding)
                    .zIndex(999)
            }
    }
}

extension View {
    func dwBottomToolBar(
        alignment: Alignment = .bottom,
        padding: EdgeInsets = EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 8),
        items: [DWBottomToolbarItem]
    ) -> some View {
        modifier(
            DWBottomToolbarModifier(
                alignment: alignment,
                padding: padding,
                items: items
            )
        )
    }
}

// MARK: - Preview

// #Preview("Custom Size Buttons") {
//    MapWithCustomSizesPreview()
// }
//
// private struct MapWithCustomSizesPreview: View {
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(.blue.opacity(0.1))
//                .ignoresSafeArea()
//        }
//        .dwBottomToolBar(items: [
//            .button(image: Image(.pin), action: {
//                print("pin tapped")
//            })
//            .iconSize(12)
//            .setupPadding(top: 4, leading: 6, bottom: 4, trailing: 3)
//            .iconColor(.black),
//
//            .button(image: Image(.ellipsis), action: {
//                print("ellipsis tapped")
//            })
//            .iconSize(12)
//            .setupPadding(top: 4, leading: 3, bottom: 4, trailing: 6)
//            .iconColor(.black),
//
//        ])
//    }
// }
//
// #Preview("Bottom Toolbar on Sheet - Simple") {
//    SimpleToolbarOnSheetPreview()
// }
//
// private struct SimpleToolbarOnSheetPreview: View {
//    @State private var showSheet = true
//
//    var body: some View {
//        VStack {
//            Button("Open Sheet") {
//                showSheet = true
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .sheet(isPresented: $showSheet) {
//            SimpleSheetView()
//                .presentationDetents([.medium])
//                .presentationDragIndicator(.visible)
//        }
//    }
// }
//
// private struct SimpleSheetView: View {
//    var body: some View {
//        Color(.systemBackground)
//            .ignoresSafeArea()
//            .dwBottomToolBar(
//                items: [
//                    .button("pin", size: 16) { print("pin tapped") },
//                    .menu(
//                        image: Image(systemName: "ellipsis"),
//                        items: [
//                            DWBottomToolbarItem.MenuItem(
//                                title: "공유하기",
//                                systemImage: "pencil",
//                                role: nil,
//                                action: {}
//                            ),
//                        ]
//                    ),
//                ]
//            )
//    }
// }
