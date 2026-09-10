import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const SpatiaWalletApp());
}

// ---------------------------------------------------------------------------
// GLOBAL APPLICATION & DEPIN STATE CONTROLLER
// ---------------------------------------------------------------------------
class WalletState extends ChangeNotifier {
  bool isAuthenticated = false;
  String currentAddress = "0x25e4c8F79B13C12bE6347A01B56F4389";
  String mnemonicPhrase = "orbit crystal pulse glacier matrix velvet siren timber whisper hazard nexus galaxy";
  String privateKeyHex = "0x4a9b2c8f1e5d7a30894bcf2e176985ac5821037bcde8491f06129845cd12ef4b";

  // Financial Balances
  double spatBalance = 14250.0;
  double usdtBalance = 420.50;
  double ethBalance = 0.3150;
  double arbBalance = 380.0;

  // DePIN Veteran Surveyor Stats
  int lifetimePOIs = 23176; // Geolancer Master Pioneer Tribute
  int offlineQueueCount = 6; // Zero-Data Offline Buffer
  int gasVoucherCredits = 48; // Paymaster Credits: Earned via POI
  bool privacyShieldActive = true; // On-Device Auto Blur
  bool pdrInertialActive = true; // Pedestrian Dead Reckoning

  // Real-Time Binance Feed + Volatility
  double ethPrice = 2780.40;
  double ethChange24h = 4.12;
  double arbPrice = 0.845;
  double arbChange24h = -0.95;
  double spatPrice = 0.0468;
  double spatChange24h = 24.15;

  Timer? _tickerTimer;

  WalletState() {
    _startLivePriceTicker();
  }

  void login(String address, {String? phrase, String? privKey}) {
    isAuthenticated = true;
    currentAddress = address;
    if (phrase != null) mnemonicPhrase = phrase;
    if (privKey != null) privateKeyHex = privKey;
    notifyListeners();
  }

  void logout() {
    isAuthenticated = false;
    notifyListeners();
  }

  // Record POI with Gas Paymaster Voucher + Token Rewards
  void recordPOI({required String type, double rewardSPAT = 15.0, bool isOffline = false}) {
    lifetimePOIs += 1;
    if (isOffline) {
      offlineQueueCount += 1;
    } else {
      spatBalance += rewardSPAT;
      gasVoucherCredits += 2; // Setiap POI menyubsidi 2 transaksi swap gas gratis
    }
    notifyListeners();
  }

  // Sinkronisasi Offline Mesh Buffer ke Blockchain Arbitrum
  void syncOfflineQueue() {
    if (offlineQueueCount > 0) {
      spatBalance += (offlineQueueCount * 15.0);
      gasVoucherCredits += (offlineQueueCount * 2);
      offlineQueueCount = 0;
      notifyListeners();
    }
  }

  void togglePrivacyShield() {
    privacyShieldActive = !privacyShieldActive;
    notifyListeners();
  }

  void togglePDR() {
    pdrInertialActive = !pdrInertialActive;
    notifyListeners();
  }

  void executeSwap(String from, String to, double amountIn, double amountOut, bool useGasVoucher) {
    if (from == "USDT") usdtBalance -= amountIn;
    if (from == "SPAT") spatBalance -= amountIn;
    if (from == "ETH") ethBalance -= amountIn;
    if (from == "ARB") arbBalance -= amountIn;

    if (to == "USDT") usdtBalance += amountOut;
    if (to == "SPAT") spatBalance += amountOut;
    if (to == "ETH") ethBalance += amountOut;
    if (to == "ARB") arbBalance += amountOut;

    if (useGasVoucher && gasVoucherCredits > 0) {
      gasVoucherCredits -= 1;
    }
    notifyListeners();
  }

  double get totalPortfolioUSD {
    return (spatBalance * spatPrice) + usdtBalance + (ethBalance * ethPrice) + (arbBalance * arbPrice);
  }

