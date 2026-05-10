import 'package:flutter/cupertino.dart';
import 'package:aramisc/app/utilities/app_functions/functionality.dart';
import 'package:aramisc/app/utilities/widgets/loader/loading.controller.dart';
import 'package:aramisc/config/global_variable/app_settings_controller.dart';
import 'package:aramisc/config/global_variable/global_variable_controller.dart';
import 'package:aramisc/domain/core/model/profile_ui_model.dart';
import 'package:aramisc/push_notification/app_push_notification.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../domain/base_client/base_client.dart';
import '../../../utilities/widgets/no_internet/internet_controller.dart';
import '../../../database/auth_database.dart';
import '../../../utilities/api_urls.dart';
import '../../../utilities/message/snack_bars.dart';

class LoginController extends GetxController {
  GlobalRxVariableController globalRxVariableController =
  Get.find<GlobalRxVariableController>();

  RxBool isLoading = false.obs;
  RxBool isObscureText = true.obs;

  LoadingController loadingController = Get.find();
  InternetController internetController = Get.find();

  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  final GetStorage _box = GetStorage();

  /// Abonne l'utilisateur aux topics Firebase selon son rôle
  Future<void> _subscribeToRoleTopics(int roleId) async {
    await subscribeToTopic('all_users'); // tous les utilisateurs

    switch (roleId) {
      case 1:
        await subscribeToTopic('admins');
        break;
      case 2:
        await subscribeToTopic('students');
        break;
      case 3:
        await subscribeToTopic('parents');
        break;
      case 4:
        await subscribeToTopic('teachers');
        break;
    }
  }

  void userLogin({required String email, required String password}) async {
    ProfileInfoModel profileInfoModel;

    try {
      isLoading.value = true;
      final res = await BaseClient().postData(
        url: AramiscApi.login(),
        header: {'Content-Type': 'application/json'},
        payload: {"email": email, "password": password},
      );

      profileInfoModel = ProfileInfoModel.fromJson(res);
      if (profileInfoModel.success == true) {
        isLoading.value = false;
        _box.write('password', password);
        globalRxVariableController.notificationCount.value =
            profileInfoModel.data.unreadNotifications;
        globalRxVariableController.token.value =
            profileInfoModel.data.accessToken;
        globalRxVariableController.roleId.value =
            profileInfoModel.data.user.roleId;
        globalRxVariableController.userId.value = profileInfoModel.data.user.id;
        globalRxVariableController.email.value =
            profileInfoModel.data.user.email;
        globalRxVariableController.fullName.value =
            profileInfoModel.data.user.fullName;

        showBasicSuccessSnackBar(message: profileInfoModel.message);
        bool status = await AuthDatabase.instance.saveAuthInfo(
          profileInfoModelModel: profileInfoModel,
        );

        GlobalVariable.header = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': Get.find<GlobalRxVariableController>().token.value!,
        };

        final roleId = profileInfoModel.data.user.roleId;

        if (roleId == 2) {
          globalRxVariableController.studentId.value =
              profileInfoModel.data.user.studentId;
          globalRxVariableController.roleName.value = 'Student';
          globalRxVariableController.isStudent.value = true;
          debugPrint('Student Id ::: ${globalRxVariableController.studentId}');
        }

        if (roleId == 1 || roleId == 4) {
          globalRxVariableController.staffId.value =
              profileInfoModel.data.user.staffId;
          roleId == 1
              ? globalRxVariableController.roleName.value = 'Admin'
              : globalRxVariableController.roleName.value = 'Teacher';
          debugPrint(
              'Admin/Teacher Id ::: ${globalRxVariableController.staffId}');
        }

        if (roleId == 3) {
          globalRxVariableController.parentId.value =
              profileInfoModel.data.user.parentId;
          globalRxVariableController.roleName.value = 'Parent';
          debugPrint('Parent Id ::: ${globalRxVariableController.parentId}');
        }

        // Abonnement aux topics Firebase selon le rôle
        await _subscribeToRoleTopics(roleId);

        // Envoyer le FCM token au backend
        final fcmToken = await getFcmDeviceToken();
        if (fcmToken.isNotEmpty) {
          // TODO: envoyer fcmToken à votre API backend
          // await BaseClient().postData(
          //   url: AramiscApi.updateFcmToken(),
          //   header: GlobalVariable.header,
          //   payload: {"fcm_token": fcmToken},
          // );
          debugPrint('FCM Token envoyé au backend: $fcmToken');
        }

        if (status) {
          AppFunctions().getFunctions(roleId);
        }
        Get.find<AppSettingsController>().getGeneralSettings();
      } else {
        isLoading.value = false;
        showBasicFailedSnackBar(message: profileInfoModel.message);
      }
    } catch (e, t) {
      isLoading.value = false;
      debugPrint('$e');
      debugPrint('$t');
    } finally {
      isLoading.value = false;
    }
  }

  void demoUserLogin({required int role}) async {
    ProfileInfoModel profileInfoModel;
    try {
      isLoading.value = true;
      final response = await BaseClient().getData(
        url: AramiscApi.demoLogin(role.toString()),
        header: {'Content-Type': 'application/json'},
      );

      profileInfoModel = ProfileInfoModel.fromJson(response);
      if (profileInfoModel.success == true) {
        isLoading.value = false;
        globalRxVariableController.notificationCount.value =
            profileInfoModel.data.unreadNotifications;
        globalRxVariableController.token.value =
            profileInfoModel.data.accessToken;
        globalRxVariableController.roleId.value =
            profileInfoModel.data.user.roleId;
        globalRxVariableController.userId.value = profileInfoModel.data.user.id;
        globalRxVariableController.email.value =
            profileInfoModel.data.user.email;
        globalRxVariableController.fullName.value =
            profileInfoModel.data.user.fullName;

        showBasicSuccessSnackBar(message: profileInfoModel.message);
        bool status = await AuthDatabase.instance.saveAuthInfo(
          profileInfoModelModel: profileInfoModel,
        );

        GlobalVariable.header = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': Get.find<GlobalRxVariableController>().token.value!,
        };

        final roleId = profileInfoModel.data.user.roleId;

        if (roleId == 2) {
          globalRxVariableController.studentId.value =
              profileInfoModel.data.user.studentId;
          globalRxVariableController.isStudent.value = true;
          globalRxVariableController.roleName.value = 'Student';
          debugPrint('Student Id ::: ${globalRxVariableController.studentId}');
        }

        if (roleId == 1 || roleId == 4) {
          globalRxVariableController.staffId.value =
              profileInfoModel.data.user.staffId;
          debugPrint(
              'Admin/Teacher Id ::: ${globalRxVariableController.staffId}');
          roleId == 1
              ? globalRxVariableController.roleName.value = 'Admin'
              : globalRxVariableController.roleName.value = 'Teacher';
        }

        if (roleId == 3) {
          globalRxVariableController.parentId.value =
              profileInfoModel.data.user.parentId;
          debugPrint('Parent Id ::: ${globalRxVariableController.parentId}');
          globalRxVariableController.roleName.value = 'Parent';
        }

        // Abonnement aux topics Firebase selon le rôle
        await _subscribeToRoleTopics(roleId);

        if (status) {
          AppFunctions().getFunctions(roleId);
        }
        Get.find<AppSettingsController>().getGeneralSettings();
      } else {
        isLoading.value = false;
        showBasicFailedSnackBar(message: profileInfoModel.message);
      }
    } catch (e, t) {
      debugPrint('$e');
      debugPrint('$t');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    internetConnectionChecker();
    super.onInit();
  }
}