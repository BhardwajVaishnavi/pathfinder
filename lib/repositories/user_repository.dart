import '../models/models.dart';
import '../services/database_service.dart';

class UserRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new user
  Future<User> createUser(String name, String? email, String? phone, DateTime? dateOfBirth, Gender? gender) async {
    final now = DateTime.now();

    final results = await _databaseService.query(
      '''
      INSERT INTO users (
        name, email, phone, date_of_birth, gender,
        is_profile_complete, created_at
      )
      VALUES (
        @name, @email, @phone, @dateOfBirth, @gender,
        @isProfileComplete, @createdAt
      )
      RETURNING id
      ''',
      parameters: {
        'name': name,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender?.value,
        'isProfileComplete': false,
        'createdAt': now.toIso8601String(),
      },
    );

    final id = results.first['id'] as int;

    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      gender: gender,
      isProfileComplete: false,
      createdAt: now,
    );
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    final results = await _databaseService.query(
      'SELECT * FROM users WHERE id = @id',
      parameters: {'id': id},
    );

    if (results.isEmpty) {
      return null;
    }

    return User.fromMap(results.first);
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final results = await _databaseService.query(
      'SELECT * FROM users WHERE email = @email',
      parameters: {'email': email},
    );

    if (results.isEmpty) {
      return null;
    }

    return User.fromMap(results.first);
  }

  // Get user by phone
  Future<User?> getUserByPhone(String phone) async {
    final results = await _databaseService.query(
      'SELECT * FROM users WHERE phone = @phone',
      parameters: {'phone': phone},
    );

    if (results.isEmpty) {
      return null;
    }

    return User.fromMap(results.first);
  }

  // Update user
  Future<User> updateUser(User user) async {
    await _databaseService.execute(
      '''
      UPDATE users
      SET name = @name, email = @email, phone = @phone, date_of_birth = @dateOfBirth,
          gender = @gender, address = @address, city = @city, state = @state,
          country = @country, pincode = @pincode, identity_proof_type = @identityProofType,
          identity_proof_number = @identityProofNumber, identity_proof_image_path = @identityProofImagePath,
          is_profile_complete = @isProfileComplete
      WHERE id = @id
      ''',
      parameters: {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'dateOfBirth': user.dateOfBirth?.toIso8601String(),
        'gender': user.gender?.value,
        'address': user.address,
        'city': user.city,
        'state': user.state,
        'country': user.country,
        'pincode': user.pincode,
        'identityProofType': user.identityProofType,
        'identityProofNumber': user.identityProofNumber,
        'identityProofImagePath': user.identityProofImagePath,
        'isProfileComplete': user.isProfileComplete,
      },
    );

    return user;
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    await _databaseService.execute(
      'DELETE FROM users WHERE id = @id',
      parameters: {'id': id},
    );
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final results = await _databaseService.query('SELECT * FROM users');
    return results.map((map) => User.fromMap(map)).toList();
  }

  // Update user profile completion status
  Future<User> updateProfileCompletionStatus(int userId, bool isComplete) async {
    await _databaseService.execute(
      'UPDATE users SET is_profile_complete = @isComplete WHERE id = @id',
      parameters: {
        'id': userId,
        'isComplete': isComplete,
      },
    );

    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    return user.copyWith(isProfileComplete: isComplete);
  }

  // Update user identity proof
  Future<User> updateIdentityProof(
    int userId,
    String proofType,
    String proofNumber,
    String imagePath
  ) async {
    await _databaseService.execute(
      '''
      UPDATE users
      SET identity_proof_type = @proofType,
          identity_proof_number = @proofNumber,
          identity_proof_image_path = @imagePath
      WHERE id = @id
      ''',
      parameters: {
        'id': userId,
        'proofType': proofType,
        'proofNumber': proofNumber,
        'imagePath': imagePath,
      },
    );

    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    return user.copyWith(
      identityProofType: proofType,
      identityProofNumber: proofNumber,
      identityProofImagePath: imagePath,
    );
  }
}
