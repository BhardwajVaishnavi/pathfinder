class DatabaseConfig {
  // NeonDB PostgreSQL connection details
  static const String host = 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech';
  static const int port = 5432;
  static const String database = 'neondb';
  static const String username = 'neondb_owner';
  static const String password = 'npg_hPHsRAyS2XV5';
  static const bool useSSL = true;
  
  // Connection string
  static String get connectionString => 
      'postgresql://$username:$password@$host/$database?sslmode=${useSSL ? 'require' : 'disable'}';
}
