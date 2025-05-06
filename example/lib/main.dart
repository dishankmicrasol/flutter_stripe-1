// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '.env.example.dart';
import 'screens/screens.dart';
import 'widgets/dismiss_focus_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return DismissFocusOverlay(
      child: MaterialApp(
        theme: exampleAppTheme,
        // home: HomePage(),
        home: PaymentPage(),
        navigatorObservers: [],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Examples'),
      ),
      body: ListView(children: [
        ...ListTile.divideTiles(
          context: context,
          tiles: [for (final example in Example.screens) example],
        ),
      ]),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  Future<void> initPaymentSheetSetupMode() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // // 1. create payment intent on the server
      // final data = await _createTestPaymentSheet();

      // create some billingdetails
      final billingDetails = BillingDetails(
        /*name: 'Vayu Robotics',
        email: 'email@stripe.com',
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),*/
      ); // mocked data for tests

      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Main params
          merchantDisplayName: 'Flutter Stripe Store Demo',
          paymentIntentClientSecret: "pi_3RHkOy2fPNVKwDlg0BhYKHww_secret_mzNJwqjoeVnkST2VcfOzaHz0t",
          // customerId: "cus_SC4vT6JxX9sWiM",
          paymentMethodOrder: ['card'],
          primaryButtonLabel: 'Pay Now 50\$',

          // billingDetails: billingDetails,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      rethrow;
    }
  }

  Future<void> confirmPayment() async {
    /// TODO
    /// confirmPayment
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // 3. display the payment sheet.
      await Stripe.instance.presentPaymentSheet();

      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Payment successfully completed'),
          ),
        );
      }
    } on Exception catch (e) {
      if (e is StripeException) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error from Stripe: ${e.error.localizedMessage}'),
          ),
        );
      } else {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Unforeseen error: $e'),
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stripe PaymentSheet Demo")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: ()async{
                await initPaymentSheetSetupMode();
                await confirmPayment();
              },
              child: const Text("Gpay"),
            ),
            // ElevatedButton(
            //   onPressed: initPaymentSheetSetupModeGPAY,
            //   child: const Text("Gpay"),
            // ),
            // ElevatedButton(
            //   onPressed: initPaymentSheetSetupModeGPAY,
            //   child: const Text("Gpay"),
            // ),
          ],
        ),
      ),
    );
  }
}

final exampleAppTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color(0xff6058F7),
    secondary: Color(0xff6058F7),
  ),
  primaryColor: Colors.white,
  useMaterial3: false,
  appBarTheme: AppBarTheme(elevation: 1),
);
