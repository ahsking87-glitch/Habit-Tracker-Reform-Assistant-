import ManagedSettings
import ManagedSettingsUI
import UIKit

@available(iOS 16.0, *)
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.04, green: 0.11, blue: 0.09, alpha: 0.95),
            icon: UIImage(systemName: "moon.stars.fill")?
                .withTintColor(UIColor(red: 0.81, green: 0.69, blue: 0.38, alpha: 1.0)),
            title: ShieldConfiguration.Label(
                text: "A Sacred Pause (وقفة واعية)",
                color: UIColor(red: 0.95, green: 0.96, blue: 0.96, alpha: 1.0)
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This app is paused during this focus block. What does your heart truly need right now?",
                color: UIColor(red: 0.70, green: 0.76, blue: 0.74, alpha: 1.0)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Refresh with Wudu (2 min)",
                color: .black
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.81, green: 0.69, blue: 0.38, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Mindful 10s Unlock",
                color: UIColor(red: 0.55, green: 0.63, blue: 0.60, alpha: 1.0)
            )
        )
    }
}
