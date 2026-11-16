import { motion } from 'framer-motion';

export function BottomSheet({ isOpen, onClose, children }: any) {
  return (
    <motion.div
      drag="y"
      dragConstraints={{ top: 0 }}
      dragElastic={0.2}
      onDragEnd={(_, info) => { if (info.offset.y > 150) onClose(); }}
      className="fixed bottom-0 left-0 right-0 rounded-t-3xl bg-neutral-900 p-6 z-50 shadow-2xl"
    >
      <div className="mx-auto h-1.5 w-12 rounded-full bg-neutral-700 mb-4" />
      {children}
    </motion.div>
  );
}
