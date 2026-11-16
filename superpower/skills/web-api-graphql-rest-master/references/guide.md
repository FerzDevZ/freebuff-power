# API Client & Silent Refresh Reference

```typescript
import { z } from 'zod';

export async function typedFetch<TSchema extends z.ZodTypeAny>(
  url: string,
  schema: TSchema,
  init?: RequestInit
): Promise<z.infer<TSchema>> {
  const response = await fetch(url, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...init?.headers,
    },
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`API Error ${response.status}: ${errorBody}`);
  }

  const rawData = await response.json();
  const parsed = schema.safeParse(rawData);

  if (!parsed.success) {
    console.error('Schema validation error:', parsed.error.format());
    throw new Error('API response contract mismatch');
  }

  return parsed.data;
}
```
