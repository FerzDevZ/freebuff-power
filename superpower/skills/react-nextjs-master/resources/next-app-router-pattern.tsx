// Production Next.js App Router Page with Streaming Suspense
import { Suspense } from 'react';

async function SlowDataComponent() {
  // Simulate database query
  await new Promise((res) => setTimeout(res, 500));
  return <div className="p-4 rounded-xl bg-zinc-800 text-white">Streamed Server Data Loaded</div>;
}

export default async function DashboardPage() {
  return (
    <main className="max-w-4xl mx-auto p-8 space-y-6">
      <h1 className="text-3xl font-bold tracking-tight text-white">Dashboard Overview</h1>
      <Suspense fallback={<div className="h-24 rounded-xl bg-zinc-800 animate-pulse" />}>
        <SlowDataComponent />
      </Suspense>
    </main>
  );
}
