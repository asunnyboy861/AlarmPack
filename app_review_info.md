# App Review Information — AlarmPack

## App Overview

AlarmPack is an alarm grouping app that lets users organize alarms into "Packs" (e.g., Work, School, Gym) and switch between them with one tap. It supports both AlarmKit (iOS 26+) and local notifications (iOS 17-25) for maximum device compatibility.

## In-App Purchase

- **Product ID**: `com.zzoutuo.AlarmPack.pro`
- **Type**: Non-Consumable (one-time purchase)
- **Price**: $2.99
- **Display Name**: AlarmPack Pro
- **Description**: Unlock unlimited packs, unlimited alarms per pack, shift scheduling, skip alarm, custom sounds, and advanced widgets.

### How to Test IAP

1. Launch the app and complete onboarding (select at least one template)
2. Create 2 Packs (free limit reached)
3. Tap "New Pack" button → Paywall appears
4. Tap "Unlock Pro — $2.99" to initiate purchase
5. Alternatively, tap "Restore Purchases" to restore previous purchases

### Free vs Pro Features

| Feature | Free | Pro |
|---------|------|-----|
| Pack count | 2 | Unlimited |
| Alarms per Pack | 3 | Unlimited |
| Rotating shift scheduling | No | Yes |
| Skip next alarm | No | Yes |
| Custom alarm sounds | No | Yes |
| Advanced widgets | No | Yes |

## Core User Flow

1. **Onboarding**: First launch shows template selection (Work, School, Gym, Weekend, Night Shift)
2. **Pack List**: Main screen shows all alarm packs with toggle to activate
3. **Pack Detail**: Tap a pack to view/edit alarms, add new alarms, skip alarms
4. **Settings**: Configure snooze time, haptic feedback, restore purchases

## Permissions Required

- **Notifications**: Required for alarm functionality on iOS 17-25 devices
- **AlarmKit**: Required for alarm functionality on iOS 26+ devices (system-level alarms)

## Policy Pages

- Privacy Policy: https://asunnyboy861.github.io/AlarmPack/privacy.html
- Terms of Use: https://asunnyboy861.github.io/AlarmPack/terms.html
- Support Page: https://asunnyboy861.github.io/AlarmPack/support.html

## Contact

- Developer: asunnyboy861
- Support Email: Available via in-app Contact Support form
