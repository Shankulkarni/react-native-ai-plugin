---
name: animations
description: "Use when implementing animations or gestures -- GPU-only properties, Reanimated v3 worklets, useDerivedValue, GestureDetector press states, layout animations, React Compiler compatibility."
---

# Animations + Gestures

Reanimated v3 + Gesture Handler v2. New Architecture only. No RN core `Animated` API.

## CRITICAL -- Only GPU-Accelerated Properties

```tsx
// ❌ Causes layout recalculation every frame
width, height, top, left, margin, padding

// ✅ GPU-accelerated -- animate freely
transform: [{ translateX }, { translateY }, { scale }, { rotate }]
opacity
```

## Core Imports

```tsx
import Animated, {
  useSharedValue, useAnimatedStyle, useDerivedValue,
  useAnimatedReaction, withSpring, withTiming, withSequence,
  withDelay, withRepeat, runOnJS, interpolate,
  interpolateColor, Extrapolation, cancelAnimation,
  FadeIn, FadeOut, SlideInRight, ZoomIn,
} from 'react-native-reanimated'
import { Gesture, GestureDetector } from 'react-native-gesture-handler'

// Always Animated.View from reanimated -- never from react-native
```

## Animated Press State

```tsx
function AnimatedCard({ onPress, children }: { onPress?: () => void; children: ReactNode }) {
  const scale = useSharedValue(1)
  const opacity = useSharedValue(1)

  const tap = Gesture.Tap()
    .onBegin(() => {
      scale.value = withSpring(0.96, { damping: 15, stiffness: 300 })
      opacity.value = withTiming(0.85, { duration: 80 })
    })
    .onFinalize((_, success) => {
      scale.value = withSpring(1, { damping: 15, stiffness: 300 })
      opacity.value = withTiming(1, { duration: 120 })
      if (success && onPress) runOnJS(onPress)()
    })

  const style = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }))

  return (
    <GestureDetector gesture={tap}>
      <Animated.View style={style}>{children}</Animated.View>
    </GestureDetector>
  )
}
```

## useDerivedValue vs useAnimatedReaction

```tsx
// ✅ useDerivedValue -- compute a new value (runs on UI thread)
const rotation = useDerivedValue(() => `${progress.value * 360}deg`)
const clamped = useDerivedValue(() =>
  interpolate(raw.value, [0, 1], [0.8, 1.2], Extrapolation.CLAMP)
)

// ✅ useAnimatedReaction -- side effects only (call JS, haptics)
useAnimatedReaction(
  () => progress.value,
  (current, prev) => {
    if (current >= 1 && prev !== null && prev < 1) runOnJS(onComplete)()
  },
)
```

## Layout Animations

```tsx
// Entering/exiting animations on mount/unmount
<Animated.View entering={FadeIn.duration(300)} exiting={FadeOut.duration(200)}>
  <Text>Fades in</Text>
</Animated.View>

<Animated.View entering={SlideInRight.springify().damping(15)}>
  <Card />
</Animated.View>

// List item animations
<FlashList
  renderItem={({ item, index }) => (
    <Animated.View entering={FadeIn.delay(index * 50)}>
      <PostCard {...item} />
    </Animated.View>
  )}
/>
```

## Pan Gesture (Swipe to Dismiss)

```tsx
function SwipeToDismiss({ onDismiss, children }: { onDismiss: () => void; children: ReactNode }) {
  const x = useSharedValue(0)
  const THRESHOLD = 100

  const pan = Gesture.Pan()
    .onUpdate((e) => { x.value = e.translationX })
    .onEnd((e) => {
      if (Math.abs(e.translationX) > THRESHOLD) runOnJS(onDismiss)()
      else x.value = withSpring(0)
    })

  const style = useAnimatedStyle(() => ({
    transform: [{ translateX: x.value }],
    opacity: interpolate(Math.abs(x.value), [0, THRESHOLD], [1, 0.5], Extrapolation.CLAMP),
  }))

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={style}>{children}</Animated.View>
    </GestureDetector>
  )
}
```

## Spring Presets

```ts
const SPRING = {
  snappy: { damping: 20, stiffness: 400 },
  bouncy: { damping: 10, stiffness: 200, mass: 0.8 },
  gentle: { damping: 30, stiffness: 150 },
}

// Usage
scale.value = withSpring(1, SPRING.snappy)
```

## Worklet Rules

- No `console.log` in worklets -- crashes New Architecture UI thread
- No closures over JS objects -- pass primitives only
- No async/await -- worklets are synchronous
- No React hooks -- worklets run on UI thread

```ts
// ✅ Worklet-safe utility
function clamp(value: number, min: number, max: number): number {
  'worklet'
  return Math.min(Math.max(value, min), max)
}
```
