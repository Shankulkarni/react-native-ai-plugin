---
name: forms
description: "Use when building forms -- react-hook-form + zod v4, RN-specific inputs, init(schema) for defaultValues, useWatch, keyboard handling, server validation errors."
---

# Forms -- react-hook-form + zod v4

## Setup

```ts
// src/libs/form.ts -- resolver wrapper for zod v4
import { zodResolver } from '@hookform/resolvers/zod'
import type { ZodType } from 'zod'
export function createResolver<T extends ZodType>(schema: T) {
  return zodResolver(schema)
}
```

## Form Template

```tsx
import { useForm } from 'react-hook-form'
import { useWatch } from 'react-hook-form'
import { init } from 'zod-empty'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'

const loginSchema = z.object({
  email: z.email({ error: 'Enter a valid email' }),
  password: z.string().min(8, { error: 'At least 8 characters' }),
})

type LoginFormValues = z.infer<typeof loginSchema>

function LoginForm() {
  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: init(loginSchema),   // ← always init(schema), never {}
  })

  const onSubmit = form.handleSubmit(async (values) => {
    await loginMutation.mutateAsync(values)
  })

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} className="flex-1">
      <ScrollView contentContainerClassName="p-4 gap-4" keyboardShouldPersistTaps="handled">
        <Controller
          control={form.control}
          name="email"
          render={({ field, fieldState }) => (
            <View className="gap-1">
              <TextInput
                className={cn('border rounded-xl px-4 py-3 text-base', fieldState.error ? 'border-red-500' : 'border-gray-300')}
                value={field.value}
                onChangeText={field.onChange}
                onBlur={field.onBlur}
                placeholder="Email"
                keyboardType="email-address"
                autoCapitalize="none"
                autoComplete="email"
                returnKeyType="next"
              />
              {fieldState.error && <Text className="text-red-500 text-sm">{fieldState.error.message}</Text>}
            </View>
          )}
        />

        <Button
          label={form.formState.isSubmitting ? 'Signing in...' : 'Sign in'}
          onPress={onSubmit}
          isLoading={form.formState.isSubmitting}
        />
      </ScrollView>
    </KeyboardAvoidingView>
  )
}
```

## Edit Mode

```tsx
// ✅ Edit mode: init(schema) for defaultValues + values for the data
const form = useForm<EditProfileValues>({
  resolver: zodResolver(editProfileSchema),
  defaultValues: init(editProfileSchema),  // ← shape, never actual data
  values: existingProfile,                 // ← actual data goes here
})

// ❌ Never put actual data in defaultValues
const form = useForm({ defaultValues: { name: user.name } })  // breaks reset()
```

## useWatch -- not form.watch()

```tsx
// ❌ form.watch() -- causes full component re-render
const email = form.watch('email')

// ✅ useWatch -- targeted subscription
import { useWatch } from 'react-hook-form'
const email = useWatch({ control: form.control, name: 'email' })

// ✅ In child component outside FormProvider -- pass control
function EmailPreview({ control }: { control: Control<FormValues> }) {
  const email = useWatch({ control, name: 'email' })
  return <Text>{email}</Text>
}
```

## Keyboard Handling

```tsx
// Ref chain for "next" keyboard button
const emailRef = useRef<TextInput>(null)
const passwordRef = useRef<TextInput>(null)

<TextInput
  ref={emailRef}
  returnKeyType="next"
  onSubmitEditing={() => passwordRef.current?.focus()}
/>
<TextInput
  ref={passwordRef}
  returnKeyType="done"
  onSubmitEditing={form.handleSubmit(onSubmit)}
/>
```

## Server Validation Errors

```tsx
const onSubmit = form.handleSubmit(async (values) => {
  try {
    await loginMutation.mutateAsync(values)
  } catch (error) {
    if (isValidationError(error)) {
      // Map server errors to form fields
      error.fields.forEach(({ field, message }) => {
        form.setError(field as keyof LoginFormValues, { message })
      })
    }
  }
})
```

## zod v4 Schema Patterns

```ts
// ✅ Short error syntax (v4)
z.email({ error: 'Invalid email' })
z.string().min(1, { error: 'Required' })
z.string().min(8, { error: 'At least 8 characters' })

// ✅ Optional vs nullable
z.string().optional()    // string | undefined
z.string().nullable()    // string | null

// ✅ Transform for phone numbers, etc.
z.string().transform(val => val.replace(/\D/g, ''))

// ✅ Refine for cross-field validation
z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine(data => data.password === data.confirmPassword, {
  error: 'Passwords do not match',
  path: ['confirmPassword'],
})
```

## Rules

- `init(schema)` from `zod-empty` for `defaultValues` -- always
- Edit mode: `values: existingData` never `defaultValues: existingData`
- `useWatch()` never `form.watch()`
- `keyboardShouldPersistTaps="handled"` on all form ScrollViews
- `returnKeyType="next"` chain all inputs, last one `returnKeyType="done"`
- `autoCapitalize="none"` on email, username fields
- `autoComplete` attribute on all relevant fields
