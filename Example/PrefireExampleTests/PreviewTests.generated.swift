// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all
// swiftformat:disable all

import XCTest
import SwiftUI
import Prefire

import SnapshotTesting
#if canImport(AccessibilitySnapshot)
    import AccessibilitySnapshot
#endif
@testable import PrefireExample

class PreviewTests: XCTestCase {
    private let deviceConfig: ViewImageConfig = .iPhoneX
    private let simulatorDevice = "iPhone15,2"
    private let requiredOSVersion = 16

    override func setUp() {
        super.setUp()

        checkEnvironments()
        UIView.setAnimationsEnabled(false)
    }

    func test_authView_Preview() {
        let previews = AuthView_Preview.previews
        for (index, preview) in AuthView_Preview._allPreviews.enumerated() {
            let settings = previews.snapshotSettings(for: index)
            assertSnapshots(matching: preview, precision: settings.precision, delay: settings.delay)
        }
    }

    func test_circleImage() {
        let previews = CircleImage_Previews.previews
        for (index, preview) in CircleImage_Previews._allPreviews.enumerated() {
            let settings = previews.snapshotSettings(for: index)
            assertSnapshots(matching: preview, precision: settings.precision, delay: settings.delay)
        }
    }

    func test_greenButton() {
        let previews = GreenButton_Previews.previews
        for (index, preview) in GreenButton_Previews._allPreviews.enumerated() {
            let settings = previews.snapshotSettings(for: index)
            assertSnapshots(matching: preview, precision: settings.precision, delay: settings.delay)
        }
    }

    func test_prefireView_Preview() {
        let previews = PrefireView_Preview.previews
        for (index, preview) in PrefireView_Preview._allPreviews.enumerated() {
            let settings = previews.snapshotSettings(for: index)
            assertSnapshots(matching: preview, precision: settings.precision, delay: settings.delay)
        }
    }

    func test_testViewWithoutState() {
        let previews = TestViewWithoutState_Previews.previews
        for (index, preview) in TestViewWithoutState_Previews._allPreviews.enumerated() {
            let settings = previews.snapshotSettings(for: index)
            assertSnapshots(matching: preview, precision: settings.precision, delay: settings.delay)
        }
    }

    func test_testView() {
        let previews = TestView_Previews.previews
        for (index, preview) in TestView_Previews._allPreviews.enumerated() {
            let settings = previews.snapshotSettings(for: index)
            assertSnapshots(matching: preview, precision: settings.precision, delay: settings.delay)
        }
    }

    // MARK: Private

    private func assertSnapshots(matching preview: _Preview, precision: Float?, delay: TimeInterval?, testName: String = #function) {
        let isScreen = preview.layout == .device
        let device = preview.device?.snapshotDevice() ?? deviceConfig
        var view = preview.content
        view = isScreen ? view : AnyView(view.frame(width: device.size?.width).fixedSize(horizontal: false, vertical: true))

        assertSnapshot(
            matching: view,
            as: .wait(for: delay, on: .image(precision: precision ?? 1, layout: isScreen ? .device(config: device) : .sizeThatFits)),
            named: preview.displayName,
            testName: testName
        )
        #if canImport(AccessibilitySnapshot)
            let vc = UIHostingController(rootView: view)
            vc.view.frame = UIScreen.main.bounds
            assertSnapshot(
                matching: vc,
                as: .wait(for: delay, on: .accessibilityImage(showActivationPoints: .always)),
                named: preview.displayName.map { $0 + ".accessibility" },
                testName: testName
            )
        #endif
    }

    /// Check environments to avoid problems with snapshots on different devices or OS.
    private func checkEnvironments() {
        let deviceModel = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]
        let osVersion = ProcessInfo().operatingSystemVersion
        guard deviceModel?.contains(simulatorDevice) ?? false else {
            fatalError("Switch to using \(simulatorDevice) for these tests.")
        }

        guard osVersion.majorVersion == requiredOSVersion else {
            fatalError("Switch to iOS \(requiredOSVersion) for these tests.")
        }
    }
}

private extension Mirror {
    func findValue(for name: String) -> Any? {
        var mirror: Mirror? = self

        while mirror != nil {
            guard let value = mirror?.children.first(where: { "\($0.value)".contains(name) })?.value else {
                return mirror?.children.first?.value
            }
            mirror = Mirror(reflecting: value)
        }

        return nil
    }

    var values: [String: Any] {
        children.reduce([String: Any]()) { partialResult, child in
            var partialResult = partialResult
            if let index = child.label {
                partialResult[index] = child.value
            }
            return partialResult
        }
    }
}

private extension Snapshotting {
    static func wait(for duration: TimeInterval?, on strategy: Snapshotting) -> Snapshotting {
        if let duration {
            return wait(for: duration, on: strategy)
        } else {
            return strategy
        }
    }
}

private extension PreviewDevice {
    func snapshotDevice() -> ViewImageConfig? {
        switch rawValue {
        case "iPhone 12", "iPhone 11", "iPhone 10":
            return .iPhoneX
        case "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8":
            return .iPhone8
        case "iPhone 6 Plus", "iPhone 6s Plus", "iPhone 8 Plus":
            return .iPhone8Plus
        case "iPhone SE (1st generation)", "iPhone SE (2nd generation)":
            return .iPhoneSe
        default: return nil
        }
    }
}

private extension View {
    func snapshotSettings(for index: Int) -> (precision: Float?, delay: TimeInterval?) {
        let viewValue = Mirror(reflecting: self).children.first?.value
        let viewArray = viewValue.flatMap { Mirror(reflecting: $0).values }

        let precision = Mirror(reflecting: viewArray?[".\(index)"] as Any)
            .findValue(for: String(describing: PrecisionPreferenceKey.self)) as? Float

        let delay = Mirror(reflecting: viewArray?[".\(index)"] as Any)
            .findValue(for: String(describing: DelayPreferenceKey.self)) as? TimeInterval

        return (precision, delay)
    }
}