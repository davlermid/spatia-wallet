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

class SpatiaWalletApp extends StatelessWidget {
  const SpatiaWalletApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spatia Wallet',
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
      home: const MainNavigationScreen(),
    );
  }
}

class CandlePoint {
  final double open;
  final double high;
  final double low;
  final double close;

  CandlePoint({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  bool get isBullish => close >= open;
}

class CryptoAsset {
  final String symbol;
  final String name;
  final String balance;
  final double fiatValue;
  final double change24h;
  final Color badgeColor;
  final IconData icon;

  CryptoAsset({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.fiatValue,
    required this.change24h,
    required this.badgeColor,
    required this.icon,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PlaceholderScreen(title: "Spatia Multi-DEX Swap"),
    const PlaceholderScreen(title: "Spatial DePIN Node Map"),
    const PlaceholderScreen(title: "Web3 dApp Browser"),
    const PlaceholderScreen(title: "Security & Hardware Enclave"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF090D1A),
          border: Border(top: BorderSide(color: Color(0x1FFFFFFF), width: 0.8)),
        ),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horizontal_circle_outlined),
              activeIcon: Icon(Icons.swap_horizontal_circle),
              label: 'DEX Swap',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Node Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.public),
              activeIcon: Icon(Icons.public, color: Color(0xFF38BDF8)),
              label: 'Browser',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: 'Security',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeframe = '24H';

  final List<CandlePoint> _spatCandles = [
    CandlePoint(open: 0.024, high: 0.028, low: 0.023, close: 0.027),
    CandlePoint(open: 0.027, high: 0.029, low: 0.025, close: 0.026),
    CandlePoint(open: 0.026, high: 0.031, low: 0.025, close: 0.030),
    CandlePoint(open: 0.030, high: 0.032, low: 0.028, close: 0.029),
    CandlePoint(open: 0.029, high: 0.035, low: 0.028, close: 0.034),
    CandlePoint(open: 0.034, high: 0.036, low: 0.032, close: 0.033),
    CandlePoint(open: 0.033, high: 0.038, low: 0.032, close: 0.037),
    CandlePoint(open: 0.037, high: 0.041, low: 0.035, close: 0.040),
    CandlePoint(open: 0.040, high: 0.042, low: 0.038, close: 0.039),
    CandlePoint(open: 0.039, high: 0.045, low: 0.038, close: 0.044),
  ];

  final List<CryptoAsset> _assets = [
    CryptoAsset(
      symbol: "SPAT",
      name: "Spatia Network",
      balance: "12,450.00",
      fiatValue: 547.80,
      change24h: 18.42,
      badgeColor: const Color(0xFF38BDF8),
      icon: Icons.hub,
    ),
    CryptoAsset(
      symbol: "USDT",
      name: "Tether USD (Arbitrum)",
      balance: "385.20",
      fiatValue: 385.20,
      change24h: 0.02,
      badgeColor: const Color(0xFF2DD4BF),
      icon: Icons.attach_money,
    ),
    CryptoAsset(
      symbol: "ETH",
      name: "Ethereum (Nitro)",
      balance: "0.2450",
      fiatValue: 845.25,
      change24h: 3.15,
      badgeColor: const Color(0xFF818CF8),
      icon: Icons.diamond_outlined,
    ),
    CryptoAsset(
      symbol: "ARB",
      name: "Arbitrum One",
      balance: "310.00",
      fiatValue: 248.00,
      change24h: -1.85,
      badgeColor: const Color(0xFF3B82F6),
      icon: Icons.layers_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x3338BDF8)),
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                          SizedBox(width: 6),
                          Text(
                            "Arbitrum Nitro",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0)),
                          ),
                          Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "0x25e4...4b89",
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.qr_code_scanner, size: 18, color: Colors.white70),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF070E22)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x2238BDF8)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TOTAL PROTOCOL BALANCE",
                        style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            "\$2,026.25",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "+12.8%",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButton(Icons.arrow_upward, "Send"),
                          _buildActionButton(Icons.arrow_downward, "Receive"),
                          _buildActionButton(Icons.sync_alt, "Swap", isHighlighted: true),
                          _buildActionButton(Icons.credit_card, "Off-Ramp"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D182E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x332DD4BF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.radar, color: Color(0xFF2DD4BF), size: 16),
                          SizedBox(width: 8),
                          Text(
                            "PoPP Mining Active • 10 \$SPAT / POI",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0)),
                          ),
                        ],
                      ),
                      const Text(
                        "HARDWARE SECURE",
                        style: TextStyle(fontSize: 9, fontFamily: 'monospace', color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090E1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x1FFFFFFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "SPAT / USDT (Spatia Native Pool)",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "\$0.0440  +18.42%",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF34D399)),
                              ),
                            ],
                          ),
                          Row(
                            children: ['1H', '24H', '7D', '1M'].map((tf) {
                              bool selected = _selectedTimeframe == tf;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTimeframe = tf),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: selected ? const Color(0xFF38BDF8) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tf,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: selected ? Colors.black : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 130,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: CandlestickPainter(candles: _spatCandles),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: const [
                    Text("Portfolio Assets", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Auto-Route: Spatia AMM", style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontFamily: 'monospace')),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final a = _assets[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF090E1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x15FFFFFF)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: a.badgeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(a.icon, color: a.badgeColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                Text(a.name, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(a.balance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                              Row(
                                children: [
                                  Text(
                                    "\$${a.fiatValue.toStringAsFixed(2)}",
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${a.change24h >= 0 ? '+' : ''}${a.change24h}%",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: a.change24h >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _assets.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool isHighlighted = false}) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFF38BDF8) : const Color(0xFF1E293B),
            shape: BoxShape.circle,
            boxShadow: isHighlighted
                ? [BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))]
                : null,
          ),
          child: Icon(icon, color: isHighlighted ? Colors.black : Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0))),
      ],
    );
  }
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

    double candleWidth = size.width / (candles.length * 1.6);
    double spacing = size.width / candles.length;

    final bullPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final bearPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    final wickPaint = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

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

      Rect candleRect = Rect.fromCenter(
        center: Offset(x, top + bodyHeight / 2),
        width: candleWidth,
        height: bodyHeight,
      );

      canvas.drawRRect(RRect.fromRectAndRadius(candleRect, const Radius.circular(2)), currentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
      ),
    );
  }
}
