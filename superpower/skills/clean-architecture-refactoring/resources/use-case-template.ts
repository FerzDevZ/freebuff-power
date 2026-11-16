// Clean Architecture Use Case & Port Template (TypeScript)

// 1. Driven Port (Interface)
export interface UserRepositoryPort {
  findByEmail(email: string): Promise<UserEntity | null>;
  save(user: UserEntity): Promise<void>;
}

// 2. Domain Entity
export class UserEntity {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public status: 'ACTIVE' | 'SUSPENDED'
  ) {}

  public suspend(): void {
    this.status = 'SUSPENDED';
  }
}

// 3. Application Use Case (Driving Port)
export class SuspendUserUseCase {
  constructor(private readonly userRepo: UserRepositoryPort) {}

  async execute(userId: string): Promise<void> {
    const user = await this.userRepo.findByEmail(userId);
    if (!user) {
      throw new Error(`User not found: ${userId}`);
    }
    user.suspend();
    await this.userRepo.save(user);
  }
}
