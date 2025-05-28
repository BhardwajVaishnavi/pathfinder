import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/database_service.dart';

class DatabaseMigration {
  final DatabaseService _databaseService = DatabaseService();
  
  Future<void> migrate() async {
    if (kIsWeb) {
      print('Running on web platform, skipping database migration');
      return;
    }
    
    try {
      await _databaseService.connect();
      
      // Add identity proof fields to users table
      await _addIdentityProofFields();
      
      print('Database migration completed successfully');
    } catch (e) {
      print('Error during database migration: $e');
      rethrow;
    }
  }
  
  Future<void> _addIdentityProofFields() async {
    try {
      // Check if identity_proof_type column exists
      final columns = await _databaseService.query(
        "SELECT column_name FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'identity_proof_type'",
      );
      
      if (columns.isEmpty) {
        // Add identity proof fields
        await _databaseService.execute('''
          ALTER TABLE users 
          ADD COLUMN identity_proof_type VARCHAR(50),
          ADD COLUMN identity_proof_number VARCHAR(50),
          ADD COLUMN identity_proof_image_path TEXT,
          ADD COLUMN is_profile_complete BOOLEAN DEFAULT FALSE
        ''');
        
        print('Added identity proof fields to users table');
      } else {
        print('Identity proof fields already exist in users table');
      }
    } catch (e) {
      print('Error adding identity proof fields: $e');
      rethrow;
    }
  }
}
