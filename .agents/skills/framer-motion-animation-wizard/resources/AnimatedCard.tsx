import { motion } from 'framer-motion';

export function AnimatedCard({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      whileHover={{ y: -4, scale: 1.02 }}
      transition={{ type: 'spring', stiffness: 350, damping: 25 }}
      className="rounded-2xl border border-white/10 bg-neutral-900/80 p-6 backdrop-blur-xl shadow-2xl"
    >
      <h3 className="text-xl font-bold text-white mb-2">{title}</h3>
      {children}
    </motion.div>
  );
}
