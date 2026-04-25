import SwiftUI

public enum AppSpacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
}

public enum AppRadius {
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
}

public enum AppColor {
    #if os(iOS)
    public static let background = Color(.systemBackground)
    public static let secondaryBackground = Color(.secondarySystemBackground)
    #else
    public static let background = Color(.windowBackgroundColor)
    public static let secondaryBackground = Color(.underPageBackgroundColor)
    #endif
    public static let accent = Color.accentColor
}
