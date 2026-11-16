import webpush from 'web-push';

export async function sendPushNotification(subscription: webpush.PushSubscription, payload: string) {
  await webpush.sendNotification(subscription, payload);
}
