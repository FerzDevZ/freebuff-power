---
name: web-forms-validation-rhf-zod
description: Production React/Next.js forms with react-hook-form and Zod — one schema shared by client and server, field-level errors that are actually accessible, async validation without races, multi-step state, and tests that prove invalid input never reaches the mutation.
---

# Forms that cannot submit garbage

A form is a trust boundary. The browser copy of the schema is UX; the server copy
is the control. Derive both from one Zod schema so they cannot drift.

## One schema, two consumers

```ts
// features/signup/schema.ts
import { z } from "zod";

export const signupSchema = z.object({
  email: z.string().trim().toLowerCase().email("Email tidak valid"),
  password: z.string().min(12, "Minimal 12 karakter"),
  age: z.coerce.number().int().min(13, "Minimal 13 tahun"),
  acceptTerms: z.literal(true, { errorMap: () => ({ message: "Wajib disetujui" }) }),
});

export type SignupInput = z.infer<typeof signupSchema>;
```

```ts
// server action / route handler
const parsed = signupSchema.safeParse(await request.json());
if (!parsed.success) {
  return Response.json({ errors: parsed.error.flatten().fieldErrors }, { status: 422 });
}
```

Never `schema.parse()` unguarded in a request path: it throws and turns a 422 into
a 500. Never cast `req.body as SignupInput`.

## Wiring react-hook-form

```tsx
const form = useForm<SignupInput>({
  resolver: zodResolver(signupSchema),
  mode: "onBlur",
  defaultValues: { email: "", password: "", age: 18, acceptTerms: false },
});

<form onSubmit={form.handleSubmit(onSubmit)} noValidate>
  <input {...form.register("email")} aria-invalid={!!form.formState.errors.email} />
  {form.formState.errors.email && (
    <p role="alert">{form.formState.errors.email.message}</p>
  )}
</form>
```

- `zodResolver` comes from `@hookform/resolvers/zod`; the resolver version must
  match the Zod major (v3 vs v4 resolvers are not interchangeable).
- Use `noValidate` on the form so browser bubbles do not mask your messages.
- Errors need `aria-invalid` and `role="alert"`; a red border alone is not
  accessible.
- Disable the submit button while `form.formState.isSubmitting`, but still guard
  server-side — double submission is a server problem.

## Async validation without races

```ts
const checkEmail = async (email: string) => {
  const res = await fetch(`/api/email-available?email=${encodeURIComponent(email)}`);
  return res.ok;
};
```

- debounce and abort the previous request (`AbortController`), or an older response
  can overwrite a newer field state;
- async checks belong in the submit path when they decide uniqueness — a client
  check is advisory only;
- server rate-limits the availability endpoint, otherwise it is an enumeration oracle.

## Multi-step forms

- keep one `useForm` per step with a step schema, or one form with a step index and
  per-step validation via `form.trigger(fieldsOfStep)`;
- preserve entered data when going back; do not unmount and lose it;
- final submit validates the full schema, not just the last step.

## File uploads

Validate size and MIME **on the server** from the actual bytes/stream, not the
`Content-Type` header. Client-side `accept` is a hint.

## Testing the boundary

- a unit test that the schema rejects the hostile cases (empty, too long, wrong
  type, missing consent);
- a component test that submits invalid data and asserts the mutation was not
  called;
- one integration test that posts raw invalid JSON straight to the handler,
  bypassing the UI.

If the only test goes through the UI, the server boundary is untested.

## Limits

- Zod v3 and v4 error-map APIs differ; pin one and read that version's docs.
- This is a client/server forms pattern, not a validation library comparison.
- No fixture: behaviour depends on your app's test runner and DOM environment.
