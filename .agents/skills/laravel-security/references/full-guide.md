    method: 'POST',
    headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
});
</script>
```

## XSS Prevention

### Blade Templating Security

```blade
{{-- SAFE: Auto-escaped by Blade --}}
{{ $userInput }}

{{-- DANGEROUS: Raw output — NEVER use with user input --}}
{!! $userInput !!}

{{-- SAFE: Only use {!! !!} with trusted content you control --}}
{!! $trustedHtmlFromYourServer !!}

{{-- GOOD: Use specific escaping directives --}}
@js($data) {{-- JSON encode for JavaScript --}}
@json($data) {{-- JSON encode in templates --}}

{{-- BAD: Direct user input in raw HTML --}}
<div>{!! $user->bio !!}</div> {{-- VULNERABLE if user provides bio --}}
```

### Safe HTML Handling

```php
// When you must allow some HTML, use a whitelist approach
use HTMLPurifier; // Requires: composer require ezyang/htmlpurifier

public function sanitizeHtml(string $dirty): string
{
    $config = \HTMLPurifier_Config::createDefault();
    $config->set('HTML.Allowed', 'p,b,i,a[href],ul,ol,li,br');
    $config->set('URI.AllowedSchemes', ['http', 'https', 'mailto']);
    $purifier = new \HTMLPurifier($config);
    return $purifier->purify($dirty);
}

// In blade:
<div>{!! $sanitizedContent !!}</div> {{-- Safe after purification --}}
```

### JavaScript Context Escaping

```blade
{{-- SAFE: Blade @js escapes for JavaScript context --}}
<script>
    const user = @js($user); // JSON + escaped for JS context
    const settings = @json($settings); // Direct JSON encode
</script>

{{-- DANGEROUS: Manual JSON in JS context --}}
<script>
    const user = {{ json_encode($user) }}; // NOT escaped for JS!
</script>
```

### HTTP Headers for XSS Protection

```php
// App\Http\Middleware\SecurityHeaders.php
class SecurityHeaders
{
    public function handle(Request $request, Closure $next): mixed
    {
        $response = $next($request);

        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'DENY');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        $response->headers->set(
            'Content-Security-Policy',
            "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'"
        );

        return $response;
    }
}

// Register in kernel
protected $middleware = [
    \App\Http\Middleware\SecurityHeaders::class,
];
```

## Input Validation

### Form Request Validation

```php
final class StorePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('create', Post::class) ?? false;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255', 'sanitize_html'],
            'content' => ['required', 'string', 'max:10000'],
            'image' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png,gif,webp', // Whitelist specific types
                'max:2048', // 2MB max
            ],
            'tags' => ['array'],
            'tags.*' => ['integer', 'exists:tags,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.max' => 'Post title must not exceed 255 characters.',
            'image.max' => 'Image must be under 2MB.',
        ];
    }

    // Sanitize input after validation
    public function validated($key = null, $default = null): mixed
    {
        $validated = parent::validated();
        $validated['title'] = strip_tags($validated['title']);
        return $key ? ($validated[$key] ?? $default) : $validated;
    }
}
```

### Custom Validation Rules

```php
// app/Rules/StrongPassword.php
class StrongPassword implements Rule
{
    public function passes($attribute, $value): bool
    {
        return preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#^()_\-+=])[A-Za-z\d@$!%*?&#^()_\-+=]{12,}$/', $value);
    }

    public function message(): string
    {
        return 'The :attribute must be at least 12 characters with uppercase, lowercase, number, and symbol.';
    }
}

// app/Rules/NotBlacklistedDomain.php
class NotBlacklistedDomain implements Rule
{
    private array $blacklisted = ['mailinator.com', 'guerrillamail.com'];

    public function passes($attribute, $value): bool
    {
        $domain = substr(strrchr($value, '@'), 1);
        return !in_array(strtolower($domain), $this->blacklisted);
    }

