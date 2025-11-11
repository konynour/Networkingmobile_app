import 'dart:developer';
import 'package:dio/dio.dart';

class DioService {
  // Singleton pattern for single instance
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;
  
  late final Dio dio;
  
  // Base URL - change this to your API
  static const String baseUrl = 'https://fakestoreapi.com';
  
  DioService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors for logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log(' REQUEST[${options.method}] => ${options.uri}');
          log('Headers: ${options.headers}');
          log('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log(' RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          log('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          log(' ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
          log('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }
  
  // ==================== GET REQUESTS ====================
  
  /// Get all products
  Future<List<dynamic>?> getAllProducts() async {
    try {
      final response = await dio.get('/products');
      
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  /// Get single product by ID
  Future<Map<String, dynamic>?> getProductById(int id) async {
    try {
      final response = await dio.get('/products/$id');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  /// Get products by category
  Future<List<dynamic>?> getProductsByCategory(String category) async {
    try {
      final response = await dio.get('/products/category/$category');
      
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  // ==================== POST REQUESTS ====================
  
  /// Add new product
  Future<Map<String, dynamic>?> addProduct({
    required String title,
    required double price,
    required String description,
    required String image,
    required String category,
  }) async {
    try {
      final response = await dio.post(
        '/products',
        data: {
          'title': title,
          'price': price,
          'description': description,
          'image': image,
          'category': category,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Product added successfully!');
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  // ==================== PUT REQUESTS ====================
  
  /// Update entire product
  Future<Map<String, dynamic>?> updateProduct({
    required int id,
    required String title,
    required double price,
    required String description,
    required String image,
    required String category,
  }) async {
    try {
      final response = await dio.put(
        '/products/$id',
        data: {
          'title': title,
          'price': price,
          'description': description,
          'image': image,
          'category': category,
        },
      );
      
      if (response.statusCode == 200) {
        log(' Product updated successfully!');
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  // ==================== PATCH REQUESTS ====================
  
  /// Update product partially
  Future<Map<String, dynamic>?> patchProduct({
    required int id,
    Map<String, dynamic>? updates,
  }) async {
    try {
      final response = await dio.patch(
        '/products/$id',
        data: updates,
      );
      
      if (response.statusCode == 200) {
        log(' Product patched successfully!');
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  // ==================== DELETE REQUESTS ====================
  
  /// Delete product
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await dio.delete('/products/$id');
      
      if (response.statusCode == 200) {
        log('Product deleted successfully!');
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }
  
  // ==================== ADVANCED FEATURES ====================
  
  /// Download file with progress
  Future<bool> downloadFile({
    required String url,
    required String savePath,
    Function(int, int)? onProgress,
  }) async {
    try {
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            log(' Download Progress: $progress%');
            onProgress?.call(received, total);
          }
        },
      );
      log(' File downloaded successfully!');
      return true;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }
  
  /// Upload file
  Future<Map<String, dynamic>?> uploadFile({
    required String filePath,
    required String endpoint,
  }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      
      final response = await dio.post(endpoint, data: formData);
      
      if (response.statusCode == 200) {
        log(' File uploaded successfully!');
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  /// Request with custom headers
  Future<Response?> requestWithHeaders({
    required String endpoint,
    required String method,
    Map<String, dynamic>? headers,
    dynamic data,
  }) async {
    try {
      final response = await dio.request(
        endpoint,
        data: data,
        options: Options(
          method: method,
          headers: headers,
        ),
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  /// Request with query parameters
  Future<Response?> requestWithQueryParams({
    required String endpoint,
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  // ==================== ERROR HANDLING ====================
  
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        log(' Connection Timeout!');
        break;
      case DioExceptionType.sendTimeout:
        log('Send Timeout!');
        break;
      case DioExceptionType.receiveTimeout:
        log(' Receive Timeout!');
        break;
      case DioExceptionType.badResponse:
        log('Bad Response: ${error.response?.statusCode}');
        log('Message: ${error.response?.data}');
        break;
      case DioExceptionType.cancel:
        log(' Request Cancelled!');
        break;
      case DioExceptionType.connectionError:
        log(' No Internet Connection!');
        break;
      case DioExceptionType.badCertificate:
        log(' Bad Certificate!');
        break;
      case DioExceptionType.unknown:
        log(' Unknown Error: ${error.message}');
        break;
    }
  }
  
  // ==================== UTILITY METHODS ====================
  
  /// Cancel all pending requests
  void cancelAllRequests() {
    dio.close(force: true);
  }
  
  /// Set authorization token
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  /// Clear authorization token
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}

// ==================== USAGE EXAMPLE ====================

void exampleUsage() async {
  final dioService = DioService();
  
  // GET all products
  final products = await dioService.getAllProducts();
  log('Products: $products');
  
  // GET single product
  final product = await dioService.getProductById(1);
  log('Product: $product');
  
  // POST - Add product
  final newProduct = await dioService.addProduct(
    title: 'Amazing Product',
    price: 99.99,
    description: 'This is an amazing product',
    image: 'https://i.pravatar.cc',
    category: 'electronics',
  );
  log('New Product: $newProduct');
  
  // PUT - Update product
  final updated = await dioService.updateProduct(
    id: 1,
    title: 'Updated Product',
    price: 149.99,
    description: 'Updated description',
    image: 'https://i.pravatar.cc',
    category: 'electronics',
  );
  log('Updated: $updated');
  
  // PATCH - Partial update
  final patched = await dioService.patchProduct(
    id: 1,
    updates: {'price': 199.99},
  );
  log('Patched: $patched');
  
  // DELETE product
  final deleted = await dioService.deleteProduct(1);
  log('Deleted: $deleted');
  
  // Set auth token
  dioService.setAuthToken('your_token_here');
  
  // Request with query params
  final filtered = await dioService.requestWithQueryParams(
    endpoint: '/products',
    queryParams: {'limit': 5, 'sort': 'desc'},
  );
  log('Filtered: ${filtered?.data}');
}