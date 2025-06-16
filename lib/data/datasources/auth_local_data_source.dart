import 'package:wizi_learn/core/errors/exceptions.dart';
import 'package:wizi_learn/data/models/auth/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      // Implémentez votre logique de cache ici (SharedPreferences, Hive, etc.)
      // Exemple avec SharedPreferences:
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('cached_user', jsonEncode(user.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to cache user');
    }
  }

  @override
  Future<UserModel?> getLastUser() async {
    try {
      // Implémentez votre logique de récupération ici
      // Exemple:
      // final prefs = await SharedPreferences.getInstance();
      // final jsonString = prefs.getString('cached_user');
      // if (jsonString != null) {
      //   return UserModel.fromJson(jsonDecode(jsonString));
      // }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Implémentez votre logique de nettoyage ici
      // Exemple:
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.remove('cached_user');
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }
}