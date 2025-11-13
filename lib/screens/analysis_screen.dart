import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_data_provider.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "AI.Analysis",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),

      body: userData.savingName.isEmpty
          ? const Center(
        child: Text(
          "No goal data available yet!",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildHeaderCard(userData),
            const SizedBox(height: 20),
            _buildGoalProgress(userData),
            const SizedBox(height: 20),
            _buildDetailsSection(userData),
            const SizedBox(height: 20),
            _buildStatsGrid(userData),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(UserDataProvider userData) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blueAccent.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Saving Goal",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            userData.savingName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${userData.currency} ${userData.amount}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Target Date: ${userData.targetDate != null ? DateFormat('dd MMM yyyy').format(userData.targetDate!) : 'Not set'}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(UserDataProvider userData) {
    double progress = userData.levelsCount > 0
        ? (userData.streakDays / userData.levelsCount).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Progress",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 18,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${(progress * 100).toStringAsFixed(1)}% completed",
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(UserDataProvider userData) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Goal Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Divider(height: 25),
            _buildDetailRow("Frequency", userData.savingFrequency ?? "Daily"),
            _buildDetailRow("Levels Count", "${userData.levelsCount}"),
            _buildDetailRow("Per Level Amount", "${userData.currency} ${userData.perLevelAmount.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(UserDataProvider userData) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard("Current Streak", "${userData.streakDays} days", Icons.local_fire_department, Colors.orange),
        _buildStatCard("Currency", userData.currency, Icons.attach_money, Colors.green),
        _buildStatCard("Levels", "${userData.levelsCount}", Icons.stacked_bar_chart, Colors.purple),
        _buildStatCard("Total Amount", "${userData.currency} ${userData.amount}", Icons.savings, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}