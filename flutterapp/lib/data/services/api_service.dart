import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';

/// Serviço de API usando Dio
/// Gerencia todas as requisições HTTP, interceptadores e tratamento de erros
class ApiService {
  late final Dio _dio;
  String? _authToken;

  static const String _baseUrl = 'http://172.25.176.1:5000';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        // Conexões via túnel podem ser lentas no 3G/4G, aumentei o timeout
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Tenta identificar o app para evitar bloqueios de navegador
          'User-Agent': 'FlutterApp/1.0',
          // Cabeçalho que às vezes ajuda a pular avisos de tunel (herdado do Ngrok/LocalTunnel)
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Adiciona o Token se estiver logado
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Sucesso
          return handler.next(response);
        },
        onError: (error, handler) {
          // Processa o erro antes de devolver para a tela
          final errorMessage = _handleError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: errorMessage,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  /// Define o Token de Autenticação (após login)
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Login do Usuário
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print("🔵 TENTANDO LOGIN: $_baseUrl/auth/login");

      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print("🟢 RESPOSTA: ${response.statusCode}");

      // 🔍 VERIFICAÇÃO DE BLOQUEIO DO TÚNEL
      // Se a resposta vier como String e tiver HTML, é a página de bloqueio da Microsoft.
      if (response.data is String) {
        final String dataStr = response.data;
        if (dataStr.contains('<!DOCTYPE html>') || dataStr.contains('<html')) {
          print("🔴 ERRO: Página de Aviso da Microsoft detectada.");
          throw DioException(
            requestOptions: response.requestOptions,
            error: "Bloqueio de segurança do Túnel. Abra a URL no navegador do celular e clique em 'Continue'.",
            type: DioExceptionType.badResponse,
          );
        }
        return jsonDecode(dataStr) as Map<String, dynamic>;
      }

      return response.data as Map<String, dynamic>;

    } catch (e) {
      print("🔴 ERRO NO LOGIN: $e");
      rethrow;
    }
  }

  /// Registro de Usuário
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required List<int> favoriteGenres,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'favoriteGenres': favoriteGenres,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se o token ainda é válido
  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Adicionar filme aos favoritos
  Future<void> addFavoriteMovie(int movieId) async {
    try {
      await _dio.post(
        '/user/add-movie',
        data: {'movieId': movieId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remover filme dos favoritos
  Future<void> removeFavoriteMovie(int movieId) async {
    try {
      await _dio.post(
        '/user/remove-movie',
        data: {'movieId': movieId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Perfil completo do usuário
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/user/me');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Atualizar perfil
  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    List<int>? favoriteGenres,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (favoriteGenres != null) data['favoriteGenres'] = favoriteGenres;

      final response = await _dio.patch(
        '/user/me',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Tratamento de Erros Personalizado
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'O servidor demorou a responder. Verifique sua conexão.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        // Tenta pegar a mensagem de erro do backend
        String? serverMessage;
        if (data is Map) {
          serverMessage = data['message'] ?? data['error'];
        }

        if (statusCode == 400) return serverMessage ?? 'Dados inválidos.';
        if (statusCode == 401) return 'Senha incorreta ou sessão expirada.';
        if (statusCode == 404) return 'Recurso não encontrado.';
        if (statusCode == 500) return 'Erro interno no servidor.';
        if (statusCode == 502 || statusCode == 503) {
          return 'O Túnel está online, mas sua API local parece desligada.';
        }

        return serverMessage ?? 'Erro desconhecido ($statusCode).';

      case DioExceptionType.connectionError:
        return 'Falha na conexão. O túnel pode estar offline ou a URL mudou.';

      default:
        return error.error.toString(); // Retorna a mensagem manual que criamos no throw
    }
  }
}