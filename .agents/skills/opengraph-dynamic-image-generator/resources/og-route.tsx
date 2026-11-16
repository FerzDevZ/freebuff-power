import { ImageResponse } from 'next/og';

export const runtime = 'edge';

export async function GET(request: Request) {
  return new ImageResponse(
    (
      <div style={{ display: 'flex', width: '100%', height: '100%', background: '#09090b', color: 'white', alignItems: 'center', justifyContent: 'center' }}>
        <h1 style={{ fontSize: 64, fontWeight: 800 }}>⚡ Ferz Superpower Skills</h1>
      </div>
    ),
    { width: 1200, height: 630 }
  );
}
