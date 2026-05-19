import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/order/order_card.dart';
import '../../../data/models/order/order_model.dart';
import '../../../data/models/order/order_status_enum.dart';
import '../../../data/repositories/order_repository.dart';
import 'order_detail_screen.dart';

/// TASK 11: Order History Screen
///
/// Features:
/// - Paginated order list (10 per page)
/// - Pull to refresh
/// - Status filter tabs
/// - Load more button / infinite scroll
/// - Empty state handling
/// - Error state with retry
class OrderHistoryScreen extends StatefulWidget {
  final int userId;
  final String token;

  const OrderHistoryScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  final OrderRepository _orderRepository = OrderRepository();
  final ScrollController _scrollController = ScrollController();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  static const int _pageLimit = 10;
  int _totalOrders = 0;
  bool _hasMore = true;

  // Filter state
  OrderStatus? _selectedStatusFilter;
  late TabController _tabController;

  static const List<_TabFilter> _filters = [
    _TabFilter(label: 'All', status: null),
    _TabFilter(label: 'Pending', status: OrderStatus.pending),
    _TabFilter(label: 'Processing', status: OrderStatus.processing),
    _TabFilter(label: 'Shipped', status: OrderStatus.shipped),
    _TabFilter(label: 'Delivered', status: OrderStatus.delivered),
    _TabFilter(label: 'Cancelled', status: OrderStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadOrders(refresh: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final filter = _filters[_tabController.index];
    setState(() {
      _selectedStatusFilter = filter.status;
    });
    _loadOrders(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (refresh) {
        _orders = [];
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      final result = await _orderRepository.getOrders(
        userId: widget.userId,
        token: widget.token,
        page: 1,
        limit: _pageLimit,
      );

      List<OrderModel> fetchedOrders = result.orders;

      // Client-side filter by status if selected
      if (_selectedStatusFilter != null) {
        fetchedOrders = fetchedOrders
            .where((o) => o.status == _selectedStatusFilter)
            .toList();
      }

      final total = result.pagination['total'] as int? ?? 0;

      setState(() {
        _orders = fetchedOrders;
        _totalOrders = total;
        _currentPage = 1;
        _hasMore = fetchedOrders.length >= _pageLimit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await _orderRepository.getOrders(
        userId: widget.userId,
        token: widget.token,
        page: nextPage,
        limit: _pageLimit,
      );

      List<OrderModel> newOrders = result.orders;

      if (_selectedStatusFilter != null) {
        newOrders = newOrders
            .where((o) => o.status == _selectedStatusFilter)
            .toList();
      }

      setState(() {
        _orders.addAll(newOrders);
        _currentPage = nextPage;
        _hasMore = newOrders.length >= _pageLimit;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load more orders.')),
        );
      }
    }
  }

  void _navigateToDetail(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          orderId: order.id,
          userId: widget.userId,
          token: widget.token,
        ),
      ),
    ).then((_) => _loadOrders(refresh: true)); // refresh after coming back
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: const Color(0xFF1E88E5),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF1E88E5),
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        tabs: _filters.map((f) => Tab(text: f.label)).toList(),
      ),
    );
  }

  Widget _buildOrderList() {
    if (_isLoading && _orders.isEmpty) {
      return _buildSkeletonList();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrders(refresh: true),
      color: const Color(0xFF1E88E5),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _orders.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _orders.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1E88E5),
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final order = _orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCard(
              orderId: order.id,
              status: order.status?.name.toUpperCase() ?? 'PENDING',
              totalPrice: order.totalAmount ?? 0.0,
              createdDate: order.createdAt ?? DateTime.now(),
              itemCount: order.items?.length ?? order.itemsCount ?? 0,
              onTap: () => _navigateToDetail(order),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _SkeletonOrderCard(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(44),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 44,
              color: Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedStatusFilter != null
                ? 'No ${_filters[_tabController.index].label} Orders'
                : 'No Orders Yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedStatusFilter != null
                ? 'You have no orders with this status.'
                : 'Start shopping to see your orders here.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Browse Products',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _loadOrders(refresh: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            if (_totalOrders > 0)
              Text(
                '$_totalOrders order${_totalOrders == 1 ? '' : 's'} total',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,
                size: 22, color: Color(0xFF1A1A2E)),
            onPressed: () => _loadOrders(refresh: true),
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildFilterTabs(),
        ),
      ),
      body: _buildOrderList(),
    );
  }
}

class _TabFilter {
  final String label;
  final OrderStatus? status;
  const _TabFilter({required this.label, required this.status});
}

// ─────────────────────────────────────────────
// Skeleton Loading Card
// ─────────────────────────────────────────────
class _SkeletonOrderCard extends StatefulWidget {
  @override
  State<_SkeletonOrderCard> createState() => _SkeletonOrderCardState();
}

class _SkeletonOrderCardState extends State<_SkeletonOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _skeletonBox(100, 16),
                  _skeletonBox(80, 24, radius: 20),
                ],
              ),
              const SizedBox(height: 14),
              _skeletonBox(140, 14),
              const SizedBox(height: 8),
              _skeletonBox(100, 14),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _skeletonBox(80, 14),
                  _skeletonBox(60, 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeletonBox(double width, double height, {double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}