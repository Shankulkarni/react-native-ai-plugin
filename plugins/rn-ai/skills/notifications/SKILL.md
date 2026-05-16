---
name: notifications
description: "Use when implementing push notifications -- Expo Notifications setup, permissions, FCM/APNs token registration, foreground/background handlers, notification categories."
---

# Push Notifications -- Expo Notifications

## Install

```bash
bunx expo install expo-notifications expo-device expo-constants
```

`app.json`:
```json
{
  "expo": {
    "plugins": [
      ["expo-notifications", {
        "icon": "./assets/notification-icon.png",
        "color": "#6366f1",
        "sounds": ["./assets/notification.wav"]
      }]
    ],
    "ios": { "bundleIdentifier": "com.myorg.myapp" },
    "android": { "googleServicesFile": "./google-services.json" }
  }
}
```

## Permission + Token Registration

```ts
// src/libs/notifications.ts
import * as Device from 'expo-device'
import * as Notifications from 'expo-notifications'
import Constants from 'expo-constants'
import { Platform } from 'react-native'

export async function registerForPushNotifications(): Promise<string | null> {
  if (!Device.isDevice) {
    console.warn('Push notifications require a physical device')
    return null
  }

  const { status: existing } = await Notifications.getPermissionsAsync()
  let finalStatus = existing

  if (existing !== 'granted') {
    const { status } = await Notifications.requestPermissionsAsync()
    finalStatus = status
  }

  if (finalStatus !== 'granted') return null

  const projectId = Constants.expoConfig?.extra?.eas?.projectId
  const token = await Notifications.getExpoPushTokenAsync({ projectId })

  if (Platform.OS === 'android') {
    await Notifications.setNotificationChannelAsync('default', {
      name: 'default',
      importance: Notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
    })
  }

  return token.data
}
```

## Notification Handler

Set in root `_layout.tsx` before any component renders:

```tsx
import * as Notifications from 'expo-notifications'

// How to display notifications when app is in foreground
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
})

export default function RootLayout() {
  // ...
}
```

## Hooks (`src/hooks/use-notifications.ts`)

```ts
import { useEffect, useRef } from 'react'
import * as Notifications from 'expo-notifications'
import { router } from 'expo-router'
import type { Href } from 'expo-router'
import { registerForPushNotifications } from '@/libs/notifications'

export function useNotifications() {
  const notificationListener = useRef<Notifications.EventSubscription>()
  const responseListener = useRef<Notifications.EventSubscription>()

  useEffect(() => {
    registerForPushNotifications().then(token => {
      if (token) {
        // Send token to your API
      }
    })

    // Fires when notification received in foreground
    notificationListener.current = Notifications.addNotificationReceivedListener(_notification => {
      // handle foreground notification -- e.g. update badge count or show in-app toast
    })

    // Fires when user taps notification
    responseListener.current = Notifications.addNotificationResponseReceivedListener(response => {
      const data = response.notification.request.content.data
      if (data.screen) {
        // notification payload is untyped -- validate screen values server-side before sending
        router.push(data.screen as Href)
      }
    })

    return () => {
      notificationListener.current?.remove()
      responseListener.current?.remove()
    }
  }, [])
}
```

Use in root `_layout.tsx`:
```tsx
export default function RootLayout() {
  useNotifications()
  // ...
}
```

## Handle App Launch from Notification

```tsx
import * as Notifications from 'expo-notifications'
import { useEffect } from 'react'
import { router } from 'expo-router'
import type { Href } from 'expo-router'

export default function RootLayout() {
  useEffect(() => {
    // App opened from a notification
    Notifications.getLastNotificationResponseAsync().then(response => {
      const screen = response?.notification.request.content.data.screen
      if (screen) {
        // cold-start navigation from notification -- payload is untyped, validate screen values server-side
        router.push(screen as Href)
      }
    })
  }, [])
}
```

## Local Notifications

```ts
// Schedule a local notification
await Notifications.scheduleNotificationAsync({
  content: {
    title: 'Reminder',
    body: 'Don\'t forget to check in!',
    data: { screen: '/(app)/(tabs)/' },
  },
  trigger: { seconds: 60 },  // 1 minute from now
})

// Cancel all scheduled
await Notifications.cancelAllScheduledNotificationsAsync()
```

## Rules

- Always request permissions before registering -- never assume granted
- Always clean up listeners in `useEffect` return
- Send push token to API after registration -- store server-side for sending
- Handle `getLastNotificationResponseAsync` for cold-start navigation
- Never show notification UI in JS -- use `setNotificationHandler` to control display
- `google-services.json` must be in EAS secrets for CI -- never committed
