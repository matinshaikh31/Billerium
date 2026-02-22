import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/settings/domain/entity/setting_model.dart';
import 'package:billing_software/features/settings/domain/repo/setting_repository.dart';

class FirebaseSettingRepository implements SettingRepository {
  final settingDocRef = FBFireStore.settings;

  @override
  Future<SettingModel?> fetchSettings() async {
    try {
      final doc = await settingDocRef.get();

      if (!doc.exists) {
        // If settings don't exist, create default settings
        final defaultSettings = SettingModel(CGST: 9, SGST: 9);
        await settingDocRef.set(defaultSettings.toJson());
        return defaultSettings;
      }

      return SettingModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch settings: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSettings(SettingModel settings) async {
    try {
      await settingDocRef.set(settings.toJson());
    } catch (e) {
      throw Exception('Failed to update settings: ${e.toString()}');
    }
  }

  @override
  Stream<SettingModel?> watchSettings() {
    return settingDocRef.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return SettingModel(CGST: 9, SGST: 9);
      }
      return SettingModel.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }
}
