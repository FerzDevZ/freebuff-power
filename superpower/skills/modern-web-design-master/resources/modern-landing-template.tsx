import React from 'react';

export default function ModernHero() {
  return (
    <section className="relative min-h-[90vh] flex items-center justify-center bg-black text-white px-6 overflow-hidden">
      {/* Background Radial Glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-indigo-600/20 blur-[140px] rounded-full pointer-events-none" />

      <div className="relative z-10 max-w-4xl text-center flex flex-col items-center">
        {/* Modern Pill Badge */}
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/5 border border-white/10 text-xs font-medium text-indigo-300 backdrop-blur-md mb-6 hover:bg-white/10 transition-colors">
          <span className="w-2 h-2 rounded-full bg-indigo-400 animate-pulse" />
          <span>Ferz All-Skills Suite v1.0 Released</span>
        </div>

        <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-b from-white via-white/90 to-zinc-500 leading-tight mb-6">
          Architecting Intelligence at Production Scale
        </h1>

        <p className="text-lg md:text-xl text-zinc-400 max-w-2xl mb-10 leading-relaxed">
          Modular, production-grade agent skills and runbooks designed for high-performance software engineering teams.
        </p>

        <div className="flex flex-col sm:flex-row items-center gap-4">
          <button className="w-full sm:w-auto px-8 py-3.5 rounded-xl bg-white text-black font-semibold hover:bg-zinc-200 transition-all hover:scale-105 active:scale-95 shadow-xl shadow-white/10">
            Explore Skills
          </button>
          <button className="w-full sm:w-auto px-8 py-3.5 rounded-xl bg-zinc-900 border border-white/10 text-white font-medium hover:bg-zinc-800 transition-all">
            Read Documentation
          </button>
        </div>
      </div>
    </section>
  );
}
