import 'package:customer_app/for%20test/detail2.dart';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  List<Product> data = [];
  Map<int, String> koreanNames = {};
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    getJSONdata();
  }

  Future<void> getJSONdata() async {
    final url = Uri.parse('${IpAddress.baseUrl}/product/select');
    try {
      final response = await http.post(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final List list = decoded['results'];
        final fetchedData = list.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();

        final Map<String, Product> uniqueMap = {};
        for (final item in fetchedData) {
          uniqueMap.putIfAbsent(item.ename, () => item);
        }

        if (!mounted) return;
        setState(() {
          data = uniqueMap.values.toList();
          _isLoading = false;
        });

        for (final item in data) {
          fetchKoreanName(item);
        }
      } else {
        setState(() { _errorMessage = "Server Error"; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMessage = "Connection Failed"; _isLoading = false; });
    }
  }

  Future<void> fetchKoreanName(Product product) async {
    final int targetPid = (product.mid != null && product.mid != 0) ? product.mid! : product.id!;
    var url = Uri.parse('${IpAddress.baseUrl}/productname/select?pid=$targetPid');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        List results = jsonResponse['results'];
        if (results.isNotEmpty && mounted) {
          setState(() { koreanNames[product.id!] = results[0]['name']; });
        }
      }
    } catch (e) { debugPrint('Name Fetch Error: $e'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // 아주 연한 웜그레이
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: Colors.white.withOpacity(0.7),
              elevation: 0,
              centerTitle: false,
              title: Image.asset('images/logo.png', height: 22),
              actions: [
                IconButton(icon: const Icon(Icons.search_rounded, color: Colors.black, size: 26), onPressed: () {}),
                IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 26), onPressed: () {}),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
          : RefreshIndicator(
              onRefresh: getJSONdata,
              edgeOffset: 100,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  
                  // 메인 타이틀
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Curated Collections", style: TextStyle(fontSize: 14, color: Colors.grey[600], letterSpacing: 1.2)),
                          const SizedBox(height: 8),
                          const Text("당신을 위한 새로운 발견", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
                        ],
                      ),
                    ),
                  ),

                  // 창의적 히어로 슬라이더
                  SliverToBoxAdapter(child: _buildCreativeSlider()),

                  // 가로형 섹션 (신상품)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("New Arrivals", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                          Text("전체보기", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildHorizontalList()),

                  // 그리드 섹션 (인기 상품)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                      child: const Text("Editor's Pick", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.6,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ProductCard(product: data[index], koreanName: koreanNames[data[index].id]),
                        childCount: data.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 50)),
                ],
              ),
            ),
    );
  }

  Widget _buildCreativeSlider() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: 420,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (v) => setState(() => _currentPage = v),
        itemCount: data.length > 5 ? 5 : data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final imgId = (item.mid != null && item.mid != 0) ? item.mid! : item.id!;
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (_pageController.page! - index).abs();
                value = (1 - (value * 0.15)).clamp(0.0, 1.0);
              }
              return Center(
                child: Transform.scale(
                  scale: value,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const Detail2(), arguments: {'product': item, 'koreanName': koreanNames[item.id]}),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 15))
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                '${IpAddress.baseUrl}/productimage/view?pid=$imgId&position=main',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 40,
                              left: 30,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                    child: const Text("TOP PICK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    koreanNames[item.id] ?? item.ename,
                                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final item = data[index];
          final imgId = (item.mid != null && item.mid != 0) ? item.mid! : item.id!;
          return GestureDetector(
            onTap: () => Get.to(() => const Detail2(), arguments: {'product': item, 'koreanName': koreanNames[item.id]}),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage('${IpAddress.baseUrl}/productimage/view?pid=$imgId&position=main'),
                ),
                const SizedBox(height: 12),
                Text(item.ename.substring(0, item.ename.length > 10 ? 10 : item.ename.length), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final String? koreanName;

  const _ProductCard({required this.product, this.koreanName});

  @override
  Widget build(BuildContext context) {
    final int imageId = (product.mid != null && product.mid != 0) ? product.mid! : product.id!;
    final f = NumberFormat('###,###,###');

    return GestureDetector(
      onTap: () => Get.to(() => const Detail2(), arguments: {'product': product, 'koreanName': koreanName}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Hero(
                  tag: 'product_${product.id}',
                  child: Image.network(
                    '${IpAddress.baseUrl}/productimage/view?pid=$imageId&position=main',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            product.ename.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[400], letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            koreanName ?? product.ename,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            '${f.format(product.price)}원',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}