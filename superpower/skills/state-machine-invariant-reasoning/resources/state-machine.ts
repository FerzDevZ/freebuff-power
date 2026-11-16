type OrderState = 
  | { status: 'PENDING' }
  | { status: 'PAID'; transactionId: string }
  | { status: 'SHIPPED'; trackingNumber: string; shippedAt: Date }
  | { status: 'CANCELLED'; reason: string };
