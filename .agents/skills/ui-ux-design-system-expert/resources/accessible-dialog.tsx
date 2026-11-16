// Production Accessible Dialog Primitive (Radix UI + Tailwind)
import * as React from 'react';
import * as DialogPrimitive from '@radix-ui/react-dialog';

export function AccessibleModal({
  isOpen,
  onClose,
  title,
  description,
  children,
}: {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  description: string;
  children: React.ReactNode;
}) {
  return (
    <DialogPrimitive.Root open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogPrimitive.Portal>
        {/* Overlay */}
        <DialogPrimitive.Overlay className="fixed inset-0 bg-black/60 backdrop-blur-sm transition-opacity duration-200 animate-in fade-in z-50" />
        
        {/* Dialog Content */}
        <DialogPrimitive.Content
          className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-lg rounded-2xl bg-zinc-900 border border-white/10 p-6 shadow-2xl z-50 animate-in zoom-in-95 focus:outline-none"
          aria-describedby="dialog-desc"
        >
          <DialogPrimitive.Title className="text-xl font-bold text-white tracking-tight">
            {title}
          </DialogPrimitive.Title>
          
          <DialogPrimitive.Description id="dialog-desc" className="text-sm text-zinc-400 mt-2 mb-6">
            {description}
          </DialogPrimitive.Description>

          <div className="mt-4">{children}</div>

          <DialogPrimitive.Close
            className="absolute top-4 right-4 text-zinc-400 hover:text-white rounded-lg p-1.5 focus-visible:ring-2 focus-visible:ring-indigo-500 focus:outline-none"
            aria-label="Close dialog"
          >
            ✕
          </DialogPrimitive.Close>
        </DialogPrimitive.Content>
      </DialogPrimitive.Portal>
    </DialogPrimitive.Root>
  );
}
