import 'package:billing_software/features/settings/domain/entity/setting_model.dart';
import 'package:billing_software/features/settings/domain/repo/setting_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final SettingRepository settingRepository;
  final TextEditingController cgstController = TextEditingController();
  final TextEditingController sgstController = TextEditingController();

  SettingCubit({required this.settingRepository})
    : super(SettingState.initial());

  @override
  Future<void> close() {
    cgstController.dispose();
    sgstController.dispose();
    return super.close();
  }

  /// Fetch settings from Firebase
  Future<void> fetchSettings() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final settings = await settingRepository.fetchSettings();

      if (settings != null) {
        // Update controllers with fetched values
        cgstController.text = settings.CGST.toString();
        sgstController.text = settings.SGST.toString();

        emit(
          state.copyWith(
            settings: settings,
            isLoading: false,
            // successMessage: 'Settings loaded successfully',
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, error: 'No settings found'));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to fetch settings: ${e.toString()}',
        ),
      );
    }
  }

  /// Update settings in Firebase
  Future<void> updateSettings() async {
    try {
      emit(state.copyWith(isLoading: true, error: null, successMessage: null));

      // Parse values from controllers
      final cgst = int.tryParse(cgstController.text.trim()) ?? 0;
      final sgst = int.tryParse(sgstController.text.trim()) ?? 0;

      // Validate
      if (cgst < 0 || cgst > 100) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'CGST must be between 0 and 100',
          ),
        );
        return;
      }

      if (sgst < 0 || sgst > 100) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'SGST must be between 0 and 100',
          ),
        );
        return;
      }

      final newSettings = SettingModel(CGST: cgst, SGST: sgst);

      await settingRepository.updateSettings(newSettings);

      emit(
        state.copyWith(
          settings: newSettings,
          isLoading: false,
          successMessage: 'Settings updated successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update settings: ${e.toString()}',
        ),
      );
    }
  }

  /// Watch settings changes in real-time
  void watchSettings() {
    settingRepository.watchSettings().listen(
      (settings) {
        if (settings != null) {
          cgstController.text = settings.CGST.toString();
          sgstController.text = settings.SGST.toString();
          emit(state.copyWith(settings: settings));
        }
      },
      onError: (error) {
        emit(
          state.copyWith(error: 'Error watching settings: ${error.toString()}'),
        );
      },
    );
  }

  /// Clear success/error messages
  void clearMessages() {
    emit(
      state.copyWith(successMessage: null, error: null, clearMessages: true),
    );
  }
}
