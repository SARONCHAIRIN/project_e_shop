import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/order_repository.dart';
import 'package:e_shop/data/models/order/order_model.dart';

/// Order History Screen - displays all user orders with pagination
class OrderHistoryScreen extends StatefulWidget {
  final OrderRepository orderRepository;

  const OrderHistoryScreen({
    super.key,
    required this.orderRepository,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadOrders(page: 1);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_currentPage < _totalPages && !_isLoadingMore) {
        _loadOrders(page: _currentPage + 1, loadMore: true);
      }
    }
  }

  Future<void> _loadOrders({required int page, bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final storage = TokenStorage();
      final userId = await storage.getUserId();
      final token = await storage.getToken();

      if (userId == null || token == null) {
        throw Exception('User not authenticated');
      }

      final result = await _orderRepository.getOrders(
        userId: userId,
        token: token,
        page: page,
        limit: 10,
      );

      setState(() {
        if (loadMore) {
          _orders.addAll(result.orders);
        } else {
          _orders = result.orders;
        }

        _currentPage = page;
        final pagination = result.pagination;
        _totalPages = ((pagination['total'] as int? ?? 0) / 10).ceil();
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
      setState(() => _error = 'Failed to load orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshOrders() async {
    _loadOrders(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(color: Colors.blue),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(
                      child: Text('No orders yet'),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshOrders,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _orders.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _orders.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: SpinKitCircle(
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                            );
                          }

                          final order = _orders[index] as dynamic;
                          return GestureDetector(
                            onTap: () {
                              if (order is OrderModel) {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => OrderDetailScreen(
                                //       order: order,
                                //       orderRepository: _orderRepository,
                                //     ),
                                //   ),
                                // );
                              }
                            },
                            // child: OrderCard(order: order),
                            child:Text('null'),
                          );
                        },
                      ),
                    ),
    );
  }

  OrderRepository get _orderRepository => widget.orderRepository;
}

