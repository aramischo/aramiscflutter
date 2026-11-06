import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AppColors {
  /// Couleurs de marque réglables depuis le back-office (Réglages généraux),
  /// reçues avec language-list / general-settings et mémorisées pour le démarrage suivant.
  static const _storageKey = 'mobile_colors';

  static Color primaryColor               = const Color(0xFF862CFF);
  static Color secondaryColor             = const Color(0xFFB844D1);
  static Color appBackgroundColor         = const Color(0xFF6100B8);
  static Color appButtonColor             = const Color(0xFF953BE4);
  static Color lessonButtonColor          = const Color(0xFF862CFF);
  static Color backgroundPrimaryColor     = const Color(0xFF6100B8);
  static Color backgroundSecondaryColor   = const Color(0xFF943AE3);
  static Color homeTextColor              = const Color(0xFF943AE3);
  static Color parentsIconCardBackgroundColor = const Color(0xFF953BE4);
  static Color profileIndicatorColor      = const Color(0xFFB844D1);

  /// Couleurs mémorisées lors du dernier lancement (à appeler avant runApp)
  static void loadSaved() {
    try {
      final saved = GetStorage().read(_storageKey);
      if (saved is Map) _apply(Map<String, dynamic>.from(saved));
    } catch (_) {}
  }

  /// Applique les couleurs reçues du serveur. Retourne true si quelque chose a changé.
  static bool applyFromServer(dynamic colors) {
    if (colors is! Map) return false;
    final map = Map<String, dynamic>.from(colors);
    final changed = _apply(map);
    if (changed) {
      try {
        GetStorage().write(_storageKey, map);
      } catch (_) {}
    }
    return changed;
  }

  static bool _apply(Map<String, dynamic> map) {
    final before = [primaryColor, secondaryColor, appBackgroundColor, backgroundSecondaryColor, appButtonColor];
    final primary = _parse(map['primary']);
    final secondary = _parse(map['secondary']);
    final headerStart = _parse(map['header_start']);
    final headerEnd = _parse(map['header_end']);
    final button = _parse(map['button']);
    if (primary != null) {
      primaryColor = primary;
      lessonButtonColor = primary;
    }
    if (secondary != null) {
      secondaryColor = secondary;
      profileIndicatorColor = secondary;
    }
    if (headerStart != null) {
      appBackgroundColor = headerStart;
      backgroundPrimaryColor = headerStart;
    }
    if (headerEnd != null) {
      backgroundSecondaryColor = headerEnd;
      homeTextColor = headerEnd;
    }
    if (button != null) {
      appButtonColor = button;
      parentsIconCardBackgroundColor = button;
    }
    final after = [primaryColor, secondaryColor, appBackgroundColor, backgroundSecondaryColor, appButtonColor];
    for (var i = 0; i < before.length; i++) {
      if (before[i] != after[i]) return true;
    }
    return false;
  }

  /// "#RRGGBB" -> Color
  static Color? _parse(dynamic hex) {
    if (hex is! String) return null;
    final value = hex.replaceFirst('#', '');
    if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(value)) return null;
    return Color(int.parse('FF$value', radix: 16));
  }

  static const loginIconColor             = Color(0xFFA6ABCE);
  static const pinkColor                  = Color(0xFFEBDAF9);
  static const lightPinkColor             = Color(0xFFFDFBFF);
  static const cardColor                  = Color(0x4CF4EBFC);
  static const boxBorderColor             = Color(0x4C67329B);
  static const dividerColor               = Color(0xFFEBD8FC);
  static const hintTextColor              = Color(0xFF635976);
  static const smallCardColor             = Color(0xFFF4EBFC);
  static const appColorB5C1CB             = Color(0xFFB6B6B6);
  static const appColor324844             = Color(0xFF324844);
  static const textColor635976            = Color(0xFF635976);
  static const borderColorEAE7F0          = Color(0xFFEAE7F0);

 /// Text Colors
  static const homeIconBackgroundColor = Color(0xFFF4EBFC);


  /// Home Colors
  static const dividerColorSelected = Color(0xFFEBD8FC);

  /// Profile Colors
  static const profileTopContainerColor = Color(0xFFF4EBFC);
  static const parentsCardBorderColor = Color(0xFFF2F0F6);
  static const parentsDesignationColor = Color(0xFFF2F0F6);
  static const profileTitleColor = Color(0xFF635976);
  static const profileValueColor = Color(0xFF412C56);
  static Color profileDividerColor = const Color(0xFF635976).withOpacity(0.2);
  static const profilePicBackgroundColor = Color(0xFF556080);
  static const profileCardBackgroundColor = Color(0xFF412C56);
  static const profileCardTextColor = Color(0xFFF2F0F6);
  static const editProfileTextFieldLabelColor = Color(0xFF8489AB);

  /// Syllabus
  static const syllabusTextColorBlack = Color(0xFF412C56);
  static const syllabusTextColor635976 = Color(0xFF635976);



  /// Notification Color
  static const notificationColor = Color(0xFFED00FF);

  ///others

  static const homeworkSubjectColor = Color(0xFF373F6B);
  static const homeworkViewColor = Color(0xFF67329B);
  static const homeworkStatusRedColor = Color(0xFFF95452);
  static const homeworkStatusGreenColor = Color(0xFF06A83C);
  static const homeworkWidgetColor = Color(0xFFF2F0F6);
  static const homeworkColor = Color(0xFFF2F0F7);
  static const activeExamStatusBlueColor = Color(0xFF404FB6);
  static const customDividerColor = Color(0xFFE5E4EA);
  static const teacherTextColor = Color(0xFF646988);
  static const disabledColor = Color(0xFFF3F3F3);
  static const transportDividerColor = Color(0xFFEAE7F0);
  static Color bottomSheetDividerColor = const Color(0xFF635976).withOpacity(0.1);
  static const activeStatusGreenColor = Color(0xFF3AC172);
  static const bankPaymentStatusGreenColor = Color(0xFF23C85A);
  static const bankPaymentStatusRedColor = Color(0xFFED3B3B);
  static const activeStatusRedColor = Color(0xFFE3342F);
  static const activeStatusYellowColor = Color(0xFFFFBE00);
  static const unreadChat = Color(0xFF8124D3);








}