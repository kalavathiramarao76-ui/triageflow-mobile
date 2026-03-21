import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/favorites_provider.dart';
import '../providers/triage_provider.dart';
import 'triage_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<FavoritesProvider>().loadSaved();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Favorites',
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Triages (${favs.savedTriages.length})'),
            Tab(text: 'Incidents (${favs.savedIncidents.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Saved triages
          favs.savedTriages.isEmpty
              ? _buildEmpty('No saved triages', 'Bookmark triage results to save them here')
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: favs.savedTriages.length,
                  itemBuilder: (context, index) {
                    final triage = favs.savedTriages[index];
                    final priorityColor =
                        AppColors.getPriorityColor(triage.priority);

                    return GestureDetector(
                      onTap: () {
                        context.read<TriageProvider>().selectResult(triage);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TriageScreen()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: priorityColor.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        priorityColor.withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    triage.priority,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: priorityColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.getCategoryColor(
                                            triage.category)
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    triage.category.toUpperCase(),
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.getCategoryColor(
                                          triage.category),
                                    ),
                                  ),
                                ),
                                if (triage.isNoise) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.noise_aware_rounded,
                                      size: 16, color: AppColors.p2),
                                ],
                                const Spacer(),
                                GestureDetector(
                                  onTap: () =>
                                      favs.toggleTriage(triage),
                                  child: const Icon(
                                    Icons.bookmark_rounded,
                                    size: 20,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              triage.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                            delay: (index * 100).ms,
                            duration: 400.ms)
                        .slideX(begin: 0.05, end: 0);
                  },
                ),

          // Saved incidents
          favs.savedIncidents.isEmpty
              ? _buildEmpty('No saved incidents', 'Bookmark incidents to save them here')
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: favs.savedIncidents.length,
                  itemBuilder: (context, index) {
                    final incident = favs.savedIncidents[index];
                    final severityColor =
                        AppColors.getPriorityColor(incident.severity);
                    final statusColor =
                        AppColors.getStatusColor(incident.status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: severityColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      severityColor.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: Text(
                                  incident.severity,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: severityColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: Text(
                                  incident.status.toUpperCase(),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    favs.toggleIncident(incident),
                                child: const Icon(
                                  Icons.bookmark_rounded,
                                  size: 20,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            incident.title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            incident.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(
                            delay: (index * 100).ms,
                            duration: 400.ms)
                        .slideX(begin: 0.05, end: 0);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
