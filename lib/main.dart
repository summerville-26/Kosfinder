import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/kos_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/kos_repository.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prioritas konfigurasi: dari --dart-define jika ada, atau menggunakan URL & Key proyek
  const defaultUrl = 'https://ibickfmxyrgazmdcmgld.supabase.co';
  const defaultAnonKey = 'sb_publishable_yUjvvg09H4OzlVY_o7cAKQ_8lALGl00';

  final supabaseUrl = AppConfig.supabaseUrl.isNotEmpty
      ? AppConfig.supabaseUrl
      : defaultUrl;
  final supabaseAnonKey = AppConfig.supabaseAnonKey.isNotEmpty
      ? AppConfig.supabaseAnonKey
      : defaultAnonKey;

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase init error: $e');
    }
  }

  runApp(const KosFinderApp());
}

/// Root widget aplikasi KosFinder.
class KosFinderApp extends StatelessWidget {
  final KosRepository? kosRepository;
  final AuthRepository? authRepository;

  const KosFinderApp({
    super.key,
    this.kosRepository,
    this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<KosProvider>(
          create: (_) => KosProvider(repository: kosRepository)..fetchKos(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(repository: authRepository),
        ),
      ],
      child: MaterialApp(
        title: 'KosFinder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
