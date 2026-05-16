---
name: ui
description: "Use when building UI components or screens -- NativeWind v4 className patterns, CVA variants, dark mode, cn(), safe area, keyboard avoiding, expo-image, Pressable, compound components."
---

# UI -- NativeWind v4 + Components

NativeWind v4 brings Tailwind to React Native via the `className` prop.

## CRITICAL Rendering Rules

```tsx
// ❌ Never && with falsy -- renders "0" or crashes
{count && <Badge />}
{items.length && <List />}

// ✅ Ternary with null
{count > 0 ? <Badge count={count} /> : null}
{Boolean(items.length) && <List />}

// ❌ Strings outside <Text> crash New Architecture
<View>Hello</View>

// ✅
<View><Text>Hello</Text></View>
```

## NativeWind Basics

```tsx
// className works just like Tailwind
<View className="flex-1 bg-white px-4 py-6">
  <Text className="text-xl font-bold text-gray-900">Hello</Text>
  <Text className="text-sm text-gray-500 mt-1">Subtitle</Text>
</View>

// Conditional classes with cn()
import { cn } from '@/libs/cn'
<View className={cn('p-4 rounded-xl', isActive && 'bg-primary', isDisabled && 'opacity-50')} />

// Dark mode
<View className="bg-white dark:bg-gray-900">
  <Text className="text-gray-900 dark:text-white">Auto dark mode</Text>
</View>
```

## Component Template

```tsx
import { Pressable, Text, View } from 'react-native'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/libs/cn'

const buttonVariants = cva(
  'flex-row items-center justify-center rounded-xl gap-2 active:opacity-80',
  {
    variants: {
      variant: {
        primary: 'bg-primary',
        secondary: 'bg-gray-100 dark:bg-gray-800',
        ghost: 'bg-transparent',
        destructive: 'bg-red-500',
      },
      size: {
        sm: 'px-3 py-2 min-h-[32px]',
        md: 'px-4 py-3 min-h-[44px]',
        lg: 'px-6 py-4 min-h-[52px]',
      },
    },
    defaultVariants: { variant: 'primary', size: 'md' },
  },
)

const buttonTextVariants = cva('font-semibold', {
  variants: {
    variant: {
      primary: 'text-white',
      secondary: 'text-gray-900 dark:text-white',
      ghost: 'text-primary',
      destructive: 'text-white',
    },
    size: { sm: 'text-sm', md: 'text-base', lg: 'text-lg' },
  },
  defaultVariants: { variant: 'primary', size: 'md' },
})

type ButtonProps = React.ComponentProps<typeof Pressable> &
  VariantProps<typeof buttonVariants> & {
    label: string
    isLoading?: boolean
  }

function Button({ label, variant, size, isLoading, className, disabled, ...props }: ButtonProps) {
  return (
    <Pressable
      className={cn(buttonVariants({ variant, size }), className)}
      disabled={disabled || isLoading}
      accessibilityRole="button"
      accessibilityState={{ disabled: disabled || isLoading }}
      {...props}
    >
      {isLoading ? (
        <ActivityIndicator color={variant === 'primary' ? 'white' : '#6366f1'} size="small" />
      ) : (
        <Text className={cn(buttonTextVariants({ variant, size }))}>{label}</Text>
      )}
    </Pressable>
  )
}

export { Button }
export type { ButtonProps }
```

## Safe Area

```tsx
import { SafeAreaView } from 'react-native-safe-area-context'

// Full screen with safe area
<SafeAreaView className="flex-1 bg-white dark:bg-gray-900">
  <ScrollView>...</ScrollView>
</SafeAreaView>

// Just bottom safe area (tabs)
<View className="flex-1">
  <ScrollView contentContainerClassName="pb-safe">...</ScrollView>
</View>

// iOS ScrollView -- automatic safe area inset
<ScrollView contentInsetAdjustmentBehavior="automatic">...</ScrollView>
```

## Keyboard Avoiding

```tsx
import { KeyboardAvoidingView, Platform, ScrollView } from 'react-native'

<KeyboardAvoidingView
  className="flex-1"
  behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
>
  <ScrollView
    className="flex-1"
    keyboardShouldPersistTaps="handled"
    contentContainerClassName="p-4 gap-4"
  >
    {/* form inputs */}
  </ScrollView>
</KeyboardAvoidingView>
```

## expo-image

```tsx
import { Image } from 'expo-image'

<Image
  source={{ uri: avatarUrl }}
  placeholder={{ blurhash: 'LGFFaXYk^6#M@-5c,1J5@[or[Q6.' }}
  contentFit="cover"
  priority="high"
  className="w-12 h-12 rounded-full"
/>
```

## Pressable (not TouchableOpacity)

```tsx
// ✅ Pressable with className
<Pressable
  className="rounded-xl bg-primary px-4 py-3 active:opacity-70"
  onPress={handlePress}
  accessibilityRole="button"
>
  <Text className="text-white font-semibold">Press me</Text>
</Pressable>

// ✅ Pressable with style function for fine-grained pressed state
<Pressable style={({ pressed }) => [{ opacity: pressed ? 0.7 : 1 }]}>
  {({ pressed }) => <Text>{pressed ? 'Pressed!' : 'Press me'}</Text>}
</Pressable>
```

## Compound Components

```tsx
// Card compound component
function Card({ className, children, ...props }: ViewProps & { className?: string }) {
  return (
    <View className={cn('bg-white dark:bg-gray-900 rounded-2xl p-4 shadow-sm', className)} {...props}>
      {children}
    </View>
  )
}

function CardHeader({ className, children, ...props }: ViewProps & { className?: string }) {
  return <View className={cn('mb-3', className)} {...props}>{children}</View>
}

function CardTitle({ className, children, ...props }: TextProps & { className?: string }) {
  return <Text className={cn('text-lg font-bold text-gray-900 dark:text-white', className)} {...props}>{children}</Text>
}

Card.Header = CardHeader
Card.Title = CardTitle

// Usage
<Card>
  <Card.Header>
    <Card.Title>Hello</Card.Title>
  </Card.Header>
</Card>
```

## Typography Scale

```tsx
// Use consistent text classes -- define in tailwind.config.js theme
<Text className="text-3xl font-bold">Heading 1</Text>
<Text className="text-2xl font-bold">Heading 2</Text>
<Text className="text-xl font-semibold">Heading 3</Text>
<Text className="text-base text-gray-700 dark:text-gray-300">Body</Text>
<Text className="text-sm text-gray-500 dark:text-gray-400">Caption</Text>
```

## Accessibility

- `accessibilityRole` on every interactive element
- `accessibilityLabel` on icon-only buttons
- `accessibilityState={{ disabled, selected }}` when state changes
- Minimum touch target: `min-h-[44px] min-w-[44px]`
- `importantForAccessibility="no"` on decorative elements
