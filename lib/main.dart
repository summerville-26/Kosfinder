import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';
import 'providers/auth_provider.dart';
import 'providers/kos_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/kos_repository.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Membaca kredensial dari --dart-define secara aman tanpa hardcoded keys
  if (AppConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: AppConfig.supabaseAnonKey,
    );
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
