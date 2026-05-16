---
name: data
description: "Use when fetching or mutating server data -- React Query setup, axios instance, query key factories, useQuery/useMutation hooks, error handling, pagination, optimistic updates."
---

# Data Fetching -- React Query + axios

Backend-agnostic. React Query owns all server data. Never fetch in `useEffect`.

## QueryClient (`src/libs/query-client.ts`)

```ts
import { MutationCache, QueryCache, QueryClient } from '@tanstack/react-query'
import { toast } from 'sonner-native'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: Infinity,
      gcTime: Infinity,
      retry: false,
      refetchOnMount: false,
      refetchOnWindowFocus: false,
    },
  },
  queryCache: new QueryCache({
    onError: (error) => toast.error(error.message),
  }),
  mutationCache: new MutationCache({
    onError: (error) => toast.error(error.message),
  }),
})
```

## axios Instance (`src/libs/axios.ts`)

```ts
import axios from 'axios'
import * as SecureStore from 'expo-secure-store'

export const api = axios.create({
  baseURL: process.env.EXPO_PUBLIC_API_URL,
  timeout: 30_000,
  headers: { 'Content-Type': 'application/json' },
})

// Attach auth token
api.interceptors.request.use(async (config) => {
  const token = await SecureStore.getItemAsync('access_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Refresh token on 401
api.interceptors.response.use(
  (res) => res,
  async (error) => {
    if (error.response?.status === 401) {
      // refresh logic here
    }
    return Promise.reject(error)
  },
)
```

## API Module Structure

4 files per domain in `src/api/<domain>/`:

```
src/api/posts/
├── types.ts    ← Zod schemas + inferred types
├── api.ts      ← axios calls (pure functions)
├── keys.ts     ← query key factory
└── hooks.ts    ← useQuery/useMutation wrappers
```

### `types.ts`

```ts
import { z } from 'zod'

export const postSchema = z.object({
  id: z.string(),
  title: z.string(),
  body: z.string(),
  createdAt: z.string(),
})

export type Post = z.infer<typeof postSchema>

export const createPostSchema = z.object({
  title: z.string().min(1),
  body: z.string().min(1),
})

export type CreatePostInput = z.infer<typeof createPostSchema>
```

### `api.ts`

```ts
import { api } from '@/libs/axios'
import type { Post, CreatePostInput } from './types'

export async function fetchPosts(): Promise<Post[]> {
  const { data } = await api.get('/posts')
  return data
}

export async function fetchPost(id: string): Promise<Post> {
  const { data } = await api.get(`/posts/${id}`)
  return data
}

export async function createPost(input: CreatePostInput): Promise<Post> {
  const { data } = await api.post('/posts', input)
  return data
}

export async function deletePost(id: string): Promise<void> {
  await api.delete(`/posts/${id}`)
}
```

### `keys.ts`

```ts
export const postKeys = {
  all: ['posts'] as const,
  lists: () => [...postKeys.all, 'list'] as const,
  list: (params?: Record<string, unknown>) => [...postKeys.lists(), params] as const,
  details: () => [...postKeys.all, 'detail'] as const,
  detail: (id: string) => [...postKeys.details(), id] as const,
}
```

### `hooks.ts`

```ts
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { createPost, deletePost, fetchPost, fetchPosts } from './api'
import { postKeys } from './keys'

export function usePosts() {
  return useQuery({ queryKey: postKeys.list(), queryFn: fetchPosts })
}

export function usePost(id: string) {
  return useQuery({ queryKey: postKeys.detail(id), queryFn: () => fetchPost(id) })
}

export function useCreatePost() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: createPost,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: postKeys.lists() }),
  })
}

export function useDeletePost() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: deletePost,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: postKeys.lists() }),
  })
}
```

## Using in Components

```tsx
function PostsScreen() {
  const { data: posts, isPending, isError } = usePosts()
  const { mutate: createPost, isPending: isCreating } = useCreatePost()

  if (isPending) return <ActivityIndicator />
  if (isError) return <Text>Something went wrong</Text>

  return (
    <FlashList
      data={posts}
      renderItem={({ item }) => <PostCard id={item.id} title={item.title} />}
      estimatedItemSize={80}
    />
  )
}
```

## Pagination (Cursor-based)

```ts
// hooks.ts
export function useInfinitePosts() {
  return useInfiniteQuery({
    queryKey: postKeys.list({ infinite: true }),
    queryFn: ({ pageParam }) => fetchPostsPage({ cursor: pageParam }),
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
  })
}
```

## Optimistic Updates

```ts
export function useDeletePost() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: deletePost,
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: postKeys.lists() })
      const previous = queryClient.getQueryData(postKeys.list())
      queryClient.setQueryData(postKeys.list(), (old: Post[]) =>
        old.filter((p) => p.id !== id),
      )
      return { previous }
    },
    onError: (_, __, ctx) => {
      queryClient.setQueryData(postKeys.list(), ctx?.previous)
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: postKeys.lists() }),
  })
}
```

## Rules

- Never fetch in `useEffect` -- always `useQuery`
- Never put server data in zustand -- React Query owns it
- Always `invalidateQueries` in `onSettled` (not `onSuccess`) to handle error cases
- Always cancel in-flight queries in `onMutate` for optimistic updates
- `staleTime: Infinity` -- data never goes stale automatically, refetch manually
