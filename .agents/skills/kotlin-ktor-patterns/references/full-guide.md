    }
}

fun Route.chatRoutes() {
    val connections = Collections.synchronizedSet<Connection>(LinkedHashSet())

    webSocket("/chat") {
        val thisConnection = Connection(this)
        connections += thisConnection

        try {
            send("Connected! Users online: ${connections.size}")

            for (frame in incoming) {
                frame as? Frame.Text ?: continue
                val text = frame.readText()
                val message = ChatMessage(thisConnection.name, text)

                // Snapshot under lock to avoid ConcurrentModificationException
                val snapshot = synchronized(connections) { connections.toList() }
                snapshot.forEach { conn ->
                    conn.session.send(Json.encodeToString(message))
                }
            }
        } catch (e: Exception) {
            logger.error("WebSocket error", e)
        } finally {
            connections -= thisConnection
        }
    }
}

data class Connection(val session: DefaultWebSocketSession) {
    val name: String = "User-${counter.getAndIncrement()}"

    companion object {
        private val counter = AtomicInteger(0)
    }
}
```

## testApplication Testing

### Basic Route Testing

```kotlin
class UserRoutesTest : FunSpec({
    test("GET /users returns list of users") {
        testApplication {
            application {
                install(Koin) { modules(testModule) }
                configureSerialization()
                configureRouting()
            }

            val response = client.get("/users")

            response.status shouldBe HttpStatusCode.OK
            val body = response.body<ApiResponse<List<UserResponse>>>()
            body.success shouldBe true
            body.data.shouldNotBeNull().shouldNotBeEmpty()
        }
    }

    test("POST /users creates a user") {
        testApplication {
            application {
                install(Koin) { modules(testModule) }
                configureSerialization()
                configureStatusPages()
                configureRouting()
            }

            val client = createClient {
                install(io.ktor.client.plugins.contentnegotiation.ContentNegotiation) {
                    json()
                }
            }

            val response = client.post("/users") {
                contentType(ContentType.Application.Json)
                setBody(CreateUserRequest("Alice", "alice@example.com"))
            }

            response.status shouldBe HttpStatusCode.Created
        }
    }

    test("GET /users/{id} returns 404 for unknown id") {
        testApplication {
            application {
                install(Koin) { modules(testModule) }
                configureSerialization()
                configureStatusPages()
                configureRouting()
            }

            val response = client.get("/users/unknown-id")

            response.status shouldBe HttpStatusCode.NotFound
        }
    }
})
```

### Testing Authenticated Routes

```kotlin
class AuthenticatedRoutesTest : FunSpec({
    test("protected route requires JWT") {
        testApplication {
            application {
                install(Koin) { modules(testModule) }
                configureSerialization()
                configureAuthentication()
                configureRouting()
            }

            val response = client.post("/users") {
                contentType(ContentType.Application.Json)
                setBody(CreateUserRequest("Alice", "alice@example.com"))
            }

            response.status shouldBe HttpStatusCode.Unauthorized
        }
    }

    test("protected route succeeds with valid JWT") {
        testApplication {
            application {
                install(Koin) { modules(testModule) }
                configureSerialization()
                configureAuthentication()
                configureRouting()
            }

            val token = generateTestJWT(userId = "test-user")

            val client = createClient {
                install(io.ktor.client.plugins.contentnegotiation.ContentNegotiation) { json() }
            }

            val response = client.post("/users") {
                contentType(ContentType.Application.Json)
                bearerAuth(token)
                setBody(CreateUserRequest("Alice", "alice@example.com"))
            }

            response.status shouldBe HttpStatusCode.Created
        }
    }
})
```

## Configuration

### application.yaml

```yaml
ktor:
  application:
    modules:
      - com.example.ApplicationKt.module
  deployment:
    port: 8080

jwt:
  secret: ${JWT_SECRET}
  issuer: "https://example.com"
  audience: "https://example.com/api"
  realm: "example"

database:
  url: ${DATABASE_URL}
  driver: "org.postgresql.Driver"
  maxPoolSize: 10
```

### Reading Config

```kotlin
fun Application.configureDI() {
    val dbUrl = environment.config.property("database.url").getString()
    val dbDriver = environment.config.property("database.driver").getString()
    val maxPoolSize = environment.config.property("database.maxPoolSize").getString().toInt()

    install(Koin) {
        modules(module {
            single { DatabaseConfig(dbUrl, dbDriver, maxPoolSize) }
            single { DatabaseFactory.create(get()) }
        })
    }
}
```

## Quick Reference: Ktor Patterns

| Pattern | Description |
|---------|-------------|
| `route("/path") { get { } }` | Route grouping with DSL |
| `call.receive<T>()` | Deserialize request body |
| `call.respond(status, body)` | Send response with status |
| `call.parameters["id"]` | Read path parameters |
| `call.request.queryParameters["q"]` | Read query parameters |
| `install(Plugin) { }` | Install and configure plugin |
| `authenticate("name") { }` | Protect routes with auth |
| `by inject<T>()` | Koin dependency injection |
| `testApplication { }` | Integration testing |

**Remember**: Ktor is designed around Kotlin coroutines and DSLs. Keep routes thin, push logic to services, and use Koin for dependency injection. Test with `testApplication` for full integration coverage.
