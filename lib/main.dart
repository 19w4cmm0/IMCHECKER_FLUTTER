import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'screens/statistics_screen.dart';
import 'utils/token_manager.dart'; // Import TokenManager từ file riêng

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập đầy đủ thông tin!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://checker-api-vysh.vercel.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        await TokenManager.saveToken(token);
        await TokenManager.saveUserId(userData['_id']);
        await TokenManager.saveUserData(userData);

        _showSuccessSnackBar('Đăng nhập thành công!');

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorSnackBar(errorData['message'] ?? 'Đăng nhập thất bại!');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi kết nối, vui lòng thử lại!');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Text Processor',
                style: TextStyle(
                  color: Color(0xFFE15A46),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập để sử dụng dịch vụ',
                style: TextStyle(
                  color: Color(0x8FFFFFFF),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Tên đăng nhập',
                  hintStyle: const TextStyle(color: Color(0x8FFFFFFF)),
                  filled: true,
                  fillColor: const Color(0xFF232323),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE15A46)),
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0x8FFFFFFF),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  hintStyle: const TextStyle(color: Color(0x8FFFFFFF)),
                  filled: true,
                  fillColor: const Color(0xFF232323),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE15A46)),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0x8FFFFFFF),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0x8FFFFFFF),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE15A46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await TokenManager.saveToken('demo_token_123');
                  await TokenManager.saveUserId('demo_user_id');
                  await TokenManager.saveUserData({
                    '_id': 'demo_user_id',
                    'username': 'demo_user',
                    'email': 'demo@example.com',
                  });

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: const Text(
                  'Đăng nhập demo (cho test)',
                  style: TextStyle(
                    color: Color(0x8FFFFFFF),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class Language {
  final String code;
  final String name;
  final String flag;

  Language({required this.code, required this.name, required this.flag});
}

class TextAreaModel {
  final String id;
  String text;
  String? result;
  String status;

  TextAreaModel({
    required this.id,
    required this.text,
    this.result,
    this.status = 'normal',
  });
}

enum ProcessorType { grammar, translate, summarize }

class TextProcessorScreen extends StatefulWidget {
  final String title;
  final String apiGet;
  final String apiType;
  final String apiSave;
  final ProcessorType type;
  final String buttonLabel;
  final bool? targetLanguage;

  const TextProcessorScreen({
    Key? key,
    required this.title,
    required this.apiGet,
    required this.apiType,
    required this.apiSave,
    required this.type,
    required this.buttonLabel,
    this.targetLanguage = false,
  }) : super(key: key);

  @override
  _TextProcessorScreenState createState() => _TextProcessorScreenState();
}

class _TextProcessorScreenState extends State<TextProcessorScreen> {
  List<TextAreaModel> textAreas = [];
  String? userId;
  String selectedLanguage = 'English';

  final List<Language> languages = [
    Language(code: "English", name: "Tiếng Anh", flag: "🇺🇸"),
    Language(code: "Vietnamese", name: "Tiếng Việt", flag: "🇻🇳"),
    Language(code: "Chinese", name: "Tiếng Trung", flag: "🇨🇳"),
    Language(code: "Japanese", name: "Tiếng Nhật", flag: "🇯🇵"),
    Language(code: "Korean", name: "Tiếng Hàn", flag: "🇰🇷"),
    Language(code: "French", name: "Tiếng Pháp", flag: "🇫🇷"),
    Language(code: "German", name: "Tiếng Đức", flag: "🇩🇪"),
    Language(code: "Spanish", name: "Tiếng Tây Ban Nha", flag: "🇪🇸"),
    Language(code: "Portuguese", name: "Tiếng Bồ Đào Nha", flag: "🇵🇹"),
    Language(code: "Italian", name: "Tiếng Ý", flag: "🇮🇹"),
    Language(code: "Russian", name: "Tiếng Nga", flag: "🇷🇺"),
    Language(code: "Thai", name: "Tiếng Thái", flag: "🇹🇭"),
    Language(code: "Indonesian", name: "Tiếng Indonesia", flag: "🇮🇩"),
    Language(code: "Malay", name: "Tiếng Malaysia", flag: "🇲🇾"),
    Language(code: "Hindi", name: "Tiếng Hindi", flag: "🇮🇳"),
    Language(code: "Arabic", name: "Tiếng Ả Rập", flag: "🇸🇦"),
  ];

  @override
  void initState() {
    super.initState();
    textAreas.add(TextAreaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
    ));
    print('Initial textAreas length: ${textAreas.length}');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = await TokenManager.getToken();
      final cachedUserId = await TokenManager.getUserId();
      final cachedUserData = await TokenManager.getUserData();

      if (token == 'demo_token_123') {
        setState(() {
          userId = cachedUserId ?? 'demo_user_id';
        });
        await _fetchSavedData();
      } else if (token != null && cachedUserId != null && cachedUserData != null) {
        setState(() {
          userId = cachedUserId;
        });
        await _fetchSavedData();
      } else if (token != null) {
        await _fetchUserInfo(token);
        if (userId != null) {
          await _fetchSavedData();
        }
      } else {
        throw Exception('Không tìm thấy token!');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải dữ liệu người dùng: $e');
      await _handleTokenExpired();
    }
  }

  Future<void> _handleTokenExpired() async {
    await TokenManager.removeToken();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _fetchUserInfo(String token) async {
    try {
      final response = await http.post(
        Uri.parse('https://checker-api-vysh.vercel.app/api/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'tokenUser': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Kiểm tra nếu có trường "data", nếu không thì dùng dữ liệu trực tiếp
        final userData = data['data'] ?? data;
        final newUserId = userData['_id'];

        if (newUserId == null) {
          throw Exception('Không tìm thấy user ID trong phản hồi!');
        }

        setState(() {
          userId = newUserId;
        });

        await TokenManager.saveUserId(newUserId);
        await TokenManager.saveUserData(userData);
      } else if (response.statusCode == 401) {
        await _handleTokenExpired();
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching user info: $e');
      if (e.toString().contains('401')) {
        await _handleTokenExpired();
      }
      rethrow;
    }
  }

  Future<void> _fetchSavedData() async {
    if (userId == 'demo_user_id') {
      setState(() {
        textAreas = [
          TextAreaModel(
            id: 'demo_1',
            text: 'Đây là văn bản demo',
            result: 'Kết quả demo',
            status: 'success',
          ),
          TextAreaModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: '',
          ),
        ];
        print('textAreas length after fetch: ${textAreas.length}');
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://checker-api-vysh.vercel.app/api/${widget.apiGet}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            final savedItems = (data['data'] as List).map((item) => TextAreaModel(
              id: item['_id'],
              text: item['content'],
              result: item['result'],
              status: 'success',
            )).toList();
            textAreas = [...savedItems, ...textAreas];
          });
        }
      }
    } catch (e) {
      print('Error fetching saved data: $e');
    }
  }

  Future<void> _processText(String id) async {
    final textAreaIndex = textAreas.indexWhere((area) => area.id == id);
    if (textAreaIndex == -1) return;

    setState(() {
      textAreas[textAreaIndex].status = 'load';
    });

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _showErrorSnackBar('Không tìm thấy token, vui lòng đăng nhập lại!');
        await _handleTokenExpired();
        return;
      }

      final requestData = <String, dynamic>{
        'text': textAreas[textAreaIndex].text,
      };

      if (widget.targetLanguage == true && widget.type == ProcessorType.translate) {
        requestData['targetLanguage'] = selectedLanguage;
      }

      final response = await http.post(
        Uri.parse('https://checker-api-vysh.vercel.app/api/text/${widget.apiType}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm token vào header
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'] as String;

        setState(() {
          textAreas[textAreaIndex].result = result;
          textAreas[textAreaIndex].status = 'success';
        });

        if (userId != null) {
          await _saveToDatabase(textAreas[textAreaIndex]);
        }
      } else {
        _handleApiError(response.statusCode);
        setState(() {
          textAreas[textAreaIndex].status = 'normal';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi kết nối, vui lòng kiểm tra server!');
      setState(() {
        textAreas[textAreaIndex].status = 'normal';
      });
    }
  }

  Future<void> _saveToDatabase(TextAreaModel textArea) async {
    try {
      await http.post(
        Uri.parse('https://checker-api-vysh.vercel.app/api/${widget.apiSave}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          '_id': textArea.id,
          'content': textArea.text,
          'result': textArea.result,
          'userId': userId,
        }),
      );
    } catch (e) {
      print('Error saving to database: $e');
    }
  }

  void _handleApiError(int statusCode) {
    String message;
    switch (statusCode) {
      case 429:
        message = 'Quá nhiều yêu cầu, vui lòng thử lại sau vài phút!';
        break;
      case 400:
        message = 'Yêu cầu không hợp lệ!';
        break;
      case 401:
        message = 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!';
        _handleTokenExpired();
        return;
      default:
        message = 'Đã có lỗi xảy ra, vui lòng thử lại!';
    }
    _showErrorSnackBar(message);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addTextArea() {
    setState(() {
      textAreas.add(TextAreaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '',
      ));
    });
  }

  void _deleteTextArea(String id) async {
    if (textAreas.length > 1) {
      setState(() {
        textAreas.removeWhere((area) => area.id == id);
      });

      try {
        await http.delete(
          Uri.parse('https://checker-api-vysh.vercel.app/api/${widget.type.name}/delete${widget.type.name}/$id'),
        );
      } catch (e) {
        print('Error deleting from database: $e');
      }
    } else {
      _showErrorSnackBar('Phải có ít nhất một ô văn bản!');
    }
  }

  void _handleDismiss(String id) {
    setState(() {
      final index = textAreas.indexWhere((area) => area.id == id);
      if (index != -1) {
        textAreas[index].text = '';
        textAreas[index].result = null;
        textAreas[index].status = 'normal';
      }
    });
  }

  void _handleAccept(String id) {
    setState(() {
      final index = textAreas.indexWhere((area) => area.id == id);
      if (index != -1 && textAreas[index].result != null) {
        String result = textAreas[index].result!;
        if (result.startsWith('"') && result.endsWith('"')) {
          result = result.substring(1, result.length - 1);
        }
        textAreas[index].text = result;
        textAreas[index].result = null;
        textAreas[index].status = 'normal';
      }
    });
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSuccessSnackBar('Đã sao chép!');
  }

  void _updateText(String id, String newText) {
    setState(() {
      final index = textAreas.indexWhere((area) => area.id == id);
      if (index != -1) {
        textAreas[index].text = newText;
      }
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232323),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(color: Color(0x8FFFFFFF)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color(0x8FFFFFFF)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await TokenManager.removeToken();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE15A46),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFFE15A46),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: const Color(0x8FFFFFFF),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text(
                'Cải thiện văn bản của bạn với công cụ miễn phí tiên tiến này.',
                style: TextStyle(
                  color: Color(0x8FFFFFFF),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (textAreas.isEmpty)
              const Text(
                'Không có ô văn bản nào!',
                style: TextStyle(color: Colors.white),
              ),
            ...textAreas.asMap().entries.map((entry) {
              final index = entry.key;
              final textArea = entry.value;
              return _buildTextAreaCard(textArea, index);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAreaCard(TextAreaModel textArea, int index) {
    print('Building TextAreaCard: ${textArea.id}, Text: ${textArea.text}, Result: ${textArea.result}');
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 120,
                        maxHeight: 300,
                      ),
                      child: TextField(
                        controller: TextEditingController(text: textArea.text)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: textArea.text.length),
                          ),
                        onChanged: (value) => _updateText(textArea.id, value),
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Gõ hoặc dán văn bản của bạn vào đây',
                          hintStyle: TextStyle(color: Color(0x8FFFFFFF)),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (textArea.result != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE15A46).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xFFE15A46),
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.type == ProcessorType.translate) ...[
                              Text(
                                'Dịch sang ${languages.firstWhere((l) => l.code == selectedLanguage).name}:',
                                style: const TextStyle(
                                  color: Color(0xFFE15A46),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            SelectableText(
                              textArea.result!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: textArea.status == 'load' || textArea.text.trim().isEmpty
                              ? null
                              : () {
                            if (textArea.status == 'normal') {
                              _processText(textArea.id);
                            } else if (textArea.status == 'success') {
                              _handleAccept(textArea.id);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE15A46),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            textArea.status == 'normal'
                                ? widget.buttonLabel
                                : textArea.status == 'success'
                                ? 'Chấp nhận'
                                : 'Đang xử lý...',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        if (textArea.status == 'success')
                          OutlinedButton(
                            onPressed: () => _handleDismiss(textArea.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0x8FFFFFFF),
                              side: const BorderSide(
                                color: Color(0x66E15A46),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text('Hủy', style: TextStyle(fontSize: 13)),
                          ),
                        if (widget.targetLanguage == true &&
                            widget.type == ProcessorType.translate &&
                            textArea.status == 'normal')
                          Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              border: Border.all(
                                color: const Color(0x66E15A46),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedLanguage,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedLanguage = newValue;
                                    });
                                  }
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                dropdownColor: const Color(0xFF232323),
                                items: languages.map<DropdownMenuItem<String>>((Language language) {
                                  return DropdownMenuItem<String>(
                                    value: language.code,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(language.flag),
                                        const SizedBox(width: 8),
                                        Text(language.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (textArea.text.isNotEmpty || textArea.result != null) ...[
                    IconButton(
                      onPressed: () => _handleDismiss(textArea.id),
                      icon: const Icon(Icons.delete_outline),
                      color: const Color(0x8FFFFFFF),
                      tooltip: 'Xóa nội dung',
                    ),
                    IconButton(
                      onPressed: () => _copyText(textArea.result ?? textArea.text),
                      icon: const Icon(Icons.copy),
                      color: const Color(0x8FFFFFFF),
                      tooltip: 'Sao chép',
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: () => _deleteTextArea(textArea.id),
                      icon: const Icon(Icons.close),
                      color: const Color(0x8FFFFFFF),
                      tooltip: 'Xóa ô văn bản',
                    ),
                  ],
                  IconButton(
                    onPressed: _addTextArea,
                    icon: const Icon(Icons.add),
                    color: const Color(0x8FFFFFFF),
                    tooltip: 'Thêm ô văn bản mới',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GrammarCheckerScreen extends StatelessWidget {
  const GrammarCheckerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextProcessorScreen(
      title: "Grammar Checker",
      apiGet: "grammar/getGrammar",
      apiType: "check-grammar",
      apiSave: "grammar/",
      type: ProcessorType.grammar,
      buttonLabel: "Thực hiện",
    );
  }
}

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextProcessorScreen(
      title: "Text Translate",
      apiGet: "translate/getTranslate",
      apiType: "translate-text",
      apiSave: "translate/",
      type: ProcessorType.translate,
      buttonLabel: "Dịch",
      targetLanguage: true,
    );
  }
}

class SummarizeScreen extends StatelessWidget {
  const SummarizeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextProcessorScreen(
      title: "Text Summarizer",
      apiGet: "summarize/getSummarize",
      apiType: "summarize-text", // Đã sửa từ "check-grammar" thành "summarize-text"
      apiSave: "summarize/",
      type: ProcessorType.summarize,
      buttonLabel: "Tóm tắt",
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Processor',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF1a1a1a),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    final token = await TokenManager.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    }
  }

  void refreshAuthStatus() {
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE15A46),
          ),
        ),
      );
    }

    return _isLoggedIn ? const MainScreen() : const LoginScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GrammarCheckerScreen(),
    const TranslateScreen(),
    const SummarizeScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF232323),
        selectedItemColor: const Color(0xFFE15A46),
        unselectedItemColor: const Color(0x8FFFFFFF),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.spellcheck),
            label: 'Grammar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Translate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.summarize),
            label: 'Summarize',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê', // Thêm tab
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}