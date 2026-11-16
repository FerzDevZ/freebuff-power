// Production Kafka Producer with Idempotence (KafkaJS in TypeScript)
import { Kafka, Partitioners } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'order-service',
  brokers: ['kafka-1:9092', 'kafka-2:9092'],
});

export const producer = kafka.producer({
  createPartitioner: Partitioners.DefaultPartitioner,
  idempotent: true,
  maxInFlightRequests: 5,
});

export async function publishOrderEvent(orderId: string, eventType: string, payload: Record<string, any>) {
  await producer.send({
    topic: 'orders.v1',
    messages: [
      {
        key: orderId,
        value: JSON.stringify(payload),
        headers: { 'event-type': eventType },
      },
    ],
  });
}
