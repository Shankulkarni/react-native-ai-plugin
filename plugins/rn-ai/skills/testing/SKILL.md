---
name: testing
description: "Use when writing tests for a React Native app -- Jest + jest-expo preset, React Native Testing Library, Reanimated mocks, React Query test setup, what to test and what not to."
---

# Testing -- Jest + React Native Testing Library

## Setup

`jest.config.js`:
```js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterFramework: ['@testing-library/react-native/extend-expect'],
  setupFiles: ['react-native-reanimated/mock', './src/test/setup.ts'],
  modulePathIgnorePatterns: ['<rootDir>/node_modules/'],
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?|expo(nent)?|@expo(nent)?/.*|nativewind|react-native-reanimated|react-native-gesture-handler|react-native-mmkv))',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
}
```

`src/test/setup.ts`:
```ts
import { queryClient } from '@/libs/query-client'
beforeEach(() => queryClient.clear())
```

`package.json`:
```json
"devDependencies": {
  "jest-expo": "^52.0.0",
  "@testing-library/react-native": "^12.0.0",
  "react-test-renderer": "18.3.1"
}
```

## Test Wrapper (React Query + Navigation)

```tsx
// src/test/test-utils.tsx
import { QueryClientProvider } from '@tanstack/react-query'
import { render } from '@testing-library/react-native'
import { queryClient } from '@/libs/query-client'

function TestWrapper({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  )
}

function renderWithProviders(ui: React.ReactElement) {
  return render(ui, { wrapper: TestWrapper })
}

export { renderWithProviders }
```

## Component Test

```tsx
import { renderWithProviders } from '@/test/test-utils'
import { screen, userEvent } from '@testing-library/react-native'
import { server } from '@/test/msw-server'
import { http, HttpResponse } from 'msw'
import { PostCard } from '@/components/app/PostCard'

describe('PostCard', () => {
  it('renders title and body', () => {
    renderWithProviders(<PostCard id="1" title="Hello" body="World" />)
    expect(screen.getByText('Hello')).toBeOnTheScreen()
    expect(screen.getByText('World')).toBeOnTheScreen()
  })

  it('calls onPress when tapped', async () => {
    const user = userEvent.setup()
    const onPress = jest.fn()
    renderWithProviders(<PostCard id="1" title="Hello" body="World" onPress={onPress} />)
    await user.press(screen.getByText('Hello'))
    expect(onPress).toHaveBeenCalledTimes(1)
  })
})
```

## Hook Test

```tsx
import { renderHook, waitFor } from '@testing-library/react-native'
import { QueryClientProvider } from '@tanstack/react-query'
import { queryClient } from '@/libs/query-client'
import { usePosts } from '@/api/posts/hooks'

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
)

describe('usePosts', () => {
  it('returns posts on success', async () => {
    const { result } = renderHook(() => usePosts(), { wrapper })
    await waitFor(() => expect(result.current.isSuccess).toBe(true))
    expect(result.current.data).toHaveLength(2)
  })
})
```

## MSW for API Mocking

```bash
bun add -D msw
```

`src/test/msw-server.ts`:
```ts
import { setupServer } from 'msw/node'
import { postHandlers } from './handlers/posts'
export const server = setupServer(...postHandlers)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

`src/test/handlers/posts.ts`:
```ts
import { http, HttpResponse } from 'msw'
export const postHandlers = [
  http.get(`${process.env.EXPO_PUBLIC_API_URL}/posts`, () =>
    HttpResponse.json([{ id: '1', title: 'Hello', body: 'World' }])
  ),
]
```

## Reanimated Mock

Already set in `setupFiles: ['react-native-reanimated/mock']`.

For gesture handler:
```ts
jest.mock('react-native-gesture-handler', () => ({
  GestureDetector: ({ children }: { children: React.ReactNode }) => children,
  Gesture: { Tap: () => ({ onBegin: jest.fn().mockReturnThis(), onFinalize: jest.fn().mockReturnThis() }) },
}))
```

## What to Test

- Component renders without error for all variants
- User interactions fire correct callbacks
- Hook state transitions (loading → success → error)
- Form validation error messages
- Auth guard redirects (mock session)
- List renders correct number of items
- Edge cases: empty state, error state, loading state

## What NOT to Test

- NativeWind className values (implementation detail)
- Animation interpolation (Reanimated mocks skip)
- Navigation internals (Expo Router handles)
- StyleSheet pixel values
- Auto-generated code

## Query Priority

1. `getByRole` -- best, accessible
2. `getByLabelText`
3. `getByText`
4. `getByTestId` -- last resort

Always `userEvent` not `fireEvent`.
