---
name: performance
description: "Use when optimizing app performance -- TTI targets, FlashList, FPS measurement, Hermes, React Compiler, bundle analysis, memo patterns, avoiding re-renders."
---

# Performance

## TTI Targets (Time to Interactive)

| TTI | Rating |
|---|---|
| <2s | Excellent |
| 2--4s | Acceptable |
| >4s | Poor -- must fix |

JS Bundle load target: <500ms. Native init target: <500ms.

## FPS Targets

| FPS | State |
|---|---|
| 55--60 | Smooth -- target |
| 45--55 | Slight stutter -- investigate |
| 30--45 | Noticeable -- fix before release |
| <30 | Critical |

**UI FPS drop** = native rendering issue (layout properties animated, heavy views)\
**JS FPS drop** = JS thread blocked (heavy computation, too many re-renders)

## Lists -- FlashList over ScrollView

```tsx
// ❌ ScrollView -- renders ALL items upfront, freezes on long lists
<ScrollView>
  {posts.map(p => <PostCard key={p.id} {...p} />)}
</ScrollView>

// ✅ FlashList -- virtualizes, renders only visible items
import { FlashList } from '@shopify/flash-list'

<FlashList
  data={posts}
  renderItem={({ item }) => <PostCard id={item.id} title={item.title} />}
  estimatedItemSize={88}
  keyExtractor={item => item.id}
  onEndReached={fetchNextPage}
  onEndReachedThreshold={0.5}
  ListEmptyComponent={<EmptyState />}
  ListFooterComponent={isFetchingNextPage ? <ActivityIndicator /> : null}
/>
```

## List Memoization Rules

```tsx
// ❌ Object prop -- breaks memo, re-renders every time
<FlashList renderItem={({ item }) => <PostCard data={item} onPress={handlePress} />} />

// ✅ Primitive props -- shallow comparison works
<FlashList renderItem={({ item }) => (
  <PostCard id={item.id} title={item.title} onPress={handlePress} />
)} />

// ✅ Memoized item
const PostCard = memo(({ id, title, onPress }: PostCardProps) => ...)

// ✅ Hoisted callback -- stable reference
const handlePress = useCallback((id: string) => router.push({ pathname: '/(app)/[id]', params: { id } }), [])

// ✅ Memoized data
const filteredPosts = useMemo(() => posts.filter(p => p.active), [posts])
```

## Heterogeneous Lists

```tsx
type FeedItem = { type: 'post' | 'ad' | 'story' } & (PostItem | AdItem | StoryItem)

<FlashList
  data={feed}
  getItemType={item => item.type}
  estimatedItemSize={88}
  renderItem={({ item }) => {
    if (item.type === 'post') return <PostCard {...item} />
    if (item.type === 'ad') return <AdCard {...item} />
    return <StoryCard {...item} />
  }}
/>
```

## Avoid Re-renders

```tsx
// ❌ Inline object -- new reference every render
<Component style={{ color: 'red' }} options={{ timeout: 1000 }} />

// ✅ Outside component or useMemo
const STYLE = { color: 'red' as const }
const OPTIONS = { timeout: 1000 }

// ❌ Inline function -- new reference every render
<FlatList renderItem={({ item }) => <Item {...item} onPress={() => handlePress(item.id)} />} />

// ✅ useCallback
const renderItem = useCallback(({ item }) => <Item {...item} onPress={handlePress} />, [handlePress])
```

## React Compiler (RN 0.76+, Expo SDK 52+)

Automatically removes `memo`, `useCallback`, `useMemo` where safe.

```bash
# Check if your code is compiler-ready
bunx react-compiler-healthcheck@latest
```

Write compiler-friendly code:
```tsx
// ✅ Destructure functions at render top
function Screen({ onPress, onChange }: Props) {
  // Compiler can optimize these
  const handlePress = () => onPress()
  const handleChange = (v: string) => onChange(v)
}

// ❌ Dot-access in JSX
<Pressable onPress={() => props.onPress()} />
```

## Hermes

Enabled by default in Expo SDK 52+. Hermes benefits:
- Faster startup (bytecode pre-compilation)
- Lower memory usage
- Better GC

Ensure Hermes is enabled in `app.json`:
```json
{ "expo": { "jsEngine": "hermes" } }
```

## Animate GPU Properties Only

```tsx
// ❌ Causes layout recalculation
width.value = withSpring(200)
marginTop.value = withTiming(20)

// ✅ GPU only
transform: [{ scale: scaleValue }]
opacity: opacityValue
```

## Intl at Module Scope

```ts
// ❌ Created in render -- expensive
function formatDate(date: Date) {
  return new Intl.DateTimeFormat('en-US', { month: 'short' }).format(date)
}

// ✅ Created once at module level
const dateFormatter = new Intl.DateTimeFormat('en-US', { month: 'short' })
function formatDate(date: Date) { return dateFormatter.format(date) }
```

## Bundle Analysis

```bash
# Expo Atlas (most accurate for Expo)
EXPO_UNSTABLE_ATLAS=true bunx expo export
# Open .expo/atlas.jsonl in Atlas viewer

# Source map explorer
bunx source-map-explorer dist/index.js
```

Common bundle issues:
- Barrel exports (`import { x } from 'big-library'` loads everything)
- Moment.js (use `dayjs` instead)
- Duplicate packages (check `bun why <package>`)
