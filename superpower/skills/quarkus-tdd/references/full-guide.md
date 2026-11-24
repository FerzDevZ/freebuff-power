      // ARRANGE
      AtomicReference<LogContext> capturedContext = new AtomicReference<>();

      doAnswer(invocation -> {
        capturedContext.set(CustomLog.getCurrentContext());
        ((Runnable) invocation.getArgument(0)).run();
        return null;
      }).when(executorService).execute(any(Runnable.class));

      // ACT
      fileStorageService.uploadOriginalFile(testInputStream, 1024L,
          testLogContext, InvoiceFormat.UBL).join();

      // ASSERT
      assertThat(capturedContext.get()).isNotNull();
      assertThat(capturedContext.get().get("traceId")).isEqualTo("trace-123");
    }
  }
}
```

## Resource Layer Tests (REST Assured)

```java
@QuarkusTest
@DisplayName("DocumentResource API Tests")
class DocumentResourceTest {

  @InjectMock
  DocumentService documentService;

  @Nested
  @DisplayName("Tests for GET /api/documents")
  class ListDocuments {

    @Test
    @DisplayName("Should return list of documents")
    void givenDocumentsExist_whenList_thenReturnsOk() {
      // ARRANGE
      List<Document> documents = List.of(createDocument(1L, "DOC-001"));
      when(documentService.list(0, 20)).thenReturn(documents);

      // ACT & ASSERT
      given()
          .when().get("/api/documents")
          .then()
          .statusCode(200)
          .body("$.size()", is(1))
          .body("[0].referenceNumber", equalTo("DOC-001"));
    }
  }

  @Nested
  @DisplayName("Tests for POST /api/documents")
  class CreateDocument {

    @Test
    @DisplayName("Should create document and return 201")
    void givenValidRequest_whenCreate_thenReturns201() {
      // ARRANGE
      Document document = createDocument(1L, "DOC-001");
      when(documentService.create(any())).thenReturn(document);

      // ACT & ASSERT
      given()
          .contentType(ContentType.JSON)
          .body("""
              {
                "referenceNumber": "DOC-001",
                "description": "Test document",
                "validUntil": "2030-01-01T00:00:00Z",
                "categories": ["test"]
              }
              """)
          .when().post("/api/documents")
          .then()
          .statusCode(201)
          .header("Location", containsString("/api/documents/1"))
          .body("referenceNumber", equalTo("DOC-001"));
    }

    @Test
    @DisplayName("Should return 400 for invalid input")
    void givenInvalidRequest_whenCreate_thenReturns400() {
      // ACT & ASSERT
      given()
          .contentType(ContentType.JSON)
          .body("""
              {
                "referenceNumber": "",
                "description": "Test"
              }
              """)
          .when().post("/api/documents")
          .then()
          .statusCode(400);
    }
  }

  private Document createDocument(Long id, String referenceNumber) {
    Document document = new Document();
    document.setId(id);
    document.setReferenceNumber(referenceNumber);
    document.setStatus(DocumentStatus.PENDING);
    return document;
  }
}
```

## Integration Tests with Real Database

```java
@QuarkusTest
@TestProfile(IntegrationTestProfile.class)
@DisplayName("Document Integration Tests")
class DocumentIntegrationTest {

  @Test
  @Transactional
  @DisplayName("Should create and retrieve document via API")
  void givenNewDocument_whenCreateAndRetrieve_thenSuccessful() {
    // ACT - Create via API
    Long id = given()
        .contentType(ContentType.JSON)
        .body("""
            {
              "referenceNumber": "INT-001",
              "description": "Integration test",
              "validUntil": "2030-01-01T00:00:00Z",
              "categories": ["test"]
            }
            """)
        .when().post("/api/documents")
        .then()
        .statusCode(201)
        .extract().path("id");

    // ASSERT - Retrieve via API
    given()
        .when().get("/api/documents/" + id)
        .then()
        .statusCode(200)
        .body("referenceNumber", equalTo("INT-001"));
  }
}
```

## Coverage with JaCoCo

### Maven Configuration (Complete)

```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.13</version>
  <executions>
    <!-- Prepare agent for test execution -->
    <execution>
      <id>prepare-agent</id>
      <goals>
        <goal>prepare-agent</goal>
      </goals>
    </execution>

    <!-- Generate coverage report -->
    <execution>
      <id>report</id>
      <phase>verify</phase>
      <goals>
        <goal>report</goal>
      </goals>
    </execution>

    <!-- Enforce coverage thresholds -->
    <execution>
      <id>check</id>
      <goals>
        <goal>check</goal>
      </goals>
      <configuration>
        <rules>
          <rule>
            <element>BUNDLE</element>
            <limits>
              <limit>
                <counter>LINE</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.80</minimum>
              </limit>
              <limit>
                <counter>BRANCH</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.70</minimum>
              </limit>
            </limits>
          </rule>
        </rules>
      </configuration>
    </execution>
  </executions>
