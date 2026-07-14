// import 'package:flutter/foundation.dart';
//
// import '../../../data/models/order/order_model.dart';
// import '../../../data/models/order/order_status_enum.dart';
// import '../../../data/repositories/order_repository.dart';
//
// // ─────────────────────────────────────────────────────────────
// // Order List State
// // ─────────────────────────────────────────────────────────────
//
// enum OrderListState { idle, loading, loadingMore, loaded, error }
//
// enum OrderDetailState { idle, loading, loaded, error }
//
// enum OrderCancelState { idle, confirming, cancelling, success, error }
//
// // ─────────────────────────────────────────────────────────────
// // TASK 14: OrderController
// // ─────────────────────────────────────────────────────────────
//
// /// Manages order history list, detail view, and cancellation.
// ///
// /// Usage with Provider:
// /// ```dart
// /// ChangeNotifierProvider(
// ///   create: (_) => OrderController(),
// ///   child: OrderHistoryScreen(...),
// /// )
// /// ```
// class OrderController extends ChangeNotifier {
//   final OrderRepository _repository;
//
//   OrderController({OrderRepository? repository})
//     : _repository = repository ?? OrderRepository();
//
//   // ── List State ────────────────────────────────────────────
//
//   OrderListState _listState = OrderListState.idle;
//   List<OrderModel> _orders = [];
//   String? _listError;
//   int _currentPage = 1;
//   static const int _pageLimit = 10;
//   int _totalOrders = 0;
//   bool _hasMore = true;
//   OrderStatus? _statusFilter;
//
//   // ── Detail State ──────────────────────────────────────────
//
//   OrderDetailState _detailState = OrderDetailState.idle;
//   OrderModel? _selectedOrder;
//   String? _detailError;
//
//   // ── Cancel State ──────────────────────────────────────────
//
//   OrderCancelState _cancelState = OrderCancelState.idle;
//   String? _cancelError;
//
//   // ── Getters: List ─────────────────────────────────────────
//
//   OrderListState get listState => _listState;
//
//   List<OrderModel> get orders => List.unmodifiable(_orders);
//
//   String? get listError => _listError;
//
//   int get totalOrders => _totalOrders;
//
//   bool get hasMore => _hasMore;
//
//   bool get isLoadingList => _listState == OrderListState.loading;
//
//   bool get isLoadingMore => _listState == OrderListState.loadingMore;
//
//   OrderStatus? get statusFilter => _statusFilter;
//
//   // ── Getters: Detail ───────────────────────────────────────
//
//   OrderDetailState get detailState => _detailState;
//
//   OrderModel? get selectedOrder => _selectedOrder;
//
//   String? get detailError => _detailError;
//
//   bool get isLoadingDetail => _detailState == OrderDetailState.loading;
//
//   // ── Getters: Cancel ───────────────────────────────────────
//
//   OrderCancelState get cancelState => _cancelState;
//
//   String? get cancelError => _cancelError;
//
//   bool get isCancelling => _cancelState == OrderCancelState.cancelling;
//
//   // ── Convenience ───────────────────────────────────────────
//
//   bool get canCancelSelected => _selectedOrder?.status == OrderStatus.pending;
//
//   // ─────────────────────────────────────────────────────────
//   // Order List Methods
//   // ─────────────────────────────────────────────────────────
//
//   /// Loads the first page of orders, optionally filtering by status.
//   Future<void> fetchOrders({
//     required int userId,
//     required String token,
//     bool refresh = false,
//   }) async {
//     if (_listState == OrderListState.loading) return;
//
//     if (refresh) {
//       _currentPage = 1;
//       _hasMore = true;
//       _orders = [];
//     }
//
//     _listState = OrderListState.loading;
//     _listError = null;
//     notifyListeners();
//
//     try {
//       final result = await _repository.getOrders(
//         userId: userId,
//         token: token,
//         page: 1,
//         limit: _pageLimit,
//       );
//
//       var fetched = result.orders;
//
//       if (_statusFilter != null) {
//         fetched = fetched.where((o) => o.status == _statusFilter).toList();
//       }
//
//       _orders = fetched;
//       _totalOrders = result.pagination['total'] as int? ?? 0;
//       _currentPage = 1;
//       _hasMore = fetched.length >= _pageLimit;
//       _listState = OrderListState.loaded;
//     } catch (e) {
//       _listError = _cleanError(e);
//       _listState = OrderListState.error;
//     }
//
//     notifyListeners();
//   }
//
//   /// Loads the next page and appends to the existing list.
//   Future<void> loadMore({required int userId, required String token}) async {
//     if (!_hasMore) return;
//     if (_listState == OrderListState.loadingMore) return;
//     if (_listState == OrderListState.loading) return;
//
//     _listState = OrderListState.loadingMore;
//     notifyListeners();
//
//     try {
//       final nextPage = _currentPage + 1;
//       final result = await _repository.getOrders(
//         userId: userId,
//         token: token,
//         page: nextPage,
//         limit: _pageLimit,
//       );
//
//       var fetched = result.orders;
//
//       if (_statusFilter != null) {
//         fetched = fetched.where((o) => o.status == _statusFilter).toList();
//       }
//
//       _orders = [..._orders, ...fetched];
//       _currentPage = nextPage;
//       _hasMore = fetched.length >= _pageLimit;
//       _listState = OrderListState.loaded;
//     } catch (e) {
//       // Don't wipe the list — just stop loading more
//       _listState = OrderListState.loaded;
//       debugPrint('OrderController: loadMore error: $e');
//     }
//
//     notifyListeners();
//   }
//
//   /// Sets a status filter and re-fetches.
//   Future<void> setStatusFilter({
//     required OrderStatus? status,
//     required int userId,
//     required String token,
//   }) async {
//     if (_statusFilter == status) return;
//     _statusFilter = status;
//     await fetchOrders(userId: userId, token: token, refresh: true);
//   }
//
//   /// Clears the status filter and re-fetches all orders.
//   Future<void> clearFilter({required int userId, required String token}) async {
//     _statusFilter = null;
//     await fetchOrders(userId: userId, token: token, refresh: true);
//   }
//
//   // ─────────────────────────────────────────────────────────
//   // Order Detail Methods
//   // ─────────────────────────────────────────────────────────
//
//   /// Fetches full order detail including items and address.
//   Future<void> fetchOrderDetail({
//     required int orderId,
//     required String token,
//   }) async {
//     _detailState = OrderDetailState.loading;
//     _detailError = null;
//     _selectedOrder = null;
//     notifyListeners();
//
//     try {
//       final order = await _repository.getOrderDetail(
//         orderId: orderId,
//         token: token,
//       );
//       _selectedOrder = order;
//       _detailState = OrderDetailState.loaded;
//     } catch (e) {
//       _detailError = _cleanError(e);
//       _detailState = OrderDetailState.error;
//     }
//
//     notifyListeners();
//   }
//
//   /// Updates a specific order in the list (e.g. after status change).
//   void updateOrderInList(OrderModel updated) {
//     final index = _orders.indexWhere((o) => o.id == updated.id);
//     if (index != -1) {
//       _orders = List.from(_orders)..[index] = updated;
//       notifyListeners();
//     }
//   }
//
//   /// Clears the selected order detail (e.g. when leaving detail screen).
//   void clearDetail() {
//     _selectedOrder = null;
//     _detailState = OrderDetailState.idle;
//     _detailError = null;
//     notifyListeners();
//   }
//
//   // ─────────────────────────────────────────────────────────
//   // Cancel Methods
//   // ─────────────────────────────────────────────────────────
//
//   /// Cancels an order. Only works for PENDING orders.
//   ///
//   /// On success:
//   /// - Updates [selectedOrder] status to cancelled
//   /// - Updates the matching order in [orders] list
//   /// - Sets [cancelState] to success
//   Future<void> cancelOrder({
//     required int orderId,
//     required int userId,
//     required String token,
//   }) async {
//     // Guard: validate status before API call
//     final target = _selectedOrder?.id == orderId
//         ? _selectedOrder
//         : _orders.firstWhere(
//             (o) => o.id == orderId,
//             orElse: () => OrderModel(id: orderId),
//           );
//
//     if (target?.status != OrderStatus.pending) {
//       _cancelError = 'Only pending orders can be cancelled.';
//       _cancelState = OrderCancelState.error;
//       notifyListeners();
//       return;
//     }
//
//     _cancelState = OrderCancelState.cancelling;
//     _cancelError = null;
//     notifyListeners();
//
//     try {
//       final cancelled = await _repository.cancelOrder(
//         orderId: orderId,
//         userId: userId,
//         token: token,
//       );
//
//       // Update detail view
//       if (_selectedOrder?.id == orderId) {
//         _selectedOrder = cancelled;
//       }
//
//       // Update list
//       updateOrderInList(cancelled);
//
//       _cancelState = OrderCancelState.success;
//     } catch (e) {
//       _cancelError = _cleanError(e);
//       _cancelState = OrderCancelState.error;
//     }
//
//     notifyListeners();
//   }
//
//   /// Resets cancel state (call after showing success/error UI).
//   void resetCancelState() {
//     _cancelState = OrderCancelState.idle;
//     _cancelError = null;
//     notifyListeners();
//   }
//
//   // ─────────────────────────────────────────────────────────
//   // Helpers
//   // ─────────────────────────────────────────────────────────
//
//   String _cleanError(Object e) => e.toString().replaceFirst('Exception: ', '');
//
//   /// Full reset — use when logging out.
//   void resetAll() {
//     _listState = OrderListState.idle;
//     _orders = [];
//     _listError = null;
//     _currentPage = 1;
//     _totalOrders = 0;
//     _hasMore = true;
//     _statusFilter = null;
//     _detailState = OrderDetailState.idle;
//     _selectedOrder = null;
//     _detailError = null;
//     _cancelState = OrderCancelState.idle;
//     _cancelError = null;
//     notifyListeners();
//   }
// }
