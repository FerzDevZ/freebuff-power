---
name: laravel-security
description: Laravel security best practices — authentication, authorization, Eloquent safety, CSRF, XSS prevention, API security, and secure deployment configurations. Use when reviewing Laravel auth, Eloquent safety, CSRF, XSS, API security, or deployment configuration.
metadata:
  origin: ECC
---

# Laravel Security Best Practices

Comprehensive security guidelines for Laravel applications to protect against common vulnerabilities.

## When to Activate

- Setting up Laravel authentication and authorization (Sanctum, Passport, Jetstream, Breeze)
- Implementing user roles, permissions, and policies
- Configuring production security settings and environment variables
- Reviewing Laravel applications for security vulnerabilities
- Deploying Laravel applications to production
- Writing secure Eloquent queries and migrations

## Production Configuration

### Essential Production Settings

```php
// config/app.php
'env' => env('APP_ENV', 'production'),
'debug' => (bool) env('APP_DEBUG', false), // CRITICAL: Never true in production
'key' => env('APP_KEY'), // Must be set: php artisan key:generate

// config/session.php
'secure' => env('SESSION_SECURE_COOKIE', true),
'http_only' => true,
'same_site' => 'lax',

// Verify APP_KEY is set at boot
// bootstrap/app.php or a service provider
if (empty(config('app.key'))) {
    throw new RuntimeException('APP_KEY is not set. Run: php artisan key:generate');
}
```

### Environment File Security

```bash
# NEVER commit .env to version control
# .gitignore already includes .env by default

# Use .env.example with placeholders instead
DB_PASSWORD=
APP_KEY=
SANCTUM_TOKEN_PREFIX=

# Validate required variables at boot
// In AppServiceProvider::boot()
$requiredKeys = ['app.key', 'database.connections.mysql.database', 'database.connections.mysql.username'];
foreach ($requiredKeys as $key) {
    if (empty(config($key))) {
        throw new RuntimeException("Missing required config key: {$key}");
    }
}
```

### HTTPS Enforcement

```php
// AppServiceProvider::boot() or middleware
if (app()->environment('production')) {
    URL::forceScheme('https');
    request()->server->set('HTTPS', 'on');
}

// config/app.php for trusted proxies (load balancers)
// Use specific IP ranges — * trusts all, allowing X-Forwarded-* spoofing
// AWS: '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'
'trusted_proxies' => ['10.0.0.0/8', '172.16.0.0/12'],

// Force HTTPS in production via middleware
// app/Http/Middleware/ForceHttps.php
public function handle($request, Closure $next)
{
    if (!$request->secure() && app()->environment('production')) {
        return redirect()->secure($request->getRequestUri());
    }
    return $next($request);
}
```

## Authentication

### Sanctum (API Token Authentication)

```php
// config/sanctum.php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
    '%s%s',
    'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
    env('APP_URL') ? ',' . parse_url(env('APP_URL'), PHP_URL_HOST) : ''
)));

'expiration' => 60 * 24, // Token expiration in minutes (null = never)
'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),

// Issuing tokens with abilities
$token = $user->createToken('api-token', ['read', 'write'])->plainTextToken;

// Validate abilities on routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orders', function () {
        // User must have 'read' ability
        abort_unless(Auth::user()->tokenCan('read'), 403);
        // ...
    })->middleware('abilities:read');

    Route::post('/orders', function () {
        // User must have 'write' ability
        abort_unless(Auth::user()->tokenCan('write'), 403);
        // ...
    })->middleware('abilities:write');
});
```

### Password Security

```php
// config/hashing.php
// Default is bcrypt. Argon2id is stronger.
'bcrypt' => [
    'rounds' => env('BCRYPT_ROUNDS', 12), // Increase for stronger hashing
],

'argon' => [
    'memory' => 65536,
    'threads' => 4,
    'time' => 4,
],

// Password validation in RegisterRequest
public function rules(): array
{
    return [
        'password' => [
            'required',
            'confirmed',
            Password::min(12)
                ->letters()
                ->mixedCase()
                ->numbers()
                ->symbols()
                ->uncompromised(), // Checks haveibeenpwned
        ],
    ];
}

// Rate limit login attempts
// App\Http\Controllers\Auth\AuthenticatedSessionController
protected function authenticated(Request $request, $user)
{
    if ($user->wasRecentlyLockedOut()) {
        // Notify user of suspicious login
        $user->notify(new SuspiciousLoginNotification($request->ip()));
    }
}
```