    public function message(): string
    {
        return 'Email from disposable domains is not allowed.';
    }
}
```

## API Security

### Rate Limiting

```php
// App/Providers/RouteServiceProvider
protected function configureRateLimiting(): void
{
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
    });

    RateLimiter::for('auth', function (Request $request) {
        return Limit::perMinute(5)->by($request->ip())
            ->response(function () {
                return response()->json([
                    'message' => 'Too many login attempts. Try again in 1 minute.',
                ], 429);
            });
    });

    RateLimiter::for('uploads', function (Request $request) {
        return Limit::perHour(10)->by($request->user()?->id ?? $request->ip())
            ->response(function () {
                return response()->json([
                    'message' => 'Upload limit reached. Try again later.',
                ], 429);
            });
    });
}

// Route usage
Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
    Route::apiResource('posts', PostController::class);
});

Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:auth');
```

### API Authentication — Sanctum vs Passport

```php
// Sanctum (recommended for most apps — simple, first-party, SPA)
// config/sanctum.php
'expiration' => 60 * 24, // Tokens expire after 24 hours
'model' => User::class,

// Issuing scoped tokens
$token = $user->createToken('client-name', [
    'posts:read',
    'posts:write',
])->plainTextToken;

// Middleware scoping
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/posts', [PostController::class, 'index'])
        ->middleware('abilities:posts:read');

    Route::post('/posts', [PostController::class, 'store'])
        ->middleware('abilities:posts:write');
});

// Passport (OAuth2 — for third-party clients or complex auth flows)
// Install: composer require laravel/passport
Passport::tokensExpireIn(now()->addDays(15));
Passport::refreshTokensExpireIn(now()->addDays(30));
Passport::personalAccessTokensExpireIn(now()->addMonths(6));
```

### CORS Configuration

```php
// config/cors.php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', '')), // Whitelist specific origins
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => ['X-Total-Count', 'X-Pagination-Page'],
    'max_age' => 0,
    'supports_credentials' => true, // Required for Sanctum SPA auth
];

// NEVER: Allow all origins in production unless absolutely necessary
// 'allowed_origins' => ['*'], // Only for truly public APIs
```

## File Upload Security

### Validation

```php
public function rules(): array
{
    return [
        'document' => [
            'required',
            'file',
            'mimes:pdf,doc,docx,xls,xlsx', // Whitelist specific MIME types
            'max:10240', // 10MB
            'extensions:pdf,doc,docx,xls,xlsx', // Verify extension matches MIME
        ],
        'avatar' => [
            'nullable',
            'image', // Ensures it's a valid image
            'mimes:jpg,jpeg,png,webp',
            'max:2048',
            'dimensions:min_width=100,min_height=100,max_width=2000,max_height=2000',
        ],
    ];
}
```

### Secure Storage

```php
// Store sensitive files on the same private disk used to create temporary URLs.
$path = $request->file('document')->store('documents', 's3');
// Never use the 'public' disk for sensitive documents.

// Use signed URLs for temporary file access
use Illuminate\Support\Facades\Storage;

public function download(Document $document)
{
    // Requires route-model binding for Document, a persisted $document->path,
    // and a DocumentPolicy::download rule registered with Laravel.
    // Authorize against the model that owns the file, never a path taken from the request
    $this->authorize('download', $document);

    // Generate the temporary signed URL (expires in 15 minutes) only after authorization
    $url = Storage::disk('s3')->temporaryUrl($document->path, now()->addMinutes(15));

    return redirect($url);
}

// Storage configuration for cloud with encryption
// config/filesystems.php
's3' => [
    'driver' => 's3',
    'key' => env('AWS_ACCESS_KEY_ID'),
    'secret' => env('AWS_SECRET_ACCESS_KEY'),
    'region' => env('AWS_DEFAULT_REGION'),
    'bucket' => env('AWS_BUCKET'),
    'url' => env('AWS_URL'),
    'endpoint' => env('AWS_ENDPOINT'),
    'use_path_style_endpoint' => env('AWS_USE_PATH_STYLE_ENDPOINT', false),
    'throw' => false,
    'server_side_encryption' => 'AES256', // Encrypt at rest
],
```

## Dependencies and Secrets

### Composer Security

```bash
# Always audit dependencies in CI
composer audit

