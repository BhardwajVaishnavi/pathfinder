import '../models/models.dart';
import '../services/database_service.dart';

class CategoryRepository {
  final DatabaseService _databaseService = DatabaseService();
  
  // Get all categories
  Future<List<Category>> getAllCategories() async {
    final results = await _databaseService.query(
      'SELECT * FROM categories ORDER BY id',
    );
    
    return results.map((row) => Category.fromMap(row)).toList();
  }
  
  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    final results = await _databaseService.query(
      'SELECT * FROM categories WHERE id = @id',
      parameters: {'id': id},
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return Category.fromMap(results.first);
  }
  
  // Create category
  Future<Category> createCategory(String name, String? description, String? icon) async {
    final results = await _databaseService.query(
      '''
      INSERT INTO categories (name, description, icon)
      VALUES (@name, @description, @icon)
      RETURNING id
      ''',
      parameters: {
        'name': name,
        'description': description,
        'icon': icon,
      },
    );
    
    final id = results.first['id'] as int;
    
    return Category(
      id: id,
      name: name,
      description: description,
      icon: icon,
    );
  }
  
  // Update category
  Future<Category> updateCategory(Category category) async {
    await _databaseService.execute(
      '''
      UPDATE categories
      SET name = @name, description = @description, icon = @icon
      WHERE id = @id
      ''',
      parameters: {
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'icon': category.icon,
      },
    );
    
    return category;
  }
  
  // Delete category
  Future<void> deleteCategory(int id) async {
    await _databaseService.execute(
      'DELETE FROM categories WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
