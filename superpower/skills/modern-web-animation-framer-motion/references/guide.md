# Spring Physics & Reduced Motion Reference

```typescript
import { motion, useReducedMotion } from 'framer-motion';

export function AnimatedCard({ children }: { children: React.ReactNode }) {
  const shouldReduceMotion = useReducedMotion();

  const transition = shouldReduceMotion
    ? { duration: 0 }
    : { type: 'spring', stiffness: 300, damping: 25 };

  return (
    <motion.div
      initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: shouldReduceMotion ? 0 : -20 }}
      transition={transition}
      className="p-6 rounded-xl bg-card border shadow-sm"
    >
      {children}
    </motion.div>
  );
}
```
