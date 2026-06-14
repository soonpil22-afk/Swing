// 관리자 1:1 상담 — 상담 목록(ChatListPage) + 채팅 화면(_AdminChatPage)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'admin_common.dart';
import 'chat_view.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _teal     = kTeal;
const _text     = kText;
const _text2    = kText2;
const _pink     = kPink;

// ── 상담 — 목록 카드 ──
const double _csListPadH = 14; // 목록 좌우 여백
const double _csListPadV = 12; // 목록 상하 여백
const _csCardBg = _surface;    // 상담 카드 배경
const double _csCardRadius = 12;// 상담 카드 모서리
const _csCardBorder       = _elevated; // 읽음 카드 테두리
const _csCardBorderUnread = _teal;    // 안읽음 카드 테두리
const _csAvatarBg         = _surface;  // 아바타 배경
const _csAvatarIconColor  = _text;     // 아바타 아이콘(읽음)
const _csAvatarIconUnread = _teal;    // 아바타 아이콘(안읽음)
const _csNameColor  = _text;  // 이름(읽음) 색
const _csNameUnread = _teal;   // 이름(안읽음) 색
const double _csNameFontSize = 16; // 이름 글씨 크기
const _csNewBg   = _pink;   // NEW 뱃지 배경
const _csNewText = _text;  // NEW 뱃지 글씨
const _csTimeColor = _text;       // 시간 색
const double _csTimeFontSize = 16; // 시간 크기
const _csChevronColor = _text2;    // 화살표 색
const _csEmptyColor = _text2;      // "접수된 상담이 없습니다" 색
const double _csEmptyFontSize = 13;// 빈 안내 글씨 크기
const double _csAvatarSize     = 38; // 아바타 크기
const double _csAvatarIconSize = 20; // 아바타 아이콘 크기
const double _csNewFontSize    = 8;  // NEW 뱃지 글씨 크기
const double _csChevronSize    = 16; // 화살표 크기
const double _csRowGap         = kGapCard;  // 카드 사이 갭
const double _csTabToCardGap   = 2; // 1:1상담 탭 ↔ 첫 카드 갭

// ═══════════════════════ 상담 목록 (로직) ═══════════════════════
class ChatListPage extends StatelessWidget {
  final bool embedded;
  const ChatListPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastAt', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _teal));
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("접수된 상담이 없습니다.", style: TextStyle(color: _csEmptyColor, fontSize: _csEmptyFontSize)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(_csListPadH, _csTabToCardGap, _csListPadH, _csListPadV),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: _csRowGap),
            itemBuilder: (ctx, i) {
              final d    = docs[i].data() as Map<String, dynamic>;
              final uid  = docs[i].id;
              final name = d['riderName'] as String? ?? uid;
              final at   = d['lastAt'] as Timestamp?;
              final unread = d['unreadByAdmin'] as bool? ?? false;

              return GestureDetector(
                onTap: () => Navigator.push(ctx,
                    MaterialPageRoute(builder: (_) => _AdminChatPage(uid: uid, riderName: name))),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: _csCardBg,
                    borderRadius: BorderRadius.circular(_csCardRadius),
                    border: Border.all(color: unread ? _csCardBorderUnread : _csCardBorder, width: 1),
                  ),
                  child: Row(children: [
                    Container(
                      width: _csAvatarSize, height: _csAvatarSize,
                      decoration: BoxDecoration(
                        color: _csAvatarBg, shape: BoxShape.circle,
                        border: Border.all(color: unread ? _csCardBorderUnread : _csCardBorder, width: 1),
                      ),
                      child: Icon(Icons.person_outline_rounded, color: unread ? _csAvatarIconUnread : _csAvatarIconColor, size: _csAvatarIconSize),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(name, style: TextStyle(
                              color: unread ? _csNameUnread : _csNameColor,
                              fontSize: _csNameFontSize, fontWeight: FontWeight.w700)),
                          if (unread) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: _csNewBg, borderRadius: BorderRadius.circular(8)),
                              child: const Text("NEW", style: TextStyle(color: _csNewText, fontSize: _csNewFontSize, fontWeight: FontWeight.w700)),
                            ),
                          ],
                          const Spacer(),
                          if (at != null)
                            Text(DateFormat('MM/dd HH:mm').format(at.toDate()),
                                style: const TextStyle(color: _csTimeColor, fontSize: _csTimeFontSize)),
                        ]),
                      ]),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, color: _csChevronColor, size: _csChevronSize),
                  ]),
                ),
              );
            },
          );
        },
      );
    return embedded ? body : adminPanelScaffold(context, "1:1 상담", body);
  }
}

// ═══════════════════════ 관리자 채팅 화면 ═══════════════════════
class _AdminChatPage extends StatelessWidget {
  final String uid;
  final String riderName;
  const _AdminChatPage({required this.uid, required this.riderName});

  @override
  Widget build(BuildContext context) {
    return adminPanelScaffold(
      context,
      "$riderName 님",
      dividerColor: _elevated,
      dividerInset: 15,
      ChatView(uid: uid, mySide: 'admin'),
    );
  }
}
