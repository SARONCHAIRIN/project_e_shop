import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/auth/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Auth
import 'Presentation/controllers/cart/cart_controller.dart';
import 'Presentation/screen/order/trackOrder.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'data/datasources/cart/cart_service.dart';
import 'data/datasources/user_auth_service.dart';
import 'data/repositories/cart/cart_repo.dart';
import 'data/repositories/user_auth_repository.dart';

// Screens
import 'Presentation/screen/Splash_Screen_Page/slpash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //call dotenv
  await dotenv.load(fileName: ".env");

  // Initialize token storage & read token
  final tokenStorage = TokenStorage();
  final token = await tokenStorage.readToken();
  final userId = await tokenStorage.readUserId() ?? 0;

  // Initialize API & Auth
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final authRepository = User_AuthRepository(
    service: authService,
    storage: tokenStorage,
  );
// Initialize Cart Service & Repository
  final cartService = CartService();
  final cartRepo = CartRepository(cartService);


  runApp(
    MultiProvider(
      providers: [
        //cart controller
        ChangeNotifierProvider(create: (_) => CartController(repository: cartRepo,),),

        //order controller
      ],
      child: MyApp(
        authRepository: authRepository,
        initialScreen: token == null ? 'splashscreen' : 'home',
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final User_AuthRepository authRepository;
  final String initialScreen;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.initialScreen,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      onGenerateRoute: (settings) {

        if (settings.name == '/trackorder') {

          final args = settings.arguments as Map?;
          return MaterialPageRoute(

            builder: (_) => TrackOrderPage(),
          );
        }

        if (settings.name == '/homemainppage') {

          return MaterialPageRoute(

            builder: (_) => DivicesNav(authRepository: authRepository),
          );
        }

        if (settings.name == '/divicenav') {

          return MaterialPageRoute(

            builder: (_) => DivicesNav(authRepository: authRepository),
          );
        }
        if (settings.name == '/login') {

          return MaterialPageRoute(

            builder: (_) => LoginScreen(authRepository: authRepository),
          );
        }

        if(settings.name == '/register') {
          return MaterialPageRoute(builder: (_) => SignupScreen(authRepository: authRepository),
          );
        }
        return null;
      },

      title: 'E-Shop',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Builder(
        builder: (context) {
          // Decide initial screen
          switch (initialScreen) {
            case 'splashscreen':
              return SplashScreen(authRepository: authRepository);
            case 'home':
              return SplashScreen(authRepository: authRepository);
            default:
              return const Scaffold(
                body: Center(child: Text('Unknown initial screen')),
              );
          }
        },
      ),
    );
  }
}