</plugin>
```

Run tests with coverage:
```bash
mvn clean test
mvn jacoco:report
mvn jacoco:check

# Report at: target/site/jacoco/index.html
```

## Test Dependencies

```xml
<dependencies>
    <!-- Quarkus Testing -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-junit5</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-junit5-mockito</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- Mockito -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- AssertJ (preferred over JUnit assertions) -->
    <dependency>
        <groupId>org.assertj</groupId>
        <artifactId>assertj-core</artifactId>
        <version>3.24.2</version>
        <scope>test</scope>
    </dependency>

    <!-- REST Assured -->
    <dependency>
        <groupId>io.rest-assured</groupId>
        <artifactId>rest-assured</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- Camel Testing -->
    <dependency>
        <groupId>org.apache.camel.quarkus</groupId>
        <artifactId>camel-quarkus-junit5</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Best Practices

### Test Organization
- Use `@Nested` classes to group tests by method being tested
- Use `@DisplayName` for readable test descriptions visible in reports
- Follow `givenX_whenY_thenZ` naming convention for test methods
- Use `@BeforeEach` for common test data setup to reduce duplication

### Test Structure
- Follow AAA pattern with explicit comments (`// ARRANGE`, `// ACT`, `// ASSERT`)
- Use `assertDoesNotThrow` for success scenarios
- Use `assertThrows` for exception scenarios with message validation
- Verify exception messages match expected values using AssertJ `contains()` or `isEqualTo()`

### Test Coverage
- Test happy paths for all public methods
- Test null input handling
- Test edge cases (empty collections, boundary values, negative IDs, blank strings)
- Test exception scenarios comprehensively
- Mock all external dependencies (repositories, services, Camel endpoints)
- Aim for 80%+ line coverage, 70%+ branch coverage

### Assertions
- **Prefer AssertJ** (`assertThat`) over JUnit assertions for value checks
- Use fluent AssertJ API for readability: `assertThat(list).hasSize(3).contains(item)`
- For exceptions: use JUnit `assertThrows` to capture, then AssertJ to validate the message
- For non-throwing success paths: use JUnit `assertDoesNotThrow`
- For collections: `extracting()`, `filteredOn()`, `containsExactly()`

### Testing Integration
- Use `@QuarkusTest` for integration tests
- Use `@InjectMock` to mock dependencies in Quarkus tests
- Prefer REST Assured for API testing
- Use `@TestProfile` for test-specific configuration

### Event-Driven Testing
- Test Camel routes with `AdviceWith` and `MockEndpoint`
- Use `@CamelQuarkusTest` annotation (if using standalone Camel tests)
- Verify message content, headers, and routing logic
- Test error handling routes separately
- Mock external systems (RabbitMQ, S3, databases) in unit tests

### Camel Route Testing
- Use `MockEndpoint` for asserting message flow
- Use `AdviceWith` to modify routes for testing (replace endpoints with mocks)
- Test message transformation and marshalling
- Test exception handling and dead letter queues

### Testing Async Operations
- Test CompletableFuture success and failure scenarios
- Use `.join()` in tests to wait for async completion
- Test exception propagation from CompletableFuture
- Verify LogContext propagation to async operations

### Performance
- Keep tests fast and isolated
- Run tests in continuous mode: `mvn quarkus:test`
- Use parameterized tests (`@ParameterizedTest`) for input variations
- Build reusable test data builders or factory methods

### Quarkus-Specific
- Stay on latest LTS version (Quarkus 3.x)
- Test native compilation compatibility periodically
- Use Quarkus test profiles for different scenarios
- Leverage Quarkus dev services for local testing
- Use `@InjectMock` instead of `@MockBean` (Quarkus-specific)

### Verification Best Practices
- Always verify interactions on mocked dependencies
- Use `verify(mock, never())` to ensure methods are NOT called in error scenarios
- Use `argThat()` for complex argument matching
- Verify the order of calls when it matters: `InOrder` from Mockito
