---
name: navigation
description: "Use when working with Expo Router -- layouts, auth guards, typed routes, deep linking, tabs, modals, stack navigation, and passing params."
---

# Navigation -- Expo Router v4

File-based routing. Every file in `app/` is a route. Never string-concatenate paths.

## Layout Groups

```
app/
├── _layout.tsx          ← root layout (providers, fonts, theme)
├── (auth)/              ← guest-only group
│   ├── _layout.tsx      ← redirects logged-in users to (app)
│   ├── login.tsx
│   └── register.tsx
├── (app)/               ← protected group
│   ├── _layout.tsx      ← redirects guests to (auth)/login
│   └── (tabs)/
│       ├── _layout.tsx  ← tab bar
│       ├── index.tsx    ← Home tab
│       └── profile.tsx  ← Profile tab
└── +not-found.tsx
```

## Auth Guard Layouts

`app/(auth)/_layout.tsx` -- guest only:
```tsx
import { Redirect, Stack } from 'expo-router'
import { useSession } from '@/hooks/use-session'

export default function AuthLayout() {
  const { session } = useSession()
  if (session) return <Redirect href="/(app)/(tabs)/" />
  return <Stack screenOptions={{ headerShown: false }} />
}
```

`app/(app)/_layout.tsx` -- protected:
```tsx
import { Redirect, Stack } from 'expo-router'
import { useSession } from '@/hooks/use-session'

export default function AppLayout() {
  const { session } = useSession()
  if (!session) return <Redirect href="/(auth)/login" />
  return <Stack screenOptions={{ headerShown: false }} />
}
```

## Tab Navigator

`app/(app)/(tabs)/_layout.tsx`:
```tsx
import { Tabs } from 'expo-router'
import { HomeIcon, UserIcon } from 'lucide-react-native'

export default function TabLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#6366f1', headerShown: false }}>
      <Tabs.Screen
        name="index"
        options={{ title: 'Home', tabBarIcon: ({ color }) => <HomeIcon color={color} size={24} /> }}
      />
      <Tabs.Screen
        name="profile"
        options={{ title: 'Profile', tabBarIcon: ({ color }) => <UserIcon color={color} size={24} /> }}
      />
    </Tabs>
  )
}
```

## Stack with Header

```tsx
<Stack>
  <Stack.Screen name="index" options={{ title: 'Home' }} />
  <Stack.Screen name="[id]" options={{ title: 'Detail', headerBackTitle: 'Back' }} />
</Stack>
```

## Typed Routes

Enable in `app.json`:
```json
{ "expo": { "experiments": { "typedRoutes": true } } }
```

```tsx
import { router, Link } from 'expo-router'

// ✅ Typed -- compile-time checked
router.push({ pathname: '/(app)/(tabs)/', params: { tab: 'home' } })
router.push({ pathname: '/(app)/[id]', params: { id: item.id } })

<Link href={{ pathname: '/(app)/[id]', params: { id: item.id } }}>
  Open
</Link>

// ❌ Never string concatenation
router.push(`/items/${item.id}`)
```

## Reading Params

```tsx
import { useLocalSearchParams, useGlobalSearchParams } from 'expo-router'

// Local -- only params from current route segment
const { id } = useLocalSearchParams<{ id: string }>()

// Global -- params from any segment in the URL
const { tab } = useGlobalSearchParams<{ tab: string }>()
```

## Modal

```tsx
// app/(app)/modal.tsx
import { router } from 'expo-router'
import { View, Text } from 'react-native'
import { Pressable } from 'react-native'

export default function Modal() {
  return (
    <View className="flex-1 items-center justify-center">
      <Text className="text-lg font-semibold">Modal</Text>
      <Pressable onPress={() => router.back()}>
        <Text>Close</Text>
      </Pressable>
    </View>
  )
}

// In _layout.tsx
<Stack.Screen name="modal" options={{ presentation: 'modal' }} />
```

## Deep Linking

`app.json`:
```json
{
  "expo": {
    "scheme": "myapp",
    "ios": { "associatedDomains": ["applinks:myapp.com"] },
    "android": { "intentFilters": [{ "action": "VIEW", "data": [{ "scheme": "myapp" }], "category": ["BROWSABLE", "DEFAULT"] }] }
  }
}
```

Expo Router handles deep links automatically based on file structure -- no extra config needed.

## Imperative Navigation

```tsx
import { router } from 'expo-router'

router.push({ pathname: '/(app)/[id]', params: { id } })
router.replace({ pathname: '/(auth)/login' })
router.back()
router.canGoBack()  // check before calling back()
```

## Not Found

`app/+not-found.tsx`:
```tsx
import { Link, Stack } from 'expo-router'
import { View, Text } from 'react-native'

export default function NotFound() {
  return (
    <>
      <Stack.Screen options={{ title: 'Not Found' }} />
      <View className="flex-1 items-center justify-center gap-4">
        <Text className="text-xl font-bold">Page not found</Text>
        <Link href="/(app)/(tabs)/" className="text-primary">Go home</Link>
      </View>
    </>
  )
}
```
