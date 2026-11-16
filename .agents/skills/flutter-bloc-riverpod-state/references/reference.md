# Flutter State Management: BLoC vs Riverpod 2.0+ Reference

## 1. BLoC Pattern Best Practices
- **Events**: Define distinct events as Freezed unions (e.g. `UserEvent.fetchStarted`, `UserEvent.searchQueryChanged(String query)`).
- **Transformer**: Apply debouncing to search queries using `rxdart` event transformers:
  ```dart
  on<SearchQueryChanged>(
    _onSearchQueryChanged,
    transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 300)).switchMap(mapper),
  );
  ```
- **BlocObserver**: Implement global error tracking and event transitions:
  ```dart
  class AppBlocObserver extends BlocObserver {
    @override
    void onChange(BlocBase bloc, Change change) {
      super.onChange(bloc, change);
      // Log state transition
    }
  }
  ```

## 2. Riverpod 2.0+ Notifier Guide
- **Code-gen**: Use `@riverpod` annotations to generate type-safe autoDispose providers.
- **AsyncValue Handling**: Seamlessly render states using pattern matching:
  ```dart
  final state = ref.watch(userListNotifierProvider);
  return state.when(
    data: (users) => ListView.builder(...),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => ErrorWidget(err),
  );
  ```
