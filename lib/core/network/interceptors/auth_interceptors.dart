// import 'package:dio/dio.dart';
// import '../../storage/token_storage.dart';
//
// /// Dio interceptor for automatic token management and refresh.
// ///
// /// Responsibilities:
// /// - Attach access token to all outgoing requests
// /// - Handle 401 (Unauthorized) responses by attempting token refresh
// /// - Retry failed requests with new token
// /// - Prevent infinite refresh loops with locking
// class AuthInterceptor extends Interceptor {
//   final TokenStorage tokenStorage;
//   final Dio dio;
//
//   /// Track if we're currently refreshing to prevent concurrent refresh attempts
//   bool _isRefreshing = false;
//
//   /// Queue of requests pending token refresh
//   final List<_RequestRetry> _requestQueue = [];
//
//   AuthInterceptor({required this.tokenStorage, required this.dio});
//
//   @override
//   Future<void> onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) async {
//     try {
//       final accessToken = await tokenStorage.readToken();
//       if (accessToken != null && accessToken.isNotEmpty) {
//         options.headers['Authorization'] = 'Bearer $accessToken';
//       }
//     } catch (e) {
//       print('Error reading token: $e');
//     }
//     return handler.next(options);
//   }
//
//   @override
//   Future<void> onError(
//     DioException err,
//     ErrorInterceptorHandler handler,
//   ) async {
//     // Only handle 401 Unauthorized responses
//     if (err.response?.statusCode != 401) {
//       return handler.next(err);
//     }
//
//     // If no refresh token, just propagate the error
//     final refreshToken = await tokenStorage.readRefreshToken();
//     if (refreshToken == null || refreshToken.isEmpty) {
//       return handler.next(err);
//     }
//
//     // Start refresh flow only once
//     if (!_isRefreshing) {
//       _isRefreshing = true;
//
//       try {
//         // Attempt to refresh the access token
//         final response = await dio.post(
//           '/api/v1/public/refresh',
//           data: {'refreshToken': refreshToken},
//         );
//
//         if (response.statusCode == 200) {
//           final newAccessToken = response.data['access_token'] as String?;
//           final newRefreshToken = response.data['refresh_token'] as String?;
//
//           if (newAccessToken != null && newAccessToken.isNotEmpty) {
//             // Save new tokens
//             await tokenStorage.writeToken(newAccessToken);
//             if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
//               await tokenStorage.writeRefreshToken(newRefreshToken);
//             }
//
//             // Retry original request with new token
//             final originalRequest = err.requestOptions;
//             originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
//
//             // Retry all queued requests
//             final retryFutures = _requestQueue.map((req) async {
//               req.options.headers['Authorization'] = 'Bearer $newAccessToken';
//               return dio.fetch(req.options);
//             }).toList();
//
//             // Execute all retries
//             if (retryFutures.isNotEmpty) {
//               await Future.wait(retryFutures);
//             }
//
//             _requestQueue.clear();
//
//             // Retry the original failed request
//             final retryResponse = await dio.fetch(originalRequest);
//             return handler.resolve(retryResponse);
//           }
//         }
//
//         print('Token refresh failed with status ${response.statusCode}');
//         // Clear tokens if refresh failed
//         await tokenStorage.clearAll();
//         return handler.next(err);
//       } catch (e) {
//         print('Error during token refresh: $e');
//         // Clear tokens on refresh error
//         await tokenStorage.clearAll();
//         return handler.next(err);
//       } finally {
//         _isRefreshing = false;
//       }
//     } else {
//       // If already refreshing, queue this request
//       _requestQueue.add(_RequestRetry(err.requestOptions));
//
//       // Wait for refresh to complete, then retry
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       final newToken = await tokenStorage.readToken();
//       if (newToken != null && newToken.isNotEmpty) {
//         err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
//         try {
//           final retryResponse = await dio.fetch(err.requestOptions);
//           return handler.resolve(retryResponse);
//         } catch (retryErr) {
//           return handler.next(err);
//         }
//       }
//
//       return handler.next(err);
//     }
//   }
// }
//
// /// Helper class to track requests pending token refresh
// class _RequestRetry {
//   final RequestOptions options;
//   _RequestRetry(this.options);
// }
//
//