  void _startLivePriceTicker() {
    _fetchLiveCryptoPrices();
    _tickerTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchLiveCryptoPrices());
  }

  Future<void> _fetchLiveCryptoPrices() async {
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final req = await client.getUrl(Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbols=%5B%22ETHUSDT%22,%22ARBUSDT%22%5D'));
      final res = await req.close();
      if (res.statusCode == 200) {
        final raw = await res.transform(utf8.decoder).join();
        final List list = jsonDecode(raw);
        for (var item in list) {
          if (item['symbol'] == 'ETHUSDT') {
            ethPrice = double.parse(item['lastPrice']);
            ethChange24h = double.parse(item['priceChangePercent']);
          } else if (item['symbol'] == 'ARBUSDT') {
            arbPrice = double.parse(item['lastPrice']);
            arbChange24h = double.parse(item['priceChangePercent']);
          }
        }
      }
    } catch (_) {
      final rand = Random();
      spatPrice += (rand.nextDouble() - 0.47) * 0.0004;
    }
    final rand = Random();
    spatPrice += (rand.nextDouble() - 0.46) * 0.0003;
    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}

final globalWallet = WalletState();

// ---------------------------------------------------------------------------
// APPLICATION ROOT WITH DARK OBSIDIAN THEME
// ---------------------------------------------------------------------------
class SpatiaWalletApp extends StatelessWidget {
  const SpatiaWalletApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalWallet,
      builder: (context, _) {
        return MaterialApp(
          title: 'Spatia Wallet DePIN',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF030712),
            fontFamily: 'sans-serif',
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              secondary: Color(0xFF2DD4BF),
              surface: Color(0xFF0B132B),
            ),
          ),
          home: globalWallet.isAuthenticated
              ? const MainNavigationScreen()
              : const AuthOnboardingScreen(),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// SCREEN: SOVEREIGN AUTH & ONBOARDING (CREATE, IMPORT, PHRASELESS SSO)
// ---------------------------------------------------------------------------
class AuthOnboardingScreen extends StatefulWidget {
  const AuthOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<AuthOnboardingScreen> createState() => _AuthOnboardingScreenState();
}