### Session Management

```php
// config/session.php
'driver' => env('SESSION_DRIVER', 'database'), // database/redis > file
'lifetime' => env('SESSION_LIFETIME', 120),
'expire_on_close' => env('SESSION_EXPIRE_ON_CLOSE', false),
'encrypt' => env('SESSION_ENCRYPT', false),

// Regenerate session on login
// App\Http\Controllers\Auth\AuthenticatedSessionController
public function store(LoginRequest $request): RedirectResponse
{
    $request->authenticate();
    $request->session()->regenerate(); // CRITICAL: prevents session fixation
    return redirect()->intended(RouteServiceProvider::HOME);
}

// Invalidate session on logout
public function destroy(Request $request): RedirectResponse
{
    Auth::guard('web')->logout();
    $request->session()->invalidate();
    $request->session()->regenerateToken();
    return redirect('/');
}
```

## Authorization

### Gates

```php
// App\Providers\AuthServiceProvider
use App\Models\Post;
use App\Models\User;
use Illuminate\Support\Facades\Gate;

public function boot(): void
{
    Gate::define('update-post', function (User $user, Post $post): bool {
        return $user->id === $post->user_id;
    });

    Gate::define('publish-post', function (User $user): bool {
        return $user->role === 'editor' || $user->role === 'admin';
    });

    // Using before() for super-admin override
    Gate::before(function (User $user, string $ability): ?bool {
        if ($user->role === 'super-admin') {
            return true; // Grants all abilities
        }
        return null; // Fall through to normal checks
    });
}

// Usage in controllers
public function update(Request $request, Post $post): RedirectResponse
{
    Gate::authorize('update-post', $post);
    // Or: $this->authorize('update-post', $post);
    // Or: abort_unless(Auth::user()->can('update-post', $post), 403);
    // ...
}
```

### Policies

```php
// App\Policies\PostPolicy
class PostPolicy
{
    use HandlesAuthorization;

    public function viewAny(?User $user): bool
    {
        return true; // Public listing
    }

    public function view(?User $user, Post $post): bool
    {
        return $post->is_published || ($user && $user->id === $post->user_id);
    }

    public function create(User $user): bool
    {
        return $user->hasVerifiedEmail(); // Must verify email first
    }

    public function update(User $user, Post $post): bool
    {
        return $user->id === $post->user_id;
    }

    public function delete(User $user, Post $post): bool
    {
        return $user->id === $post->user_id && $post->created_at->diffInDays(now()) <= 30;
    }

    public function restore(User $user, Post $post): bool
    {
        return $user->role === 'admin';
    }

    public function forceDelete(User $user, Post $post): bool
    {
        return $user->role === 'super-admin';
    }
}

// Register in AuthServiceProvider
protected $policies = [
    Post::class => PostPolicy::class,
];

// Controller usage
public function show(Post $post): View
{
    $this->authorize('view', $post);
    return view('posts.show', compact('post'));
}

// Blade usage
@can('update', $post)
    <a href="{{ route('posts.edit', $post) }}">Edit</a>
@endcan

@cannot('update', $post)
    <span>You cannot edit this post</span>
@endcannot
```

### Middleware Authorization

```php
// Using middleware in routes
Route::put('/posts/{post}', [PostController::class, 'update'])
    ->middleware('can:update,post');

Route::get('/posts/create', [PostController::class, 'create'])
    ->middleware('can:create,App\Models\Post');

// Custom authorization middleware
// app/Http/Middleware/CheckRole.php
class CheckRole
{
    public function handle(Request $request, Closure $next, string $role): mixed
    {
        if (!$request->user() || $request->user()->role !== $role) {
            abort(403, 'Unauthorized. This area requires role: ' . $role);
        }
        return $next($request);
    }
}

// Register in Kernel
protected $routeMiddleware = [
    'role' => \App\Http\Middleware\CheckRole::class,
];

// Route usage
Route::middleware(['auth', 'role:admin'])->group(function () {
    Route::get('/admin', [AdminController::class, 'index']);
});
```

## Eloquent Security

