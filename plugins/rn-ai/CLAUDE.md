# RN-Claude -- Global Rules

These rules apply to every React Native app in this ecosystem.

## Skills -- Load Before Coding

| When doing... | Load this skill |
|---|---|
| Scaffolding a new app | `scaffold` |
| Navigation, routing, layouts, deep links | `navigation` |
| UI components, NativeWind, styling | `ui` |
| Data fetching, React Query, axios | `data` |
| Forms, validation | `forms` |
| Client UI state | `state` |
| Animations or gestures | `animations` |
| Auth, tokens, session management | `auth` |
| EAS build, submit, OTA update | `eas` |
| Push notifications | `notifications` |
| Local storage (MMKV, SecureStore) | `storage` |
| Writing tests | `testing` |
| Performance -- TTI, FPS, bundle | `performance` |
| Code quality scan | `deslop` |

## Hard Rules (Non-Negotiable)

### New Architecture -- Enforced Everywhere
- No legacy bridge APIs: `NativeModules`, `requireNativeComponent`, `UIManager` are banned.
- Target RN 0.76+. `newArchEnabled: true` in `app.json` always.

### Package Manager
- `bun` always. `bunx` instead of `npx`. Never npm/yarn for local commands.

### TypeScript
- Strict mode. `type` not `interface`. No `any`/`as`. Named exports only.
- `moduleResolution: bundler`. Inline type imports.
- No `console.log` anywhere in `src/` -- remove before commit.

### Code Style
- Tabs, single quotes, no semicolons, trailing commas. Kebab-case filenames.
- No `React.xxx` namespace -- named imports only.
- No `&&` with falsy values (`0`, `''`, `null`) -- use ternary or `Boolean()`.
- All strings inside `<Text>` -- never bare strings in `<View>`.

### UI / Styling
- NativeWind v4 only. Use `className` prop -- never inline `style` for layout/spacing.
- `StyleSheet` only for platform-specific shadows or values NativeWind can't express.
- `Pressable` -- never `TouchableOpacity` or `TouchableHighlight`.
- `expo-image` -- never RN's `Image` for remote images.
- `cn()` for conditional classNames.
- Dark mode via NativeWind `dark:` variants -- never manual theme switching logic.

### Navigation
- Expo Router typed routes always. Never string concatenation for paths.
- `(auth)/` layout for guest screens, `(app)/` layout for protected screens.
- Never navigate with raw `router.push('/some/path')` -- use typed `router.push({ pathname: '...' })`.
- Deep links configured in `app.json` -- never manual.

### Data Fetching
- React Query for ALL server data. Never fetch in `useEffect`.
- `staleTime: Infinity`, manual invalidation via `queryClient.invalidateQueries`.
- `axios` always -- one instance per API integration in `src/libs/`.
- Query key factories per domain in `src/api/<domain>/keys.ts`.
- API module: `api.ts` (axios calls) + `keys.ts` (factories) + `hooks.ts` (useQuery/useMutation) + `types.ts` (Zod schemas).

### Forms
- react-hook-form + zod v4 always.
- `init(schema)` from `zod-empty` for `defaultValues` -- always, without exception.
- Edit mode: `defaultValues: init(schema)` + `values: existingData`.
- `useWatch()` not `form.watch()`. Pass `control` when outside `FormProvider`.

### State
- zustand-x v6 for UI state only -- never server data, auth, or form state.
- React Query owns server data. Expo Router owns URL state. SecureStore owns auth tokens.
- `useStoreValue(store, 'field')` for reads. `useTracked` for nested objects.

### Storage
- `SecureStore` for tokens, keys, passwords, any sensitive value.
- `MMKV` for everything else (fast, synchronous, non-sensitive).
- Never `AsyncStorage` -- too slow, no encryption.

### Auth
- Tokens stored in `SecureStore` only -- never in MMKV, never in zustand.
- Session state (user object) in React Query cache -- not zustand.
- Route guards via Expo Router layouts -- never per-screen auth checks.

### Animations
- Reanimated v3 only. No RN core `Animated` API.
- Gesture Handler v2 only. `GestureDetector` -- never `PanResponder`.
- Only animate GPU properties (`transform`, `opacity`) -- never layout properties.
- No `console.log` in worklets -- crashes New Architecture.

### EAS / Environment
- No hardcoded API URLs -- use `process.env.EXPO_PUBLIC_API_URL`.
- EAS secrets for all credentials -- never commit tokens or keys.
- `eas.json` must have `development`, `preview`, and `production` profiles.

### Never
- Never skip Husky hooks (`--no-verify`).
- Never commit `.env*` files.
- Never use `AsyncStorage`.
- Never use `PanResponder`.
- Never use `TouchableOpacity` or `TouchableHighlight`.
- Never navigate with string concatenation.
- Never fetch data in `useEffect`.
