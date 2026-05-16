---
name: auth
description: "Use when implementing auth -- SecureStore for tokens, session management with React Query, Expo Router auth guards, refresh token pattern, sign in/out flow."
---

# Auth

Tokens in SecureStore. Session in React Query. Guards in Expo Router layouts.

## Token Storage (`src/libs/token.ts`)

```ts
import * as SecureStore from 'expo-secure-store'

const ACCESS_KEY = 'access_token'
const REFRESH_KEY = 'refresh_token'

export const tokenStorage = {
  getAccess: () => SecureStore.getItemAsync(ACCESS_KEY),
  setAccess: (token: string) => SecureStore.setItemAsync(ACCESS_KEY, token),
  getRefresh: () => SecureStore.getItemAsync(REFRESH_KEY),
  setRefresh: (token: string) => SecureStore.setItemAsync(REFRESH_KEY, token),
  clear: () => Promise.all([
    SecureStore.deleteItemAsync(ACCESS_KEY),
    SecureStore.deleteItemAsync(REFRESH_KEY),
  ]),
}
```

## Session Hook (`src/hooks/use-session.ts`)

```ts
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { tokenStorage } from '@/libs/token'
import { api } from '@/libs/axios'

const SESSION_KEY = ['session']

export function useSession() {
  const queryClient = useQueryClient()

  const { data: session, isPending } = useQuery({
    queryKey: SESSION_KEY,
    queryFn: async () => {
      const token = await tokenStorage.getAccess()
      if (!token) return null
      const { data } = await api.get('/auth/me')
      return data
    },
    staleTime: 5 * 60 * 1000,  // revalidate session every 5 min
  })

  const signIn = async (tokens: { access: string; refresh: string }) => {
    await Promise.all([
      tokenStorage.setAccess(tokens.access),
      tokenStorage.setRefresh(tokens.refresh),
    ])
    await queryClient.invalidateQueries({ queryKey: SESSION_KEY })
  }

  const signOut = async () => {
    await tokenStorage.clear()
    queryClient.setQueryData(SESSION_KEY, null)
    queryClient.clear()
  }

  return { session, isPending, signIn, signOut }
}
```

## Expo Router Auth Guards

`app/(auth)/_layout.tsx` -- guest only, redirects logged-in users:
```tsx
import { Redirect, Stack } from 'expo-router'
import { useSession } from '@/hooks/use-session'
import { ActivityIndicator, View } from 'react-native'

export default function AuthLayout() {
  const { session, isPending } = useSession()

  if (isPending) {
    return (
      <View className="flex-1 items-center justify-center">
        <ActivityIndicator />
      </View>
    )
  }

  if (session) return <Redirect href="/(app)/(tabs)/" />
  return <Stack screenOptions={{ headerShown: false }} />
}
```

`app/(app)/_layout.tsx` -- protected, redirects guests:
```tsx
import { Redirect, Stack } from 'expo-router'
import { useSession } from '@/hooks/use-session'

export default function AppLayout() {
  const { session, isPending } = useSession()
  if (isPending) return null  // splash screen shows during check
  if (!session) return <Redirect href="/(auth)/login" />
  return <Stack screenOptions={{ headerShown: false }} />
}
```

## axios Token Interceptor

```ts
// src/libs/axios.ts
api.interceptors.request.use(async (config) => {
  const token = await tokenStorage.getAccess()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Refresh token on 401
api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const original = error.config
    if (error.response?.status === 401 && !original._retry) {
      original._retry = true
      try {
        const refresh = await tokenStorage.getRefresh()
        const { data } = await axios.post(`${process.env.EXPO_PUBLIC_API_URL}/auth/refresh`, { refresh })
        await tokenStorage.setAccess(data.access)
        original.headers.Authorization = `Bearer ${data.access}`
        return api(original)
      } catch {
        await tokenStorage.clear()
        // Redirect to login -- handled by router guard
      }
    }
    return Promise.reject(error)
  },
)
```

## Login Screen

```tsx
function LoginScreen() {
  const { signIn } = useSession()
  const { mutate: login, isPending } = useMutation({
    mutationFn: (values: LoginFormValues) => api.post('/auth/login', values).then(r => r.data),
    onSuccess: async (data) => {
      await signIn({ access: data.accessToken, refresh: data.refreshToken })
      // Router guard handles redirect automatically
    },
  })

  // ...form using react-hook-form (see forms skill)
}
```

## Sign Out

```tsx
function ProfileScreen() {
  const { signOut } = useSession()

  return (
    <Pressable onPress={signOut} accessibilityRole="button">
      <Text className="text-red-500">Sign out</Text>
    </Pressable>
  )
}
```

## Rules

- Tokens in `SecureStore` only -- never MMKV, never zustand, never AsyncStorage
- Session state (user object) in React Query -- not zustand
- Route guards via layout redirects -- never per-screen `useEffect` auth checks
- Always show loading state during initial session check -- never flash wrong screen
- `queryClient.clear()` on sign out -- removes all cached data
- Refresh token logic in axios interceptor -- not in components