class _AuthOnboardingScreenState extends State<AuthOnboardingScreen> {
  void _createNewWallet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B132B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("New Sovereign Wallet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.shield_outlined, color: Color(0xFF38BDF8)),
                ],
              ),
              const SizedBox(height: 8),
              const Text("Write down your 12 secret recovery words. Store them offline.", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF030712), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x3338BDF8))),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: globalWallet.mnemonicPhrase.split(" ").asMap().entries.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                      child: Text("${e.key + 1}. ${e.value}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0))),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () {
                    Navigator.pop(ctx);
                    globalWallet.login("0x" + List.generate(40, (i) => "0123456789abcdef"[Random().nextInt(16)]).join());
                  },
                  child: const Text("I Saved My Recovery Phrase", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _importSeed() {
    final c = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B132B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Import Mnemonic Seed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: c,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(hintText: "Enter 12 or 24 words...", filled: true, fillColor: const Color(0xFF030712), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2DD4BF), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  Navigator.pop(ctx);
                  globalWallet.login("0x7F2a89C1B043e098D712bA68364F76921345E6b8", phrase: c.text.isNotEmpty ? c.text : null);
                },
                child: const Text("Restore Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _importPrivateKey() {
    final c = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B132B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Import Private Key (Hex)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: c,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(hintText: "0x4a9b2c8f...", filled: true, fillColor: const Color(0xFF030712), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  Navigator.pop(ctx);
                  globalWallet.login("0x3C9107AbF88c03C77D59A65E12E990fD6b91A805", privKey: c.text.isNotEmpty ? c.text : null);
                },
                child: const Text("Import Key", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _passkeyLogin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0x3338BDF8))),
        title: Row(
          children: const [
            Icon(Icons.fingerprint, color: Color(0xFF2DD4BF), size: 28),
            SizedBox(width: 10),
            Text("Passkey SSO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Authenticating via Android Secure Hardware Enclave. Zero Seed Phrase Required.", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              globalWallet.login("0xPasskeyEnclave4821a8d05E4b9C678A0091");
            },
            child: const Text("Authorize Biometric", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF2DD4BF)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.4), blurRadius: 30, spreadRadius: 4)],
                    ),
                    child: const Icon(Icons.hub, size: 44, color: Colors.black),
                  ),
                  const SizedBox(height: 18),
                  const Text("SPATIA NETWORK", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 6),
                  const Text("Decentralized Physical Infrastructure & Super-DEX Wallet", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text("Create Sovereign Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _createNewWallet,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: const Color(0xFF2DD4BF), side: const BorderSide(color: Color(0x662DD4BF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      icon: const Icon(Icons.fingerprint, size: 22),
                      label: const Text("Passkey Login (Seedless SSO)", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _passkeyLogin,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0x33FFFFFF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: _importSeed,
                          child: const Text("Import Phrase", style: TextStyle(fontSize: 12, color: Color(0xFFE2E8F0))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0x33FFFFFF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: _importPrivateKey,
                          child: const Text("Private Key", style: TextStyle(fontSize: 12, color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text("Arbitrum Nitro Protected • BIP-39 / BIP-44 Standard", style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MAIN NAVIGATION BAR (5 TABS CONTAINER)
// ---------------------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DEXSwapScreen(),
    const NodeMapScreen(),
    const DAppBrowserScreen(),
    const SecurityEnclaveScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentTabIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Color(0xFF090D1A), border: Border(top: BorderSide(color: Color(0x1FFFFFFF), width: 0.8))),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF38BDF8),
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Icons.swap_horizontal_circle_outlined), activeIcon: Icon(Icons.swap_horizontal_circle), label: 'DEX Swap'),
            BottomNavigationBarItem(icon: Icon(Icons.radar), activeIcon: Icon(Icons.radar, color: Color(0xFF2DD4BF)), label: 'DePIN Radar'),
            BottomNavigationBarItem(icon: Icon(Icons.public), activeIcon: Icon(Icons.public, color: Color(0xFF38BDF8)), label: 'Browser'),
            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Security'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 1: DASHBOARD (PORTFOLIO, CANDLESTICK, SEND/RECEIVE, PAYMASTER BANNER)
// ---------------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeframe = '24H';

  void _showSendModal() {
    final toCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String selectedToken = "SPAT";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B132B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Send Digital Assets", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedToken,
                dropdownColor: const Color(0xFF0F172A),
                decoration: InputDecoration(filled: true, fillColor: const Color(0xFF030712), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ["SPAT", "USDT", "ETH", "ARB"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setModalState(() => selectedToken = val!),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: toCtrl,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(hintText: "Recipient Address (0x...)", filled: true, fillColor: const Color(0xFF030712), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(hintText: "Amount", filled: true, fillColor: const Color(0xFF030712), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
                  onPressed: () {
                    double amt = double.tryParse(amtCtrl.text) ?? 0.0;
                    if (amt > 0) globalWallet.executeSwap(selectedToken, "DUMMY", amt, 0, false);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transferred $amt $selectedToken to Arbitrum Nitro!")));
                  },
                  child: const Text("Confirm & Sign On-Chain", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiveModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B132B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Receive Assets (Arbitrum One)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(width: 130, height: 130, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.qr_code_2, size: 110, color: Colors.black))),
            const SizedBox(height: 16),
            SelectableText(globalWallet.currentAddress, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF38BDF8))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text("Copy Address"),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: globalWallet.currentAddress));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address copied to clipboard!")));
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalWallet,
      builder: (context, _) {
        final spatCandles = [
          CandlePoint(open: globalWallet.spatPrice * 0.90, high: globalWallet.spatPrice * 0.96, low: globalWallet.spatPrice * 0.88, close: globalWallet.spatPrice * 0.94),
          CandlePoint(open: globalWallet.spatPrice * 0.94, high: globalWallet.spatPrice * 0.99, low: globalWallet.spatPrice * 0.92, close: globalWallet.spatPrice * 0.98),
          CandlePoint(open: globalWallet.spatPrice * 0.98, high: globalWallet.spatPrice * 1.05, low: globalWallet.spatPrice * 0.96, close: globalWallet.spatPrice * 1.03),
          CandlePoint(open: globalWallet.spatPrice * 1.03, high: globalWallet.spatPrice * 1.07, low: globalWallet.spatPrice * 1.01, close: globalWallet.spatPrice),
        ];

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header: Network + Pioneer Badge
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x3338BDF8))),
                          child: Row(
                            children: const [
                              CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                              SizedBox(width: 6),
                              Text("Arbitrum Nitro", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        // Master Surveyor Pioneer Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5))),
                          child: Row(
                            children: [
                              const Icon(Icons.verified, size: 13, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text("${globalWallet.lifetimePOIs} POIs Verified", style: const TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Balance Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF070E22)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x2238BDF8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TOTAL PROTOCOL ASSET VALUE", style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("\$${globalWallet.totalPortfolioUSD.toStringAsFixed(2)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                child: const Text("+24.1%", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _actionBtn(Icons.arrow_upward, "Send", onTap: _showSendModal),
                              _actionBtn(Icons.arrow_downward, "Receive", onTap: _showReceiveModal),
                              _actionBtn(Icons.sync_alt, "Swap", isHighlighted: true, onTap: () {
                                final nav = context.findAncestorStateOfType<_MainNavigationScreenState>();
                                nav?.setState(() => nav._currentTabIndex = 1);
                              }),
                              _actionBtn(Icons.radar, "Map Radar", onTap: () {
                                final nav = context.findAncestorStateOfType<_MainNavigationScreenState>();
                                nav?.setState(() => nav._currentTabIndex = 2);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // INOVASI 1: DATA-FOR-GAS PAYMASTER TICKET BANNER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.local_gas_station, color: Color(0xFFA5B4FC), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Data-For-Gas Paymaster", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(4)),
                                      child: const Text("ACTIVE", style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text("${globalWallet.gasVoucherCredits} Gas Vouchers available (Subsidized by Physical POIs)", style: const TextStyle(fontSize: 10, color: Color(0xFFC7D2FE))),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),

                // Live Candlestick Canvas
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF090E1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x1FFFFFFF))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("SPAT / USDT (Spatia AMM)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text("\$${globalWallet.spatPrice.toStringAsFixed(4)}  +${globalWallet.spatChange24h}%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF34D399))),
                                ],
                              ),
                              Row(
                                children: ['1H', '24H', '7D'].map((tf) {
                                  bool sel = _selectedTimeframe == tf;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedTimeframe = tf),
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: sel ? const Color(0xFF38BDF8) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
                                      child: Text(tf, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sel ? Colors.black : const Color(0xFF94A3B8))),
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(height: 100, width: double.infinity, child: CustomPaint(painter: CandlestickPainter(candles: spatCandles))),
                        ],
                      ),
                    ),
                  ),
                ),

                // Asset Portfolio Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Live Assets Portfolio", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text("Binance + Nitro Feed", style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),

                // Assets List
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildAssetCard("SPAT", "Spatia Network", globalWallet.spatBalance.toStringAsFixed(2), globalWallet.spatBalance * globalWallet.spatPrice, globalWallet.spatChange24h, const Color(0xFF38BDF8), Icons.hub),
                    _buildAssetCard("USDT", "Tether USD", globalWallet.usdtBalance.toStringAsFixed(2), globalWallet.usdtBalance, 0.01, const Color(0xFF2DD4BF), Icons.attach_money),
                    _buildAssetCard("ETH", "Ethereum", globalWallet.ethBalance.toStringAsFixed(4), globalWallet.ethBalance * globalWallet.ethPrice, globalWallet.ethChange24h, const Color(0xFF818CF8), Icons.diamond_outlined),
                    _buildAssetCard("ARB", "Arbitrum One", globalWallet.arbBalance.toStringAsFixed(2), globalWallet.arbBalance * globalWallet.arbPrice, globalWallet.arbChange24h, const Color(0xFF3B82F6), Icons.layers_outlined),
                  ]),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionBtn(IconData icon, String label, {bool isHighlighted = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: isHighlighted ? const Color(0xFF38BDF8) : const Color(0xFF1E293B), shape: BoxShape.circle),
            child: Icon(icon, color: isHighlighted ? Colors.black : Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  Widget _buildAssetCard(String symbol, String name, String bal, double fiat, double change, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF090E1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x15FFFFFF))),
        child: Row(
          children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(name, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(bal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("\$${fiat.toStringAsFixed(2)} (${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%)", style: TextStyle(fontSize: 10, color: change >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 2: DEX SWAP (MULTI-ROUTER + 0-GAS PAYMASTER EXECUTION)
// ---------------------------------------------------------------------------
class DEXSwapScreen extends StatefulWidget {
  const DEXSwapScreen({Key? key}) : super(key: key);

  @override
  State<DEXSwapScreen> createState() => _DEXSwapScreenState();
}

class _DEXSwapScreenState extends State<DEXSwapScreen> {
  String _payToken = "USDT";
  String _receiveToken = "SPAT";
  final TextEditingController _payController = TextEditingController(text: "100");
  int _selectedRouteIndex = 0;
  bool _useGasVoucher = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalWallet,
      builder: (context, _) {
        double payAmount = double.tryParse(_payController.text) ?? 0.0;
        double receiveAmount = (_payToken == "USDT" && _receiveToken == "SPAT")
            ? (payAmount / globalWallet.spatPrice)
            : payAmount * 0.98;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text("Spatia Multi-DEX Aggregator", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Input Swap Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0B132B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x3338BDF8))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("You Pay", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          Text("Balance: ${globalWallet.usdtBalance.toStringAsFixed(2)} $_payToken", style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _payController,
                              keyboardType: TextInputType.number,
                              onChanged: (v) => setState(() {}),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(border: InputBorder.none, hintText: "0.0"),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                            child: Text(_payToken, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, color: Color(0xFF38BDF8)),
                  onPressed: () {
                    setState(() {
                      final t = _payToken;
                      _payToken = _receiveToken;
                      _receiveToken = t;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Receive Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0B132B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x332DD4BF))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("You Receive (Estimated)", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          Text("Rate: 1 SPAT ≈ \$${globalWallet.spatPrice.toStringAsFixed(4)}", style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(receiveAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                            child: Text(_receiveToken, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // INOVASI 1: PAYMASTER ZERO-GAS TOGGLE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF131A33), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x33818CF8))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.electric_bolt, color: Color(0xFFFBBF24), size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Pay Gas with Mapping Vouchers", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text("Balance: ${globalWallet.gasVoucherCredits} Vouchers", style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _useGasVoucher,
                        activeColor: const Color(0xFF38BDF8),
                        onChanged: (v) => setState(() => _useGasVoucher = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Aggregator Routes Comparison
                _buildRouteCard(0, "Spatia Native Pool", "0% Gas & Fee (Native AMM)", receiveAmount, "Gas: \$0.00 (Sponsored)", isBest: true),
                _buildRouteCard(1, "1inch Fusion V6", "Multi-Hop Arbitrum Nitro", receiveAmount * 0.985, _useGasVoucher ? "Gas: Sponsored" : "Gas: \$0.12"),
                _buildRouteCard(2, "ParaSwap Delta", "Split Routing Protocol", receiveAmount * 0.982, _useGasVoucher ? "Gas: Sponsored" : "Gas: \$0.15"),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () {
                      if (payAmount > 0) {
                        globalWallet.executeSwap(_payToken, _receiveToken, payAmount, receiveAmount, _useGasVoucher);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text("Swapped $payAmount $_payToken -> ${receiveAmount.toStringAsFixed(2)} $_receiveToken! (Gas: ${_useGasVoucher ? 'FREE by POI' : 'Paid'})"),
                        ));
                      }
                    },
                    child: const Text("Execute Swap (Zero Friction)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRouteCard(int index, String name, String sub, double output, String gas, {bool isBest = false}) {
    bool isSelected = _selectedRouteIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRouteIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF060913),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF38BDF8) : const Color(0x1FFFFFFF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF38BDF8) : Colors.grey, size: 18),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        if (isBest) ...[
                          const SizedBox(width: 6),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(4)), child: const Text("OPTIMAL", style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold))),
                        ]
                      ],
                    ),
                    Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${output.toStringAsFixed(2)} SPAT", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                Text(gas, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 3: SPATIAL DEPIN RADAR (PDR INERTIAL SENSOR, BOUNTIES, OFFLINE MESH)
// ---------------------------------------------------------------------------
class NodeMapScreen extends StatefulWidget {
  const NodeMapScreen({Key? key}) : super(key: key);

  @override
  State<NodeMapScreen> createState() => _NodeMapScreenState();
}

class _NodeMapScreenState extends State<NodeMapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarAnim;
  int _inertialSteps = 428;

  @override
  void initState() {
    super.initState();
    _radarAnim = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _radarAnim.dispose();
    super.dispose();
  }

  void _recordPOI(String name, double reward) {
    setState(() => _inertialSteps += 15);
    globalWallet.recordPOI(type: name, rewardSPAT: reward);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: const Color(0xFF10B981),
      content: Text("Recorded: $name • +$reward \$SPAT + 2 Gas Vouchers Earned!"),
    ));
  }

  void _recordOfflinePOI() {
    globalWallet.recordPOI(type: "Offline Alley Node", isOffline: true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Color(0xFFF59E0B),
      content: Text("Stored in Zero-Data Offline Buffer. Auto-sync ready!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: globalWallet,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text("Spatial DePIN Radar Node", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(globalWallet.privacyShieldActive ? Icons.visibility_off : Icons.visibility, color: globalWallet.privacyShieldActive ? const Color(0xFF10B981) : Colors.grey),
                tooltip: "On-Device Privacy Shield",
                onPressed: () {
                  globalWallet.togglePrivacyShield();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(globalWallet.privacyShieldActive ? "Privacy Shield: ON (Face & License Plate Auto-Blurred)" : "Privacy Shield: OFF"),
                  ));
                },
              )
            ],
          ),
          body: Column(
            children: [
              // INOVASI 2: PEDESTRIAN DEAD RECKONING (PDR) VECTOR BAR
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF0B132B), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x3338BDF8))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color: Color(0xFF38BDF8), size: 18),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Pedestrian Dead Reckoning (PDR)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text("Inertial Vector: $_inertialSteps steps • Heading: 142° SE", style: const TextStyle(fontSize: 10, color: Color(0xFF2DD4BF))),
                          ],
                        ),
                      ],
                    ),
                    Switch(value: globalWallet.pdrInertialActive, activeColor: const Color(0xFF2DD4BF), onChanged: (v) => globalWallet.togglePDR()),
                  ],
                ),
              ),

              // INOVASI 4: ZERO-DATA OFFLINE MESH QUEUE RIBBON
              if (globalWallet.offlineQueueCount > 0)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF2D1B00), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF59E0B))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi_off, size: 16, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          Text("${globalWallet.offlineQueueCount} Offline POIs Pending Sync", style: const TextStyle(fontSize: 11, color: Color(0xFFFDE68A), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), minimumSize: Size.zero),
                        onPressed: () => globalWallet.syncOfflineQueue(),
                        child: const Text("Sync Now", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),

              // Radar Visualizer Canvas with Bounty Nodes
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _radarAnim,
                    builder: (context, child) => CustomPaint(
                      size: const Size(260, 260),
                      painter: RadarPainter(progress: _radarAnim.value),
                    ),
                  ),
                ),
              ),

              // INOVASI 3: CORPORATE SPATIAL BOUNTY TRAY (HIGH VALUE TARGETS)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF090E1A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Color(0x1FFFFFFF))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Active Corporate Spatial Bounties", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Logistics Priority Zones", style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 10)),
                            icon: const Icon(Icons.fork_right, size: 16, color: Color(0xFF38BDF8)),
                            label: const Text("Alley Fork\n+15 SPAT", textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                            onPressed: () => _recordPOI("Alley Fork & Dead-End", 15.0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 10)),
                            icon: const Icon(Icons.storefront, size: 16, color: Color(0xFF2DD4BF)),
                            label: const Text("Micro-Biz\n+25 SPAT", textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                            onPressed: () => _recordPOI("Micro-Home Enterprise", 25.0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 10)),
                            icon: const Icon(Icons.local_shipping, size: 16, color: Color(0xFFFBBF24)),
                            label: const Text("Drop-Off\n+50 SPAT", textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                            onPressed: () => _recordPOI("Van Access Limit", 50.0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Offline Record Button
                        IconButton(
                          icon: const Icon(Icons.save_alt, color: Color(0xFFF59E0B)),
                          tooltip: "Save Offline POI",
                          onPressed: _recordOfflinePOI,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;
  RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()..color = const Color(0x3338BDF8)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.3, ringPaint);
    canvas.drawCircle(center, radius * 0.6, ringPaint);
    canvas.drawCircle(center, radius, ringPaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.transparent, const Color(0xFF38BDF8).withOpacity(0.4)],
        transform: GradientRotation(progress * pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Bounty Blip 1: Micro-Biz
    final blip1 = Paint()..color = const Color(0xFF2DD4BF);
    canvas.drawCircle(Offset(center.dx + 45, center.dy - 40), 5, blip1);

    // Bounty Blip 2: High Value Van Drop-Off
    final blip2 = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(Offset(center.dx - 60, center.dy + 35), 7, blip2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ---------------------------------------------------------------------------
// TAB 4: WEB3 dAPP BROWSER (UNISWAP, NITRO BRIDGE, EXPLORER)
// ---------------------------------------------------------------------------
class DAppBrowserScreen extends StatelessWidget {
  const DAppBrowserScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _dapps = const [
    {"name": "Uniswap V3", "url": "https://app.uniswap.org", "desc": "Leading Decentralized Trading Protocol"},
    {"name": "Arbitrum Bridge", "url": "https://bridge.arbitrum.io", "desc": "Official Nitro Rollup Gateway"},
    {"name": "Aave V3", "url": "https://app.aave.com", "desc": "Non-Custodial Liquidity Market"},
    {"name": "OpenSea Arbitrum", "url": "https://opensea.io", "desc": "NFT & Digital Physical Assets"},
    {"name": "Spatia Explorer", "url": "https://explorer.spatia.network", "desc": "Global POI & Block Verification"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x3338BDF8))),
          child: Row(
            children: const [
              Icon(Icons.lock, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Expanded(child: Text("https://app.uniswap.org", style: TextStyle(fontSize: 12, color: Colors.white70))),
              Icon(Icons.refresh, size: 16, color: Color(0xFF38BDF8)),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0D182E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x332DD4BF))),
            child: Row(
              children: [
                const Icon(Icons.link, color: Color(0xFF2DD4BF), size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text("Spatia Web3 Provider Injected (Nitro RPC Active)", style: const TextStyle(fontSize: 11))),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text("Verified Web3 dApps", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._dapps.map((d) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: const Color(0xFF090E1A), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x1FFFFFFF))),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFF1E293B), child: Text(d['name']![0], style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold))),
              title: Text(d['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: Text(d['desc']!, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              trailing: const Icon(Icons.open_in_new, size: 16, color: Color(0xFF94A3B8)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Launching ${d['name']} in Sovereign Container...")));
              },
            ),
          )).toList(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 5: SECURITY ENCLAVE & PIONEER IDENTITY
// ---------------------------------------------------------------------------
class SecurityEnclaveScreen extends StatelessWidget {
  const SecurityEnclaveScreen({Key? key}) : super(key: key);

  void _showPhrase(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        title: const Text("Recovery Seed Phrase", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SelectableText(globalWallet.mnemonicPhrase, style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF38BDF8))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
      ),
    );
  }

  void _showPrivateKey(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        title: const Text("Private Key (Raw Hex)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SelectableText(globalWallet.privateKeyHex, style: const TextStyle(fontFamily: 'monospace', color: Color(0xFFF87171), fontSize: 11)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Security & Pioneer Enclave", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pioneer Milestone Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF78350F), Color(0xFF451A03)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.military_tech, color: Color(0xFFFDE68A), size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Genesis Surveyor Tier: LEGEND", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text("${globalWallet.lifetimePOIs} Historical POIs Contributed (Master Level)", style: const TextStyle(fontSize: 11, color: Color(0xFFFDE68A))),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text("Cryptographic Protection", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _tile(Icons.vpn_key, "12-Word Recovery Mnemonic", "Inspect backup seed words", () => _showPhrase(context)),
          _tile(Icons.code, "Export Private Key", "Raw ECDSA Secp256k1 key", () => _showPrivateKey(context), isDestructive: true),

          const SizedBox(height: 16),
          const Text("Hardware Edge Security", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _tile(Icons.camera_enhance, "On-Device Privacy Shield", "Auto-blur citizen faces on local RAM", () => globalWallet.togglePrivacyShield()),
          _tile(Icons.directions_walk, "PDR Inertial Odometry", "Pedestrian dead reckoning vector engine", () => globalWallet.togglePDR()),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
              label: const Text("Lock Wallet Session", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              onPressed: () => globalWallet.logout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String sub, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF090E1A), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x1FFFFFFF))),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? const Color(0xFFF87171) : const Color(0xFF38BDF8)),
        title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDestructive ? const Color(0xFFF87171) : Colors.white)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CANDLESTICK CUSTOM PAINTER (PERFORMANCE CANVAS)
