import { cva } from 'class-variance-authority';

export const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-xl font-medium transition-all focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-indigo-600 text-white hover:bg-indigo-500 shadow-lg shadow-indigo-600/30',
        outline: 'border border-neutral-700 bg-transparent text-neutral-200 hover:bg-neutral-800',
        ghost: 'text-neutral-300 hover:bg-neutral-800/60',
      },
      size: {
        sm: 'h-9 px-3 text-xs',
        md: 'h-11 px-5 text-sm',
        lg: 'h-13 px-7 text-base',
      },
    },
    defaultVariants: { variant: 'primary', size: 'md' },
  }
);
