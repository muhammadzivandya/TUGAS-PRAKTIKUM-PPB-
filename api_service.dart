import 'package:dio/dio.dart';
import 'models/product.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://dummyjson.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  AppException _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return AppException('Koneksi internet terputus atau sangat lambat. Silakan coba lagi.');
      }
      return AppException('Terjadi kesalahan pada server (${error.response?.statusCode ?? "Unknown"}).');
    }
    return AppException('Terjadi kesalahan yang tidak terduga.');
  }

  Future<Map<String, dynamic>> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit, 'skip': skip};
      if (sortBy != null) query['sortBy'] = sortBy;
      if (order != null) query['order'] = order;

      final res = await _dio.get('/products', queryParameters: query);
      final list = (res.data['products'] as List).map((e) => Product.fromJson(e)).toList();
      return {'products': list, 'total': res.data['total'] as int};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final res = await _dio.get('/products', queryParameters: {'limit': 0});
      return (res.data['products'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final res = await _dio.get('/products/$id');
      return Product.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> searchProducts(String query, {CancelToken? cancelToken}) async {
    try {
      final res = await _dio.get('/products/search',
          queryParameters: {'q': query}, cancelToken: cancelToken);
      return (res.data['products'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      if (DioExceptionType.cancel == (e as DioException).type) {
        return [];
      }
      throw _handleError(e);
    }
  }

  Future<List<String>> getCategoryList() async {
    try {
      final res = await _dio.get('/products/category-list');
      return (res.data as List).map((e) => e.toString()).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> getProductsByCategory(String slug) async {
    try {
      final res = await _dio.get('/products/category/$slug');
      return (res.data['products'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
}
