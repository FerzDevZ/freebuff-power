import { Command } from 'cmdk';

export function CommandPalette({ open, setOpen }: { open: boolean; setOpen: (v: boolean) => void }) {
  return (
    <Command.Dialog open={open} onOpenChange={setOpen} className="fixed inset-0 z-50 bg-black/60 backdrop-blur-md p-4">
      <Command.Input placeholder="Type a command or search..." className="w-full bg-neutral-900 text-white p-3 rounded-xl" />
      <Command.List className="mt-2 text-neutral-300">
        <Command.Item onSelect={() => console.log('New Project')}>📁 Create New Project</Command.Item>
      </Command.List>
    </Command.Dialog>
  );
}
