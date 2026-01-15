import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_styles.dart';
import '../utils/firebase_service.dart';

class StudentClassesScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const StudentClassesScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.getStudentClasses(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final memberships = snapshot.data?.docs ?? [];

                  if (memberships.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: memberships.length,
                    itemBuilder: (context, index) {
                      final membership = memberships[index].data() as Map<String, dynamic>;
                      final classId = membership['classId'];

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: FirebaseService.getClassById(classId),
                        builder: (context, classSnapshot) {
                          if (!classSnapshot.hasData || classSnapshot.data == null) {
                            return const SizedBox.shrink();
                          }

                          final classData = classSnapshot.data!;
                          return _ClassCard(
                            classId: classId,
                            classData: classData,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/class_detail',
                                arguments: {
                                  'classId': classId,
                                  'classData': classData,
                                  'isTutor': false,
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/join_class',
            arguments: {
              'userId': userId,
              'userName': userName,
            },
          );
          // El StreamBuilder se actualizará automáticamente
        },
        backgroundColor: AppStyles.accentGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Unirme a Clase',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF132757), Color(0xFF1E3A6E)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132757).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.school_rounded, color: AppStyles.yellow, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Clases',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Accede al contenido de tu profesor',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppStyles.yellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 70,
                color: AppStyles.yellow,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin clases aún',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF132757),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pide el código a tu profesor y únete a una clase para comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/join_class',
                  arguments: {
                    'userId': userId,
                    'userName': userName,
                  },
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('UNIRME A UNA CLASE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String classId;
  final Map<String, dynamic> classData;
  final VoidCallback onTap;

  const _ClassCard({
    required this.classId,
    required this.classData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFAB47BC),
      const Color(0xFFFF7043),
      const Color(0xFF26A69A),
    ];
    final color = colors[(classData['name']?.toString().length ?? 0) % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header colorido
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 40,
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classData['name'] ?? 'Clase',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF132757),
                          ),
                        ),
                        if (classData['description'] != null &&
                            classData['description'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            classData['description'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.chevron_right_rounded, color: color),
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
