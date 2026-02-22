part of 'setting_cubit.dart';

class SettingState extends Equatable {
  final SettingModel? settings;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const SettingState({
    this.settings,
    required this.isLoading,
    this.error,
    this.successMessage,
  });

  factory SettingState.initial() {
    return const SettingState(
      settings: null,
      isLoading: false,
      error: null,
      successMessage: null,
    );
  }

  SettingState copyWith({
    SettingModel? settings,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return SettingState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: clearMessages ? null : (error ?? this.error),
      successMessage: clearMessages
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [settings, isLoading, error, successMessage];
}