// ---------------------------------------------------------------------------
class CandlePoint {
  final double open, high, low, close;
  CandlePoint({required this.open, required this.high, required this.low, required this.close});
  bool get isBullish => close >= open;
}

class CandlestickPainter extends CustomPainter {
  final List<CandlePoint> candles;
  CandlestickPainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    double maxVal = candles.map((c) => c.high).reduce(max);
    double minVal = candles.map((c) => c.low).reduce(min);
    double range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);
    double candleWidth = size.width / (candles.length * 1.8);
    double spacing = size.width / candles.length;

    final bullPaint = Paint()..color = const Color(0xFF10B981)..style = PaintingStyle.fill;
    final bearPaint = Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.fill;
    final wickPaint = Paint()..strokeWidth = 1.2..style = PaintingStyle.stroke;

    for (int i = 0; i < candles.length; i++) {
      final c = candles[i];
      double x = (i * spacing) + (spacing / 2);
      double openY = size.height - ((c.open - minVal) / range * size.height);
      double closeY = size.height - ((c.close - minVal) / range * size.height);
      double highY = size.height - ((c.high - minVal) / range * size.height);
      double lowY = size.height - ((c.low - minVal) / range * size.height);

      Paint currentPaint = c.isBullish ? bullPaint : bearPaint;
      wickPaint.color = currentPaint.color;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      double top = min(openY, closeY);
      double bottom = max(openY, closeY);
      double bodyHeight = max(bottom - top, 2.0);
      Rect candleRect = Rect.fromCenter(center: Offset(x, top + bodyHeight / 2), width: candleWidth, height: bodyHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(candleRect, const Radius.circular(2)), currentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
