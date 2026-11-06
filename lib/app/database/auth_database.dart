import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:aramisc/config/global_variable/global_variable_controller.dart';
import 'package:aramisc/config/language/controller/language_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/core/model/profile_ui_model.dart';
import '../../push_notification/app_push_notification.dart';

class AuthDatabase {
  static AuthDatabase? _instance;

  AuthDatabase._() {
    _instance = this;
  }

  static AuthDatabase get instance => _instance ?? AuthDatabase._();

  void init() async {
    await GetStorage.init(AuthDBKeys.dbName);
  }

  static const _secureStorage = FlutterSecureStorage();
  static const _passwordKey = 'password';

  /// Mot de passe gardé pour la connexion automatique de la classe virtuelle (stockage chiffré).
  Future<void> savePassword(String password) async {
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  /// Reprend aussi le mot de passe en clair laissé par les anciennes versions, puis l'efface.
  Future<String?> getPassword() async {
    final box = GetStorage();
    final String? legacyPassword = box.read(_passwordKey);
    if (legacyPassword != null) {
      await savePassword(legacyPassword);
      await box.remove(_passwordKey);
    }
    return _secureStorage.read(key: _passwordKey);
  }

  Future<bool> saveAuthInfo({
    required ProfileInfoModel profileInfoModelModel,
    // String? token,
  }) async {
    try {
      final storage = GetStorage(AuthDBKeys.dbName);
      await storage.write(AuthDBKeys.data, jsonEncode(profileInfoModelModel));
      if (profileInfoModelModel.data.accessToken != '') {
        await storage.write(
            AuthDBKeys.token, profileInfoModelModel.data.accessToken);
        await storage.write(AuthDBKeys.notificationCount,
            profileInfoModelModel.data.unreadNotifications);
      }
      await storage.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveUnReadNotification({
    required int unReadNotification,
  }) async {
    try {
      final storage = GetStorage(AuthDBKeys.dbName);
      await storage.write(AuthDBKeys.notificationCount, unReadNotification);
      await storage.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  int? getUnReadNotification() {
    try {
      final storage = GetStorage(AuthDBKeys.dbName);
      debugPrint(
          'Your Notification is:::: ${storage.read(AuthDBKeys.notificationCount)}');
      return storage.read(AuthDBKeys.notificationCount);
    } catch (e) {
      rethrow;
    }
  }

  ProfileInfoModel? getUserInfo() {
    try {
      final storage = GetStorage(AuthDBKeys.dbName);
      var data = storage.read(AuthDBKeys.data);
      if (data != null) {
        return ProfileInfoModel.fromJson(jsonDecode(data));
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  String? getToken() {
    try {
      final storage = GetStorage(AuthDBKeys.dbName);
      // debugPrint('Your token is:::: ${storage.read(AuthDBKeys.token)}');
      return storage.read(AuthDBKeys.token);
    } catch (e) {
      rethrow;
    }
  }

  bool auth() {
    try {
      final storage = GetStorage(AuthDBKeys.dbName);
      log('Your token is:::: ${storage.read(AuthDBKeys.token)}');
      if (storage.read(AuthDBKeys.token) == null) return false;
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logOut() async {
    GlobalRxVariableController globalRxVariableController = Get.find();
    try {
      final storage = GetStorage(AuthDBKeys.dbName);
      await storage.remove(AuthDBKeys.data);
      await storage.remove(AuthDBKeys.token);
      await storage.save();
      await GetStorage().remove(_passwordKey);
      await _secureStorage.delete(key: _passwordKey);

      // Sans attendre : hors ligne, le désabonnement ne doit pas bloquer la déconnexion.
      unawaited(unsubscribeFromAllTopics());

      globalRxVariableController.token.value = null;
      globalRxVariableController.userId.value = null;
      globalRxVariableController.roleId.value = null;

      globalRxVariableController.notificationCount.value = null;
      globalRxVariableController.studentRecordId.value = null;
      globalRxVariableController.email.value = null;
      globalRxVariableController.studentId.value = null;
      globalRxVariableController.parentId.value = null;
      globalRxVariableController.staffId.value = null;
      globalRxVariableController.isStudent.value = false;
      globalRxVariableController.isRtl.value = false;

      // L'application est en français : la déconnexion ne doit pas repasser l'interface en anglais.
      final sharedPref = await SharedPreferences.getInstance();
      Get.find<LanguageController>().langName.value = 'Français';
      language = 'fr';

      Get.find<LanguageController>().appLocale = 'fr';
      Get.find<LanguageController>().langCode = 'fr';
      Get.updateLocale(
          Locale(Get.find<LanguageController>().appLocale.toString()));
      sharedPref.clear();

      return true;
    } catch (e) {
      return false;
    }
  }
}

class AuthDBKeys {
  static const dbName = 'authDb';
  static const data = 'userInfo';
  static const token = 'token';
  static const notificationCount = 'notification_count';
}
