// Optimistic Mutation Template with TanStack Query v5
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { userKeys } from './userKeys';

interface Todo {
  id: string;
  title: string;
}

export function useAddTodo() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (newTodo: { title: string }) => {
      const res = await fetch('/api/todos', {
        method: 'POST',
        body: JSON.stringify(newTodo),
      });
      return res.json();
    },
    onMutate: async (newTodo) => {
      await queryClient.cancelQueries({ queryKey: ['todos'] });
      const previousTodos = queryClient.getQueryData<Todo[]>(['todos']);

      queryClient.setQueryData<Todo[]>(['todos'], (old = []) => [
        ...old,
        { id: 'temp-' + Date.now(), title: newTodo.title },
      ]);

      return { previousTodos };
    },
    onError: (err, newTodo, context) => {
      if (context?.previousTodos) {
        queryClient.setQueryData(['todos'], context.previousTodos);
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] });
    },
  });
}
