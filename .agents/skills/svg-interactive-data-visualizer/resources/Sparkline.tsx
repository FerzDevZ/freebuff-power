export function Sparkline({ points }: { points: number[] }) {
  const path = points.map((p, i) => `${i === 0 ? 'M' : 'L'} ${i * 30} ${100 - p}`).join(' ');
  return (
    <svg viewBox="0 0 300 100" className="w-full h-24 overflow-visible">
      <path d={path} fill="none" stroke="#10b981" strokeWidth="3" strokeLinecap="round" />
    </svg>
  );
}
