import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "ActivityCardImage" asset catalog image resource.
    static let activityCard = DeveloperToolsSupport.ImageResource(name: "ActivityCardImage", bundle: resourceBundle)

    /// The "AthhleticaaLogoDarkMode" asset catalog image resource.
    static let athhleticaaLogoDarkMode = DeveloperToolsSupport.ImageResource(name: "AthhleticaaLogoDarkMode", bundle: resourceBundle)

    /// The "AthhleticaaLogoLightMode" asset catalog image resource.
    static let athhleticaaLogoLightMode = DeveloperToolsSupport.ImageResource(name: "AthhleticaaLogoLightMode", bundle: resourceBundle)

    /// The "BloodOxygenCardImage" asset catalog image resource.
    static let bloodOxygenCard = DeveloperToolsSupport.ImageResource(name: "BloodOxygenCardImage", bundle: resourceBundle)

    /// The "HRVCardImage" asset catalog image resource.
    static let hrvCard = DeveloperToolsSupport.ImageResource(name: "HRVCardImage", bundle: resourceBundle)

    /// The "HeartRateCardImage" asset catalog image resource.
    static let heartRateCard = DeveloperToolsSupport.ImageResource(name: "HeartRateCardImage", bundle: resourceBundle)

    /// The "HeartRateIcon" asset catalog image resource.
    static let heartRateIcon = DeveloperToolsSupport.ImageResource(name: "HeartRateIcon", bundle: resourceBundle)

    /// The "RingImage" asset catalog image resource.
    static let ring = DeveloperToolsSupport.ImageResource(name: "RingImage", bundle: resourceBundle)

    /// The "SleepCardImage" asset catalog image resource.
    static let sleepCard = DeveloperToolsSupport.ImageResource(name: "SleepCardImage", bundle: resourceBundle)

    /// The "SportsCardImage" asset catalog image resource.
    static let sportsCard = DeveloperToolsSupport.ImageResource(name: "SportsCardImage", bundle: resourceBundle)

    /// The "StressCardImage" asset catalog image resource.
    static let stressCard = DeveloperToolsSupport.ImageResource(name: "StressCardImage", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "ActivityCardImage" asset catalog image.
    static var activityCard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .activityCard)
#else
        .init()
#endif
    }

    /// The "AthhleticaaLogoDarkMode" asset catalog image.
    static var athhleticaaLogoDarkMode: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .athhleticaaLogoDarkMode)
#else
        .init()
#endif
    }

    /// The "AthhleticaaLogoLightMode" asset catalog image.
    static var athhleticaaLogoLightMode: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .athhleticaaLogoLightMode)
#else
        .init()
#endif
    }

    /// The "BloodOxygenCardImage" asset catalog image.
    static var bloodOxygenCard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bloodOxygenCard)
#else
        .init()
#endif
    }

    /// The "HRVCardImage" asset catalog image.
    static var hrvCard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .hrvCard)
#else
        .init()
#endif
    }

    /// The "HeartRateCardImage" asset catalog image.
    static var heartRateCard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .heartRateCard)
#else
        .init()
#endif
    }

    /// The "HeartRateIcon" asset catalog image.
    static var heartRateIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .heartRateIcon)
#else
        .init()
#endif
    }

    /// The "RingImage" asset catalog image.
    static var ring: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ring)
#else
        .init()
#endif
    }

    /// The "SleepCardImage" asset catalog image.
    static var sleepCard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sleepCard)
#else
        .init()
#endif
    }

    /// The "SportsCardImage" asset catalog image.
    static var sportsCard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sportsCard)
#else
        .init()
#endif
    }

    /// The "StressCardImage" asset catalog image.
    static var stressCard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .stressCard)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "ActivityCardImage" asset catalog image.
    static var activityCard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .activityCard)
#else
        .init()
#endif
    }

    /// The "AthhleticaaLogoDarkMode" asset catalog image.
    static var athhleticaaLogoDarkMode: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .athhleticaaLogoDarkMode)
#else
        .init()
#endif
    }

    /// The "AthhleticaaLogoLightMode" asset catalog image.
    static var athhleticaaLogoLightMode: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .athhleticaaLogoLightMode)
#else
        .init()
#endif
    }

    /// The "BloodOxygenCardImage" asset catalog image.
    static var bloodOxygenCard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bloodOxygenCard)
#else
        .init()
#endif
    }

    /// The "HRVCardImage" asset catalog image.
    static var hrvCard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .hrvCard)
#else
        .init()
#endif
    }

    /// The "HeartRateCardImage" asset catalog image.
    static var heartRateCard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .heartRateCard)
#else
        .init()
#endif
    }

    /// The "HeartRateIcon" asset catalog image.
    static var heartRateIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .heartRateIcon)
#else
        .init()
#endif
    }

    /// The "RingImage" asset catalog image.
    static var ring: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ring)
#else
        .init()
#endif
    }

    /// The "SleepCardImage" asset catalog image.
    static var sleepCard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sleepCard)
#else
        .init()
#endif
    }

    /// The "SportsCardImage" asset catalog image.
    static var sportsCard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sportsCard)
#else
        .init()
#endif
    }

    /// The "StressCardImage" asset catalog image.
    static var stressCard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .stressCard)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

