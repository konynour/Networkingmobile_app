import 'package:flutter/material.dart';
import 'package:network_project/Dio_Service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dio Service Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DioService _dioService = DioService();
  
  bool _loading = false;
  List<dynamic> _products = [];
  String _error = '';
  Map<String, dynamic>? _singleProduct;

  // Fetch all products
  Future<void> _fetchAllProducts() async {
    setState(() {
      _loading = true;
      _error = '';
      _singleProduct = null;
    });
    
    try {
      final products = await _dioService.getAllProducts();
      setState(() {
        _products = products ?? [];
      });
    } catch (e) {
      setState(() => _error = 'Error fetching products: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Fetch single product by ID
  Future<void> _fetchSingleProduct(int id) async {
    setState(() {
      _loading = true;
      _error = '';
      _products = [];
    });
    
    try {
      final product = await _dioService.getProductById(id);
      setState(() {
        _singleProduct = product;
      });
    } catch (e) {
      setState(() => _error = 'Error fetching product: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Add a new product
  Future<void> _addProduct() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      final newProduct = await _dioService.addProduct(
        title: 'New Amazing Product',
        price: 129.99,
        description: 'This is a brand new product added via Dio!',
        image: 'https://i.pravatar.cc/300',
        category: 'electronics',
      );
      
      if (newProduct != null) {
        setState(() {
          _singleProduct = newProduct;
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Product added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _error = 'Error adding product: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Update a product
  Future<void> _updateProduct(int id) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      final updated = await _dioService.updateProduct(
        id: id,
        title: 'Updated Product Title',
        price: 199.99,
        description: 'This product has been updated!',
        image: 'https://i.pravatar.cc/300',
        category: 'electronics',
      );
      
      if (updated != null) {
        setState(() {
          _singleProduct = updated;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Product updated successfully!'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _error = 'Error updating product: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Delete a product
  Future<void> _deleteProduct(int id) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      final success = await _dioService.deleteProduct(id);
      
      if (success) {
        setState(() {
          _singleProduct = null;
          _products = [];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Product deleted successfully!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _error = 'Error deleting product: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllProducts,
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _fetchAllProducts,
                  icon: const Icon(Icons.list),
                  label: const Text('Get All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _fetchSingleProduct(1),
                  icon: const Icon(Icons.inventory),
                  label: const Text('Get ID:1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _updateProduct(1),
                  icon: const Icon(Icons.edit),
                  label: const Text('Update ID:1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _deleteProduct(1),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete ID:1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            
            // Content Display
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, 
                                size: 64, 
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _singleProduct != null
                          ? _buildSingleProductView()
                          : _products.isNotEmpty
                              ? _buildProductsList()
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_bag_outlined,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Tap a button above to load data',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
            ),
          ],
        ),
      ),
    );
  }

  // Build single product view
  Widget _buildSingleProductView() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_singleProduct!['image'] != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _singleProduct!['image'],
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 64),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                _singleProduct!['title'] ?? 'No Title',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${_singleProduct!['price']}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(_singleProduct!['category'] ?? 'No Category'),
                backgroundColor: Colors.blue[100],
              ),
              const SizedBox(height: 12),
              Text(
                _singleProduct!['description'] ?? 'No Description',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'ID: ${_singleProduct!['id']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build products list view
  Widget _buildProductsList() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: product['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        );
                      },
                    ),
                  )
                : const Icon(Icons.image_not_supported),
            title: Text(
              product['title'] ?? 'No Title',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('\$${product['price']}'),
            trailing: Text(
              'ID: ${product['id']}',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () => _fetchSingleProduct(product['id']),
          ),
        );
      },
    );
  }
}