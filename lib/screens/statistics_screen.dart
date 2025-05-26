import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../utils/token_manager.dart';
import '../main.dart';
import 'login_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String userId = '';
  String period = 'day';
  List<Map<String, dynamic>> statisticsData = [];
  Map<String, dynamic>? summaryData;
  bool isLoading = false;
  String? errorMessage;

  // Constants cho styling
  static const Color primaryColor = Color(0xFFE15A46);
  static const Color backgroundColor = Color(0xFF1a1a1a);
  static const Color cardColor = Color(0xFF232323);

  // Colors cho từng type
  static const Map<String, Color> typeColors = {
    'grammar': Colors.blue,
    'translate': Colors.green,
    'summarize': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final cachedUserId = await TokenManager.getUserId();
      print("Cached userId in StatisticsScreen: $cachedUserId");

      if (cachedUserId != null) {
        setState(() {
          userId = cachedUserId;
        });
        await Future.wait([
          _fetchStatistics(),
          _fetchSummary(),
        ]);
      } else {
        _handleAuthError('Không tìm thấy userId, vui lòng đăng nhập lại!');
      }
    } catch (e) {
      print('Error loading user data: $e');
      _handleAuthError('Lỗi khi tải thông tin người dùng!');
    }
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        _handleAuthError('Không tìm thấy token, vui lòng đăng nhập lại!');
        return;
      }

      final endDate = DateTime.now();
      final startDate = _getStartDate(endDate, period);

      final uri = Uri.parse('https://checker-api-vysh.vercel.app/api/statistics')
          .replace(queryParameters: {
        'period': period,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Statistics data: ${data['data']}");

        setState(() {
          statisticsData = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      } else if (response.statusCode == 401) {
        _handleAuthError('Phiên đăng nhập hết hạn!');
      } else {
        setState(() {
          errorMessage = 'Lỗi khi lấy dữ liệu thống kê: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      setState(() {
        errorMessage = 'Lỗi kết nối khi lấy dữ liệu thống kê!';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchSummary() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('https://checker-api-vysh.vercel.app/api/statistics/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          summaryData = data;
        });
      }
    } catch (e) {
      print('Error fetching summary: $e');
    }
  }

  DateTime _getStartDate(DateTime endDate, String period) {
    switch (period) {
      case 'today':
        return DateTime(endDate.year, endDate.month, endDate.day);
      case 'day':
        return endDate.subtract(Duration(days: 7));
      case 'week':
        return endDate.subtract(Duration(days: 30));
      case 'month':
        return endDate.subtract(Duration(days: 90));
      default:
        return endDate.subtract(Duration(days: 7));
    }
  }

  void _handleAuthError(String message) {
    _showErrorSnackBar(message);
    TokenManager.removeToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _fetchStatistics(),
      _fetchSummary(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Thống kê',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 16),
              if (summaryData != null) ...[
                _buildSummaryCards(),
                const SizedBox(height: 16),
              ],
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chu kỳ: ',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            DropdownButton<String>(
              value: period,
              onChanged: (String? newValue) {
                if (newValue != null && newValue != period) {
                  setState(() {
                    period = newValue;
                  });
                  _fetchStatistics();
                }
              },
              items: const [
                DropdownMenuItem(value: 'today', child: Text('Hôm nay')),
                DropdownMenuItem(value: 'day', child: Text('Theo ngày')),
                DropdownMenuItem(value: 'week', child: Text('Theo tuần')),
                DropdownMenuItem(value: 'month', child: Text('Theo tháng')),
              ],
              dropdownColor: cardColor,
              style: const TextStyle(color: Colors.white),
              underline: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final data = summaryData!['data'] as List;

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final type = item['type'];
          final color = typeColors[type] ?? Colors.grey;

          return Container(
            width: 140,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getTypeName(type),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${item['totalCount']}',
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'TB: ${item['avgPerDay']}/ngày',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return Container(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onRefresh,
                child: Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (statisticsData.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, color: Colors.grey, size: 48),
              SizedBox(height: 16),
              Text(
                'Không có dữ liệu thống kê!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLegend(),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: period == 'today' ? _buildBarChart() : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: typeColors.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4),
            Text(
              _getTypeName(entry.key),
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'grammar':
        return 'Ngữ pháp';
      case 'translate':
        return 'Dịch thuật';
      case 'summarize':
        return 'Tóm tắt';
      default:
        return type;
    }
  }

  Widget _buildBarChart() {
    // Xử lý dữ liệu cho bar chart (hôm nay)
    final Map<String, double> barData = {
      'grammar': 0,
      'translate': 0,
      'summarize': 0,
    };

    // Tổng hợp dữ liệu cho hôm nay
    for (var stat in statisticsData) {
      final type = stat['type'].toString();
      final count = (stat['count'] ?? 0).toDouble();
      if (barData.containsKey(type)) {
        barData[type] = barData[type]! + count;
      }
    }

    final maxY = barData.values.fold(0.0, (prev, value) => prev > value ? prev : value);
    final adjustedMaxY = maxY > 0 ? (maxY * 1.2).ceilToDouble() : 10;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: adjustedMaxY.toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.grey.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final types = ['grammar', 'translate', 'summarize'];
              final type = types[group.x.toInt()];
              return BarTooltipItem(
                '${_getTypeName(type)}\n${rod.toY.toInt()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final types = ['grammar', 'translate', 'summarize'];
                final index = value.toInt();
                if (index >= 0 && index < types.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getTypeName(types[index]),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        barGroups: _createBarGroups(barData),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(Map<String, double> barData) {
    final types = ['grammar', 'translate', 'summarize'];

    return types.asMap().entries.map((entry) {
      final index = entry.key;
      final type = entry.value;
      final value = barData[type] ?? 0;
      final color = typeColors[type] ?? Colors.grey;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
            width: 30,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: barData.values.fold(0.0, (prev, val) => prev > val ? prev : val) * 1.2,
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildChart() {
    // Xử lý dữ liệu cho chart
    final chartData = _processChartData();

    if (chartData['dates'].length < 2) {
      return Center(
        child: Text(
          'Cần ít nhất 2 điểm dữ liệu để vẽ biểu đồ!',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: chartData['maxY'],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.grey.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final types = ['grammar', 'translate', 'summarize'];
                final type = types[spot.barIndex];
                return LineTooltipItem(
                  '${_getTypeName(type)}: ${spot.y.toInt()}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final dates = chartData['dates'] as List<String>;
                if (index >= 0 && index < dates.length) {
                  return Text(
                    _formatDateLabel(dates[index]),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        lineBarsData: _createLineBars(chartData),
      ),
    );
  }

  Map<String, dynamic> _processChartData() {
    final dates = statisticsData.map((e) => e['date'].toString()).toSet().toList()..sort();
    final Map<String, Map<String, double>> dataMap = {};

    // Initialize data structure
    for (var date in dates) {
      dataMap[date] = {'grammar': 0, 'translate': 0, 'summarize': 0};
    }

    // Fill with actual data
    for (var stat in statisticsData) {
      final date = stat['date'].toString();
      final type = stat['type'].toString();
      final count = (stat['count'] ?? 0).toDouble();
      if (dataMap[date] != null) {
        dataMap[date]![type] = count;
      }
    }

    // Calculate maxY
    double maxY = 0;
    dataMap.forEach((date, types) {
      types.forEach((type, value) {
        if (value > maxY) maxY = value;
      });
    });
    maxY = (maxY * 1.1).ceilToDouble(); // Add 10% padding

    return {
      'dates': dates,
      'data': dataMap,
      'maxY': maxY,
    };
  }

  List<LineChartBarData> _createLineBars(Map<String, dynamic> chartData) {
    final dates = chartData['dates'] as List<String>;
    final dataMap = chartData['data'] as Map<String, Map<String, double>>;

    return ['grammar', 'translate', 'summarize'].map((type) {
      return LineChartBarData(
        spots: dates.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), dataMap[e.value]![type]!);
        }).toList(),
        isCurved: true,
        color: typeColors[type],
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        barWidth: 2,
      );
    }).toList();
  }

  String _formatDateLabel(String date) {
    switch (period) {
      case 'month':
        return date; // YYYY-MM format
      case 'week':
        return date.contains('W') ? date.split('-W').last : date.split('-').last;
      case 'day':
      default:
        return date.split('-').last; // Get day part
    }
  }
}