// Production Temporal Workflow Definition (TypeScript SDK)
import { proxyActivities, sleep } from '@temporalio/workflow';
import type * as activities from './activities';

const { reserveInventory, releaseInventory, chargePayment } = proxyActivities<typeof activities>({
  startToCloseTimeout: '1 minute',
  retry: {
    maximumAttempts: 5,
    initialInterval: '1s',
    backoffCoefficient: 2,
  },
});

export async function orderFulfillmentWorkflow(orderId: string, amount: number): Promise<void> {
  await reserveInventory(orderId);

  try {
    await chargePayment(orderId, amount);
  } catch (err) {
    // Saga compensation rollback
    await releaseInventory(orderId);
    throw err;
  }
}
