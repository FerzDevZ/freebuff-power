// BLoC & Freezed Standard Template
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_bloc.freezed.dart';

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent.fetchRequested() = _FetchRequested;
  const factory UserEvent.refreshTriggered() = _RefreshTriggered;
}

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.success(List<String> items) = _Success;
  const factory UserState.failure(String message) = _Failure;
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState.initial()) {
    on<_FetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    _FetchRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.loading());
    try {
      // Fetch logic
      emit(const UserState.success([]));
    } catch (e) {
      emit(UserState.failure(e.toString()));
    }
  }
}
