import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AppState {
  theme: 'dark' | 'light';
  setTheme: (t: 'dark' | 'light') => void;
}

export const useAppStore = create<AppState>()(
  persist(
    (set) => ({ theme: 'dark', setTheme: (theme) => set({ theme }) }),
    { name: 'app-storage' }
  )
);
