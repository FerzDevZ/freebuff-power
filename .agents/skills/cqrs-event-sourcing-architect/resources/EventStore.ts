export interface DomainEvent<T = any> {
  eventId: string;
  aggregateId: string;
  eventType: string;
  timestamp: number;
  payload: T;
}
