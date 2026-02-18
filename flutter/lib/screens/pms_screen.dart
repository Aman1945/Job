import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/api_config.dart';

class PMSScreen extends StatefulWidget {
  const PMSScreen({Key? key}) : super(key: key);

  @override
  State<PMSScreen> createState() => _PMSScreenState();
}

class _PMSScreenState extends State<PMSScreen> {
  final String _baseUrl = ApiConfig.baseUrl;

  bool _isLoading = true;
  Map<String, dynamic>? _pmsData;
  List<dynamic> _leaderboard = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPMSData();
  }

  Future<void> _fetchPMSData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch user PMS data
      final pmsResponse = await http.get(
        Uri.parse('$_baseUrl/pms/$userId'),
        headers: authProvider.authHeaders,
      ).timeout(const Duration(seconds: 15));

      // Fetch leaderboard
      final leaderboardResponse = await http.get(
        Uri.parse('$_baseUrl/pms/leaderboard'),
        headers: authProvider.authHeaders,
      ).timeout(const Duration(seconds: 15));

      if (pmsResponse.statusCode == 200 && leaderboardResponse.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _pmsData = jsonDecode(pmsResponse.body)['data'];
          _leaderboard = jsonDecode(leaderboardResponse.body)['data'];
          _isLoading = false;
        });
      } else {
        String serverError = '';
        if (pmsResponse.statusCode != 200) {
          serverError += 'PMS API Error (${pmsResponse.statusCode}): ${pmsResponse.body}\n';
        }
        if (leaderboardResponse.statusCode != 200) {
          serverError += 'Leaderboard API Error (${leaderboardResponse.statusCode}): ${leaderboardResponse.body}';
        }
        throw Exception(serverError);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'INCENTIVE TERMINAL',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchPMSData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  color: const Color(0xFF6366F1),
                  onRefresh: _fetchPMSData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScoreHeader(),
                        const SizedBox(height: 24),
                        _buildKRAGrid(),
                        const SizedBox(height: 24),
                        _buildLeaderboard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildScoreHeader() {
    final score = _pmsData?['totalScore'] ?? 0.0;
    final incentive = _pmsData?['incentiveAmount'] ?? 0.0;
    final perc = _pmsData?['incentivePercentage'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL SCORE',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            '${score.toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(
              color: const Color(0xFF10B981),
              fontSize: 56,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat('PAYOUT %', '$perc%'),
              Container(width: 1, height: 40, color: Colors.white10),
              _buildHeaderStat('INCENTIVE', '₹${incentive.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildKRAGrid() {
    final kras = (_pmsData?['kras'] as List?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KRA PERFORMANCE',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        ...kras.map((kra) => _buildKRACard(kra)).toList(),
      ],
    );
  }

  Widget _buildKRACard(Map<String, dynamic> kra) {
    final achievement = kra['target'] > 0 ? (kra['achieved'] / kra['target'] * 100) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  kra['name'],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Text(
                '${achievement.toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  color: achievement >= 100 ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (achievement / 100).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                achievement >= 100 ? const Color(0xFF10B981) : const Color(0xFF6366F1),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKRASubInfo('Target', kra['target'].toString()),
              _buildKRASubInfo('Actual', kra['achieved'].toString()),
              _buildKRASubInfo('Weight', '${kra['weightage']}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKRASubInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.black38, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLeaderboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP PERFORMERS',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _leaderboard.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final user = _leaderboard[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(index),
                  radius: 14,
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(user['userName'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                trailing: Text(
                  '${user['totalScore'].toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return const Color(0xFFF59E0B); // Gold
    if (index == 1) return const Color(0xFF94A3B8); // Silver
    if (index == 2) return const Color(0xFFD97706); // Bronze
    return const Color(0xFFCBD5E1);
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred', textAlign: TextAlign.center),
          TextButton(onPressed: _fetchPMSData, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
