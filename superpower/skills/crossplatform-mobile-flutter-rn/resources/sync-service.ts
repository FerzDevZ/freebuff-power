// Offline Mutation Queue with Retry Mechanism (TypeScript)
export interface OfflineMutation {
  id: string;
  endpoint: string;
  method: 'POST' | 'PUT' | 'DELETE';
  payload: Record<string, any>;
  createdAt: number;
  retryCount: number;
}

export class OfflineSyncService {
  private queue: OfflineMutation[] = [];

  async enqueue(mutation: Omit<OfflineMutation, 'id' | 'createdAt' | 'retryCount'>): Promise<void> {
    const item: OfflineMutation = {
      ...mutation,
      id: `mut_${Date.now()}_${Math.random().toString(36).substring(7)}`,
      createdAt: Date.now(),
      retryCount: 0,
    };
    this.queue.push(item);
    await this.persistQueue();
  }

  private async persistQueue(): Promise<void> {
    // Save to local storage (AsyncStorage / SecureStore)
  }
}
