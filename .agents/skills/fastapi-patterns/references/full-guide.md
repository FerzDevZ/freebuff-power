    await db.commit()
    return user

# Good: thin route, transactional service handling.
@router.post("/users/", response_model=UserResponse, status_code=201)
async def create_user(payload: UserCreate, db: DbDep):
    try:
        return await UserService(db).create(payload)
    except DuplicateUserError:
        raise HTTPException(status_code=400, detail="Email already registered")


# Bad: sync DB calls in async routes block the event loop.
@router.get("/items/")
async def list_items(db: Session = Depends(get_db)):
    return db.query(Item).all()

# Good: use async SQLAlchemy executions.
@router.get("/items/")
async def list_items(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Item))
    return result.scalars().all()
```

---

## Best Practices

- Always declare a typed `response_model` to prevent accidental PII/data leaks and output clean OpenAPI schemas.
- Consolidate standard middleware dependency injections via type-aliasing: `DbDep = Annotated[AsyncSession, Depends(get_db)]`.
- Wrap database mutation boundaries gracefully within transactions inside your service layer, catching structural database errors directly.
- Parse JWT parameters defensively, expecting potential string/integer cast mismatches from modern payload variations.
- Enforce deterministic sorting (e.g., `.order_by(Model.id)`) on all offset/limit paginated endpoints to avoid data skips.
- Isolate authorization checks from core authentication dependencies to provide precise REST status signals (`401` vs `403`).
