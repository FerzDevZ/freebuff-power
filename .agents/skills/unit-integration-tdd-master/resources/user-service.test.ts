import { describe, it, expect, vi } from 'vitest';

// System Under Test (SUT)
class UserService {
  constructor(private readonly repo: { findById: (id: string) => Promise<any> }) {}

  async getUserDisplayName(id: string): Promise<string> {
    const user = await this.repo.findById(id);
    if (!user) throw new Error('UserNotFound');
    return `${user.firstName} ${user.lastName}`.trim();
  }
}

describe('UserService', () => {
  it('should return full name when user exists', async () => {
    // Arrange (Stub)
    const fakeRepo = {
      findById: vi.fn().mockResolvedValue({ firstName: 'John', lastName: 'Doe' }),
    };
    const sut = new UserService(fakeRepo);

    // Act
    const result = await sut.getUserDisplayName('usr_1');

    // Assert
    expect(result).toBe('John Doe');
    expect(fakeRepo.findById).toHaveBeenCalledWith('usr_1');
  });

  it('should throw UserNotFound when user does not exist', async () => {
    const fakeRepo = { findById: vi.fn().mockResolvedValue(null) };
    const sut = new UserService(fakeRepo);

    await expect(sut.getUserDisplayName('usr_999')).rejects.toThrow('UserNotFound');
  });
});
