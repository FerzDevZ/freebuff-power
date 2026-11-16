# Fullstack RSC & Server Actions Reference

## 1. Clean Server Action Pattern with Zod
```typescript
'use server';

import { z } from 'zod';
import { revalidatePath } from 'next/cache';
import { db } from '@/lib/db';
import { posts } from '@/lib/schema';

const CreatePostSchema = z.object({
  title: z.string().min(3).max(100),
  content: z.string().min(10),
});

export async function createPostAction(formData: FormData) {
  const parsed = CreatePostSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  if (!parsed.success) {
    return { success: false, errors: parsed.error.flatten().fieldErrors };
  }

  await db.insert(posts).values(parsed.data);
  revalidatePath('/posts');
  return { success: true };
}
```
