// Animated Tabs with layoutId
import * as React from 'react';
import { motion } from 'framer-motion';

export function SegmentedTabs({ tabs }: { tabs: string[] }) {
  const [selected, setSelected] = React.useState(tabs[0]);

  return (
    <div className="flex gap-2 p-1 bg-muted rounded-lg">
      {tabs.map((tab) => {
        const isActive = selected === tab;
        return (
          <button
            key={tab}
            onClick={() => setSelected(tab)}
            className="relative px-4 py-2 text-sm font-medium transition-colors"
          >
            {isActive && (
              <motion.div
                layoutId="active-pill"
                className="absolute inset-0 bg-background rounded-md shadow-sm"
                transition={{ type: 'spring', stiffness: 400, damping: 30 }}
              />
            )}
            <span className="relative z-10">{tab}</span>
          </button>
        );
      })}
    </div>
  );
}
