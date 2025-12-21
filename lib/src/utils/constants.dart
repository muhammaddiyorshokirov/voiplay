import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4A148C);
  static const Color secondary = Color(0xFFD32F2F);
  static const Color accent = Color(0xFFFF5252);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  static const Color border = Color(0xFF424242);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);
}

class AppDimens {
  static const double paddingXXS = 4;
  static const double paddingXS = 8;
  static const double paddingS = 12;
  static const double paddingM = 16;
  static const double paddingL = 20;
  static const double paddingXL = 24;
  static const double paddingXXL = 32;

  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;

  static const double iconS = 16;
  static const double iconM = 24;
  static const double iconL = 32;
  static const double iconXL = 48;

  static const double textS = 12;
  static const double textM = 14;
  static const double textL = 16;
  static const double textXL = 18;
  static const double textXXL = 20;
  static const double text2XL = 24;
  static const double text3XL = 32;

  static const double appBarHeight = 56;
  static const double bottomNavHeight = 60;
}

class AppStrings {
  static const String appName = 'VoiPlay Tv';

  static const String asosiy = 'Asosiy';
  static const String animelar = 'Animelar';
  static const String saqlangan = 'Saqlangan';
  static const String profil = 'Profil';
  static const String qidirish = 'Qidirish';
  static const String animeQidirish = 'Animeni qidirish...';
  static const String oxirgi = 'Oxirgi';
  static const String yangi = 'Yangi';
  static const String mashhurkartm = 'Mashhur';
  static const String hamdaImtiyozli = 'Hamda Imtiyozli';
  static const String jarayondagi = 'Jarayondagi';
  static const String tugallangan = 'Tugallangan';
  static const String barcha = 'Barcha';
  static const String sortirovka = 'Sortirovka';
  static const String alifboyChiqish = 'A-Z';
  static const String chiqanSanasi = 'Chiqan sanasi';
  static const String janr = 'Janr';
  static const String korilgan = 'Ko\'rilgan';
  static const String qaytaKeladigan = 'Qayta keladigan';
  static const String premium = 'Premium';
  static const String bepul = 'Bepul';
  static const String tasnifi = 'Tasnifi';
  static const String tuzuvchi = 'Tuzuvchi';
  static const String til = 'Til';
  static const String holati = 'Holati';
  static const String reyting = 'Reyting';
  static const String korishlar = 'Ko\'rishlar';
  static const String episodlar = 'Episodlar';
  static const String izohlar = 'Izohlar';
  static const String mehnatingiz = 'Mehnati';
  static const String yoqmadi = 'Yoqmadi';
  static const String izoh = 'Izoh';
  static const String javob = 'Javob';
  static const String yuborish = 'Yuborish';
  static const String promoKod = 'Promo kod';
  static const String kodniKiritish = 'Kodni kiritish';
  static const String kodAqtivirovka = 'Kod aktivlashtirildi';
  static const String premiumBilet = 'Premium bilet';
  static const String aktivBilet = 'Aktivbogu';
  static const String muddati = 'Muddati';
  static const String premiumOlish = 'Premium olish';
  static const String tarix = 'Tarix';
  static const String tarihBoq = 'Tarix bo\'sh';
  static const String korilGan = 'Ko\'rilgan';
  static const String chiqish = 'Chiqish';
  static const String shunaqa = 'Shunaqa';
  static const String tugallandi = 'Tugallandi';
  static const String imtiyozli = 'Imtiyozli';
  static const String epizod = 'Epizod';
  static const String davomi = 'Davomi';
  static const String xatoluq = 'Xatoluq';
  static const String qayta = 'Qayta';
  static const String joriy = 'Joriy';
  static const String boqYangiAni = 'Bоq';
  static const String imtiyozBadeni = 'Imtiyoz ber';
  static const String buKoringMa = 'Bu ko\'ring ma';
  static const String fotoSini = 'Foto sinir';
  static const String asosiyOlish = 'Asosiy olish';
  static const String foydasini = 'Foydasini';
}

class AppConstants {
  static const String apiBaseUrl = 'https://api.voiplay.uz/api/v3';
  static const String deepLink = 'app.voiplay.uz';
  static const String packageName = 'uz.voiplay.tv';
  static const String defaultAvatarUrl = 'https://voiplay.uz/img/defoult.png';

  static const int animePerPage = 24;
  static const int heroCarouselMax = 10;
  static const int defaultTimeout = 30;
}

class AppStyles {
  static TextStyle headlineL = const TextStyle(
    fontSize: AppDimens.text3XL,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static TextStyle headlineM = const TextStyle(
    fontSize: AppDimens.text2XL,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static TextStyle headlineS = const TextStyle(
    fontSize: AppDimens.textXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static TextStyle titleL = const TextStyle(
    fontSize: AppDimens.textXL,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static TextStyle titleM = const TextStyle(
    fontSize: AppDimens.textL,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static TextStyle titleS = const TextStyle(
    fontSize: AppDimens.textM,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static TextStyle bodyL = const TextStyle(
    fontSize: AppDimens.textL,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle bodyM = const TextStyle(
    fontSize: AppDimens.textM,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle bodyS = const TextStyle(
    fontSize: AppDimens.textS,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle labelL = const TextStyle(
    fontSize: AppDimens.textM,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle labelM = const TextStyle(
    fontSize: AppDimens.textS,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.secondary);
        }
        return const IconThemeData(color: AppColors.textSecondary);
      }),
      labelTextStyle: WidgetStateProperty.all(AppStyles.labelM),
    ),
  );
}