# Pin major versions in composer.json
"laravel/framework": "^11.0",
"spatie/laravel-permission": "^6.0"

# Check for abandoned packages
composer why-not

# Keep lock file in version control (it pins exact versions)
# Run `composer update` deliberately, never in CI/CD
```

### Secret Management

```bash
# .env file (NEVER commit)
# .gitignore includes .env by default

APP_KEY=base64:abc123...
DB_PASSWORD=secure_password
STRIPE_KEY=sk_live_...
SANCTUM_TOKEN_PREFIX=myapp_

# For production: Use a secret manager
# Deploy with: env $(aws secretsmanager get-secret-value --secret-id prod/db | jq ...) php artisan serve

# Validate secrets at boot (AppServiceProvider::boot)
$secrets = ['services.stripe.key', 'services.stripe.webhook_secret'];
foreach ($secrets as $key) {
    if (empty(config($key))) {
        Log::critical("Missing secret: {$key}");
    }
}
```

## Queue Security

```php
// Define a named rate limiter (typically in AppServiceProvider::boot())
RateLimiter::for('payments', fn () => Limit::perMinute(5));
```

```php
// Encrypt sensitive job data by implementing the interface
final class ProcessPaymentJob implements ShouldQueue, ShouldBeEncrypted
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        private readonly string $paymentIntentId, // Public IDs are fine
        private readonly string $cardFingerprint, // Encrypted via ShouldBeEncrypted
    ) {}

    public function handle(): void
    {
        // Process payment
    }

    // Limit retries and delay between attempts
    public function retryUntil(): Carbon
    {
        return now()->addMinutes(5);
    }

    // Rate limit how many jobs of this type can run
    public function middleware(): array
    {
        return [
            new RateLimited('payments'),
        ];
    }
}
```

## Logging Security Events

```php
// config/logging.php
'channels' => [
    'security' => [
        'driver' => 'single',
        'path' => storage_path('logs/security.log'),
        'level' => 'warning',
    ],
],

// Audit log helper
final class SecurityLogger
{
    public static function log(string $event, array $context = []): void
    {
        Log::channel('security')->warning($event, array_merge([
            'user_id' => Auth::id(),
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'url' => request()->fullUrl(),
            'timestamp' => now()->toIso8601String(),
        ], $context));
    }
}

// Usage
SecurityLogger::log('failed_login_attempt', ['email' => $email]);
SecurityLogger::log('password_change');
SecurityLogger::log('role_change', ['target_user' => $targetId, 'new_role' => 'admin']);
SecurityLogger::log('suspicious_activity', ['reason' => 'multiple_attempts_from_different_ips']);
```

## Quick Security Checklist

| Check | Description |
|-------|-------------|
| `APP_DEBUG=false` | Never run with debug enabled in production |
| `APP_KEY` set | Always run `php artisan key:generate` |
| HTTPS enforced | Force HTTPS in production via middleware or proxy |
| `$fillable` whitelisted | Never use `$guarded = []` |
| CSRF active | `@csrf` on all state-changing forms |
| Sanctum/Passport configured | API authentication with token abilities/scopes |
| Rate limiting applied | Throttle API and auth endpoints |
| Input validation | FormRequest with specific rules, never `$request->all()` |
| File upload restrictions | Validate MIME types, size, dimensions |
| `composer audit` in CI | Check dependencies for known vulnerabilities |
| `password_hash` / `password_verify` | Use Laravel's built-in hashing (bcrypt/Argon2) |
| Session regeneration on login | Call `$request->session()->regenerate()` |
| Security headers middleware | CSP, X-Frame-Options, X-Content-Type-Options |
| Logged security events | Audit log for auth failures, role changes, suspicious activity |
| `.env` not committed | Verify `.gitignore` includes `.env` |

## Related Skills

- `laravel-patterns` — Laravel architecture, routing, Eloquent, and API patterns
- `backend-patterns` — General backend API and database patterns
- `laravel-tdd` — Laravel testing with PHPUnit and Pest
