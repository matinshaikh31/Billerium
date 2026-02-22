import 'package:billing_software/features/settings/domain/entity/setting_model.dart';

abstract class SettingRepository {
  /// Fetch settings from Firebase
  Future<SettingModel?> fetchSettings();
  
  /// Update settings in Firebase
  Future<void> updateSettings(SettingModel settings);
  
  /// Stream settings changes
  Stream<SettingModel?> watchSettings();
}

