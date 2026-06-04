import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserApprovalPage extends StatelessWidget {
  const UserApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color goldDimDimDimDimColor = Color(0xFF61521F);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("가입 승인 대기 목록", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // isApproved가 false인 유저만 실시간으로 가져옵니다.
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('isApproved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("오류가 발생했습니다.", style: TextStyle(color: Colors.white)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: goldDimDimDimDimColor));

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("승인 대기 중인 사용자가 없습니다.", style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var user = docs[index];
              var userData = user.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  title: Text(userData['email'] ?? '이메일 없음', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text("가입 요청 중...", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. 일반관리자로 승인 버튼
                      ElevatedButton(
                        onPressed: () => _approveUser(context, user.id, 'admin'),
                        style: ElevatedButton.styleFrom(backgroundColor: goldDimDimDimDimColor, padding: const EdgeInsets.symmetric(horizontal: 10)),
                        child: const Text("관리자 임명", style: TextStyle(fontSize: 11, color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      // 2. 일반 라이더로 승인 버튼
                      OutlinedButton(
                        onPressed: () => _approveUser(context, user.id, 'driver'),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                        child: const Text("라이더 승인", style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 실제 DB 업데이트 로직
  Future<void> _approveUser(BuildContext context, String uid, String role) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isApproved': true,
        'role': role,
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${role == 'admin' ? '일반 관리자' : '라이더'}로 승인되었습니다.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("승인 처리 중 오류가 발생했습니다.")));
    }
  }
}