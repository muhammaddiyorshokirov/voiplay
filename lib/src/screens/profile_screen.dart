import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/api.dart';
import '../services/app_cache_manager.dart';
import '../utils/constants.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _promoCodeController = TextEditingController();
  List<String> watchHistoryIds = [];
  List<String> watchHistory = []; // display labels
  List<dynamic> devices = [];
  bool isLoading = true;
  bool _promoLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDevices());
    _promoCodeController.addListener(() => setState(() {}));
    // reload history when AuthService changes (addToHistory calls notifyListeners)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = Provider.of<AuthService>(context, listen: false);
      auth.addListener(_loadData);
    });
  }

  @override
  void dispose() {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      auth.removeListener(_loadData);
    } catch (e) {
      // ignore
    }
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('watch_history') ?? [];
      // Resolve episode ids to readable labels (anime title + episode)
      if (!mounted) return;
      final api = Provider.of<ApiService>(context, listen: false);
      final labels = await Future.wait(
        ids.map((id) async {
          try {
            final ep = await api.getEpisode(id);
            if (ep != null) {
              final animeTitle = ep['anime_title'] ?? ep['title'] ?? id;
              final num = ep['episode_number'] ?? '';
              return '$animeTitle - E${num.toString()}';
            }
          } catch (e) {
            // ignore and fallback to id
          }
          return id;
        }),
      );
      setState(() {
        watchHistoryIds = ids;
        watchHistory = labels;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _activatePromoCode(String code) async {
    if (code.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Promo kodni kiriting')));
      return;
    }
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promo kodni faollashtirish uchun tizimga kiring'),
        ),
      );
      return;
    }

    setState(() => _promoLoading = true);

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      // Check promo - server may return message and/or valid flag
      final info = await api.checkPromo(code);
      if (!mounted) return;
      final checkMsg = (info != null && info['message'] != null)
          ? info['message'].toString()
          : (info != null && info['valid'] == true)
              ? 'Promo kodi amal qiladi'
              : 'Noto`g`ri yoki muddati o`tgan promo kod';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(checkMsg)));

      if (info == null || info['valid'] != true) {
        setState(() => _promoLoading = false);
        return;
      }

      final res = await api.applyPromo(code, auth.userId!);
      if (!mounted) return;
      final applyMsg = res != null && res['message'] != null
          ? res['message'].toString()
          : (res != null && res['success'] == true)
              ? 'Promo kod muvaffaqiyatli qo`llanildi'
              : 'Promo kodni qo`llashda xatolik';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(applyMsg)));

      if (res != null && res['success'] == true && res['premium'] == true) {
        await auth.setPremium(true);
      }

      _promoCodeController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promo kodni tekshirishda xatolik')),
      );
    } finally {
      if (mounted) setState(() => _promoLoading = false);
    }
  }

  Future<void> _logout() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profil', style: AppStyles.headlineM),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(auth),
                  _buildPremiumSection(auth),
                  _buildPromoCodeSection(auth),
                  _buildHistorySection(),
                  _buildDevicesSection(),
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(AuthService auth) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimens.paddingL),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              // Quick dialog to set avatar url
              final controller = TextEditingController(text: auth.avatar ?? '');
              final res = await showDialog<String?>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Avatar URL kiritish'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Bekor'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, controller.text.trim()),
                      child: const Text('Saqlash'),
                    ),
                  ],
                ),
              );
              if (res != null && res.isNotEmpty) {
                await auth.updateAvatar(res);
              }
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: CachedNetworkImageProvider(
                      auth.avatar ?? AppConstants.defaultAvatarUrl,
                      cacheManager: AppCacheManager.instance,
                    ),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingL),
          Text(
            auth.username ?? 'Foydalanuvchi',
            style: AppStyles.headlineS,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.paddingS),
          Text(
            auth.email ?? '',
            style: AppStyles.labelL,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(AuthService auth) {
    return Container(
      margin: const EdgeInsets.all(AppDimens.paddingL),
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Holati',
                    style: AppStyles.titleL.copyWith(color: AppColors.text),
                  ),
                  const SizedBox(height: AppDimens.paddingS),
                  Text(
                    auth.premium ? 'Faol' : 'Nofaol',
                    style: AppStyles.titleM.copyWith(
                      color: auth.premium ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              Icon(
                auth.premium ? Icons.verified : Icons.lock,
                color: AppColors.text,
                size: AppDimens.iconL,
              ),
            ],
          ),
          if (!auth.premium) ...[
            const SizedBox(height: AppDimens.paddingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.text,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.paddingL,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  ),
                ),
                onPressed: () async {
                  final uri = Uri.parse('https://t.me/voiplay_price/3');
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      // fallback attempt
                      final ok = await launchUrl(uri);
                      if (!ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Brauzerni ochib bo‘lmadi'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Havola ochishda xato')),
                      );
                    }
                  }
                },
                child: Text(
                  'Premium Olish',
                  style: AppStyles.titleM.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(AuthService auth) {
    if (auth.premium) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
        padding: const EdgeInsets.all(AppDimens.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Promo Kodi', style: AppStyles.titleL),
            const SizedBox(height: AppDimens.paddingM),
            Text('Siz allaqachon Premium obunadasiz', style: AppStyles.bodyM),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Promo Kodi', style: AppStyles.titleL),
          const SizedBox(height: AppDimens.paddingM),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoCodeController,
                  style: AppStyles.bodyM,
                  decoration: InputDecoration(
                    hintText: 'Promo kodni kiriting',
                    hintStyle: AppStyles.labelM.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.paddingM),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed:
                      _promoLoading || _promoCodeController.text.trim().isEmpty
                          ? null
                          : () => _activatePromoCode(
                                _promoCodeController.text.trim(),
                              ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                  ),
                  child: _promoLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Faollashtirish',
                          style: AppStyles.titleM.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.all(AppDimens.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ko\'rish Tarixi', style: AppStyles.titleL),
          const SizedBox(height: AppDimens.paddingL),
          watchHistory.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.paddingXXL,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Tarix bo\'sh',
                    style: AppStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: watchHistory.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppDimens.paddingM),
                      padding: const EdgeInsets.all(AppDimens.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusL),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              watchHistory[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.bodyM,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.close, size: AppDimens.iconS),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                if (index < watchHistoryIds.length) {
                                  watchHistoryIds.removeAt(index);
                                  watchHistory.removeAt(index);
                                }
                              });
                              await prefs.setStringList(
                                'watch_history',
                                watchHistoryIds,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDevicesSection() {
    final auth = Provider.of<AuthService>(context);
    if (auth.userId == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingL,
        vertical: AppDimens.paddingM,
      ),
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qurilmalar', style: AppStyles.titleL),
          const SizedBox(height: AppDimens.paddingM),
          devices.isEmpty
              ? Text(
                  'Qurilmalar topilmadi',
                  style:
                      AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
                )
              : Column(
                  children: devices.map((d) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        d['device_name'] ??
                            d['name'] ??
                            d['platform'] ??
                            'Qurilma',
                        style: AppStyles.bodyM,
                      ),
                      subtitle: Text(
                        d['device_uuid'] ??
                            d['device_id'] ??
                            d['id']?.toString() ??
                            '',
                        style: AppStyles.labelM.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _revokeDevice(
                          d['device_uuid'] ??
                              d['device_id'] ??
                              d['id']?.toString(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Future<void> _loadDevices() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.userId == null) return;
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final d = await api.getUserDevices(auth.userId!);
      if (mounted) setState(() => devices = d);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _revokeDevice(String? deviceId) async {
    if (deviceId == null) return;
    final api = Provider.of<ApiService>(context, listen: false);
    final ok = await api.revokeDevice(deviceId);
    if (ok) {
      setState(
        () => devices.removeWhere(
          (d) => (d['device_id'] ?? d['id']?.toString()) == deviceId,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Qurilma muvaffaqiyatli o‘chirildi')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Qurilmani o‘chirishda xatolik')),
      );
    }
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingL),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingL),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
            ),
          ),
          onPressed: _logout,
          child: Text(
            'Chiqish',
            style: AppStyles.titleL.copyWith(color: AppColors.text),
          ),
        ),
      ),
    );
  }
}
