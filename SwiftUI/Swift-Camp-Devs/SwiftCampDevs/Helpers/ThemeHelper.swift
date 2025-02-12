import UIKit
import SwiftUI

enum ThemeType: String {
    case dark
    case light
    case custom
}

struct CustomTheme: Codable {
    let primaryColor: String
    let secondaryColor: String
    let backgroundColor: String
    let surfaceColor: String
    let textColor: String
    let subtitleColor: String
    let accentColor: String
    let errorColor: String
    let successColor: String
    let warningColor: String
    let cardBackground: String
    let navigationBarColor: String
    let tabBarColor: String
    let buttonBackground: String
    let buttonText: String
    let inputBackground: String
    let placeholderText: String
    let dividerColor: String
    let shadowColor: String
}
import SwiftUI

class ThemeHelper {
    static let shared = ThemeHelper()
    
    @Published private(set) var themeType: ThemeType = .light {
        didSet {
            UserDefaults.standard.set(themeType.rawValue, forKey: "selectedTheme")
        }
    }
    
    @Published var customTheme: CustomTheme?
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = ThemeType(rawValue: savedTheme) {
            self.themeType = theme
        } else {
            self.themeType = .light
        }
    }
    
    func applyTheme(_ theme: ThemeType) {
        themeType = theme
        switch theme {
        case .dark:
            applyDarkTheme()
        case .light:
            applyLightTheme()
        case .custom:
            loadCustomTheme()
            applyCustomTheme()
        }
    }
    
    private func applyDarkTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
    }
    
    private func applyLightTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
    }
    
    private func loadCustomTheme() {
        if let url = Bundle.main.url(forResource: "CustomTheme", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                customTheme = try JSONDecoder().decode(CustomTheme.self, from: data)
            } catch {
                LoggerHelper.shared.error("Failed to load custom theme from JSON: \(error)")
            }
        } else {
            LoggerHelper.shared.error("CustomTheme.json not found in bundle")
        }
    }
    
    private func applyCustomTheme() {
        guard let theme = customTheme else {
            LoggerHelper.shared.error("Custom theme not loaded")
            return
        }
        
        // Convert hex strings to UIColors
        let backgroundColor = UIColor(hex: theme.backgroundColor)
        let textColor = UIColor(hex: theme.textColor)
        let primaryColor = UIColor(hex: theme.primaryColor)
        let secondaryColor = UIColor(hex: theme.secondaryColor)
        let subtitleColor = UIColor(hex: theme.subtitleColor)
        let accentColor = UIColor(hex: theme.accentColor)
        let errorColor = UIColor(hex: theme.errorColor)
        let successColor = UIColor(hex: theme.successColor)
        let warningColor = UIColor(hex: theme.warningColor)
        let cardBackground = UIColor(hex: theme.cardBackground)
        let navigationBarColor = UIColor(hex: theme.navigationBarColor)
        let tabBarColor = UIColor(hex: theme.tabBarColor)
        let buttonBackground = UIColor(hex: theme.buttonBackground)
        let buttonText = UIColor(hex: theme.buttonText)
        let inputBackground = UIColor(hex: theme.inputBackground)
        let placeholderText = UIColor(hex: theme.placeholderText)
        let dividerColor = UIColor(hex: theme.dividerColor)
        let shadowColor = UIColor(hex: theme.shadowColor)
        
        // Force appearance update
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            LoggerHelper.shared.error("No window scene found")
            return
        }
        
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = .unspecified // Allow custom colors to apply
            window.backgroundColor = backgroundColor
            
            // Update all appearances at once
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = navigationBarColor
            navBarAppearance.titleTextAttributes = [
                .foregroundColor: textColor
            ]
            navBarAppearance.largeTitleTextAttributes = [
                .foregroundColor: textColor
            ]
            
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().tintColor = accentColor
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = tabBarColor
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().tintColor = accentColor
            
            // Update control appearances
            UIButton.appearance().backgroundColor = buttonBackground
            UIButton.appearance().tintColor = buttonText
            
            UITextField.appearance().backgroundColor = inputBackground
            UITextField.appearance().textColor = textColor
            UITextField.appearance().tintColor = accentColor
            
            // Global appearances
            UIView.appearance().tintColor = accentColor
            UILabel.appearance().textColor = textColor
            UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = textColor
            UILabel.appearance().backgroundColor = .clear
            
            // Status appearances
            UIActivityIndicatorView.appearance().color = accentColor
            UIProgressView.appearance().progressTintColor = accentColor
            UISlider.appearance().thumbTintColor = accentColor
            UISwitch.appearance().onTintColor = accentColor
            UISwitch.appearance().thumbTintColor = buttonBackground
            
            // Divider and shadow colors
            UIView.appearance().layer.borderColor = dividerColor.cgColor
            UIView.appearance().layer.shadowColor = shadowColor.cgColor
        }
    }
    
    func color(for key: String) -> Color {
        switch themeType {
        case .dark:
            return Color(key)
        case .light:
            return Color(key)
        case .custom:
                if let customTheme = customTheme {
                    switch key {
                    case "primaryColor":
                        return Color(UIColor(hex: customTheme.primaryColor))
                    case "secondaryColor":
                        return Color(UIColor(hex: customTheme.secondaryColor))
                    case "backgroundColor":
                        return Color(UIColor(hex: customTheme.backgroundColor))
                    case "surfaceColor":
                        return Color(UIColor(hex: customTheme.surfaceColor))
                    case "textColor":
                        return Color(UIColor(hex: customTheme.textColor))
                    case "subtitleColor":
                        return Color(UIColor(hex: customTheme.subtitleColor))
                    case "accentColor":
                        return Color(UIColor(hex: customTheme.accentColor))
                    case "errorColor":
                        return Color(UIColor(hex: customTheme.errorColor))
                    case "successColor":
                        return Color(UIColor(hex: customTheme.successColor))
                    case "warningColor":
                        return Color(UIColor(hex: customTheme.warningColor))
                    case "cardBackground":
                        return Color(UIColor(hex: customTheme.cardBackground))
                    case "navigationBarColor":
                        return Color(UIColor(hex: customTheme.navigationBarColor))
                    case "tabBarColor":
                        return Color(UIColor(hex: customTheme.tabBarColor))
                    case "buttonBackground":
                        return Color(UIColor(hex: customTheme.buttonBackground))
                    case "buttonText":
                        return Color(UIColor(hex: customTheme.buttonText))
                    case "inputBackground":
                        return Color(UIColor(hex: customTheme.inputBackground))
                    case "placeholderText":
                        return Color(UIColor(hex: customTheme.placeholderText))
                    case "dividerColor":
                        return Color(UIColor(hex: customTheme.dividerColor))
                    case "shadowColor":
                        return Color(UIColor(hex: customTheme.shadowColor))
                    default:
                        return Color(UIColor(hex: "#000000"))
                    }
                } else {
                    return Color(UIColor(hex: "#000000"))
                }
        }
    }
}

// UIColor extension for hex string conversion
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