### Mass Assignment Protection

```php
// BAD: $guarded = [] allows ALL columns to be mass-assigned
// NEVER use $guarded = [] in production

// GOOD: Whitelist fillable attributes
final class User extends Authenticatable
{
    protected $fillable = [
        'name',
        'email',
        'phone',
        'avatar',
    ];
    // NEVER add 'role', 'is_admin', 'is_verified' here
}

// GOOD: Explicitly control which fields can be filled in requests
public function store(StoreUserRequest $request): RedirectResponse
{
    $user = User::create($request->safe()->only([
        'name', 'email', 'phone', 'avatar'
    ]));
    // $request->safe() uses validated data only
    // $request->only() is NOT safe on its own without validation rules
}

// BAD: Creating a user with request data directly
User::create($request->all()); // VULNERABLE to mass assignment!

// BETTER: Use DTOs for creation
$user = User::create($request->validated()); // Only validated fields
```

### SQL Injection Prevention

```php
// GOOD: Eloquent automatically parameterizes queries
User::where('email', $userInput)->first();
User::whereRaw('email = ?', [$userInput])->first();

// GOOD: Query Builder also parameterizes
DB::table('users')->where('email', $userInput)->first();
DB::select('SELECT * FROM users WHERE email = ?', [$userInput]);

// BAD: Raw string interpolation
DB::select("SELECT * FROM users WHERE email = '{$userInput}'"); // VULNERABLE!
User::whereRaw("email = '{$userInput}'")->first(); // VULNERABLE!

// BAD: whereRaw/orderByRaw with unescaped input
User::orderByRaw($userInput); // VULNERABLE!
User::groupByRaw($userInput); // VULNERABLE!

// BAD: DB::statement with concatenation
DB::statement("INSERT INTO users (email) VALUES ('{$userInput}')"); // VULNERABLE!
```

### Attribute Casting

```php
final class User extends Authenticatable
{
    protected $casts = [
        'email_verified_at' => 'datetime',
        'is_admin' => 'boolean', // Cast to boolean prevents string injection
        'settings' => 'array', // Automatically json_encode/json_decode
        'metadata' => 'encrypted:array', // Laravel 11+ encrypted casting
        'password' => 'hashed', // Laravel 10+ auto-hashes on set
    ];
}
```

### Model Security

```php
final class User extends Authenticatable
{
    // Hide sensitive attributes from JSON/API responses
    protected $hidden = [
        'password',
        'remember_token',
        'two_factor_secret',
        'two_factor_recovery_codes',
    ];

    // Append only safe computed attributes
    protected $appends = ['full_name']; // safe
    // NEVER append sensitive computed data
}

final class Post extends Model
{
    // Global scope to filter soft deleted records
    use SoftDeletes;

    // Prevent N+1 by restricting lazy loading (optional strict mode)
    // AppServiceProvider::boot()
    // Model::preventLazyLoading(!app()->isProduction());
}
```

## CSRF Protection

### Default Protection

```php
// Laravel CSRF is enabled by default via VerifyCsrfToken middleware
// app/Http/Kernel.php (protected $middlewareGroups['web'])

// All POST/PUT/PATCH/DELETE forms must include @csrf
<form method="POST" action="/posts">
    @csrf
    <input type="text" name="title">
    <button type="submit">Create</button>
</form>
```

### Excluding Routes (Carefully)

```php
// app/Http/Middleware/VerifyCsrfToken.php
class VerifyCsrfToken extends Middleware
{
    // Only exclude routes that have external CSRF protection (webhooks, etc.)
    protected $except = [
        'stripe/*', // Stripe webhooks use their own signature verification
        // Avoid blanket 'api/*' — stateful Sanctum routes need CSRF.
        // Exclude only specific stateless webhook/endpoint routes.
    ];
}
```

### CSRF with JavaScript

```html
<meta name="csrf-token" content="{{ csrf_token() }}">

<script>
// Axios example (Laravel ships with Axios)
axios.defaults.headers.common['X-CSRF-TOKEN'] = document.querySelector(
    'meta[name="csrf-token"]'
).getAttribute('content');

// Fetch example
fetch('/posts', {

---

## Detailed Reference

For the full detailed guide (code examples, patterns, checklists), see [references/full-guide.md](references/full-guide.md).
