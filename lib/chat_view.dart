// 1:1 상담 공용 채팅 위젯 — 관리자·기사 동일 UI(말풍선·입력·읽음표시). mySide로 시점만 다름.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _teal     = kTeal;
const _text     = kText;
const _text2    = kText2;

class ChatView extends StatefulWidget {
  final String uid;
  final String mySide; // 'admin' | 'rider'
  final String riderName; // 기사 측에서 채팅 문서 riderName 기록용
  const ChatView({
    super.key,
    required this.uid,
    required this.mySide,
    this.riderName = '',
  });
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _sending = false;
  Timestamp? _lastMarkedOtherAt; // 보는 중 새 상대 메시지 읽음처리 중복 방지

  bool get _isAdmin => widget.mySide == 'admin';
  String get _myReadField => _isAdmin ? 'adminReadAt' : 'riderReadAt';
  String get _otherReadField => _isAdmin ? 'riderReadAt' : 'adminReadAt';
  String get _myUnreadField => _isAdmin ? 'unreadByAdmin' : 'unreadByRider';
  String get _otherUnreadField => _isAdmin ? 'unreadByRider' : 'unreadByAdmin';

  DocumentReference get _chatRef =>
      FirebaseFirestore.instance.collection('chats').doc(widget.uid);

  @override
  void initState() {
    super.initState();
    _markRead();
  }

  // 내 읽음 시각 갱신 + 내 안읽음 플래그 해제
  void _markRead() {
    _chatRef.set({
      _myReadField: FieldValue.serverTimestamp(),
      _myUnreadField: false,
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final data = <String, dynamic>{
        'lastMessage': msg,
        'lastAt': FieldValue.serverTimestamp(),
        _otherUnreadField: true,
        _myUnreadField: false,
        _myReadField: FieldValue.serverTimestamp(),
      };
      if (!_isAdmin) {
        data['uid'] = widget.uid;
        data['riderName'] =
            widget.riderName.isNotEmpty ? widget.riderName : widget.uid;
      }
      await _chatRef.set(data, SetOptions(merge: true));
      await _chatRef.collection('messages').add({
        'sender': widget.mySide,
        'text': msg,
        'at': FieldValue.serverTimestamp(),
      });
      _ctrl.clear();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  // 보는 중 새 상대 메시지가 오면 읽음 갱신 (상대 화면에 '읽음' 반영)
  void _maybeMarkRead(List<QueryDocumentSnapshot> docs) {
    Timestamp? newest;
    for (final d in docs) {
      final m = d.data() as Map<String, dynamic>;
      if (m['sender'] != widget.mySide) {
        final at = m['at'] as Timestamp?;
        if (at != null && (newest == null || at.compareTo(newest) > 0)) {
          newest = at;
        }
      }
    }
    if (newest != null &&
        (_lastMarkedOtherAt == null ||
            newest.compareTo(_lastMarkedOtherAt!) > 0)) {
      _lastMarkedOtherAt = newest;
      _markRead();
    }
  }

  Widget _bubble(String text, bool isMine, Timestamp? at, bool isRead) {
    final bubble = Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.66),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // 안읽음 = 진한 teal(채움) / 읽음 = 연하게. 상대 메시지 = surface.
        color: isMine ? _teal.withValues(alpha: isRead ? 0.10 : 0.30) : _surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMine ? 12 : 2),
          bottomRight: Radius.circular(isMine ? 2 : 12),
        ),
        border: Border.all(
          color: isMine ? _teal.withValues(alpha: isRead ? 0.3 : 0.6) : _elevated,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(text,
              style: const TextStyle(color: _text, fontSize: 13, height: 1.4)),
          if (at != null) ...[
            const SizedBox(height: 3),
            Text(DateFormat('MM/dd HH:mm').format(at.toDate()),
                style: const TextStyle(color: _text2, fontSize: 9)),
          ],
        ],
      ),
    );

    if (!isMine) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(alignment: Alignment.centerLeft, child: bubble),
      );
    }
    // 내 메시지: 오른쪽 정렬 + 왼쪽에 읽음/안읽음 표시
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 4),
            child: Text(isRead ? '읽음' : '안읽음',
                style: TextStyle(
                    color: isRead ? _text2 : _teal,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
          Flexible(child: bubble),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _chatRef.snapshots(),
          builder: (_, chatSnap) {
            final cdata = chatSnap.data?.data() as Map<String, dynamic>?;
            final otherReadAt = cdata?[_otherReadField] as Timestamp?;
            return StreamBuilder<QuerySnapshot>(
              stream: _chatRef
                  .collection('messages')
                  .orderBy('at', descending: false)
                  .snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: _teal));
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text("상담 내용을 입력해 보세요.",
                        style: TextStyle(color: _text2, fontSize: 13)),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _maybeMarkRead(docs);
                  if (_scrollCtrl.hasClients) {
                    _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut);
                  }
                });
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final isMine = d['sender'] == widget.mySide;
                    final at = d['at'] as Timestamp?;
                    final isRead = isMine &&
                        otherReadAt != null &&
                        at != null &&
                        otherReadAt.compareTo(at) >= 0;
                    return _bubble(d['text'] as String? ?? '', isMine, at, isRead);
                  },
                );
              },
            );
          },
        ),
      ),
      // 입력창 (경계선 = _elevated 중립 테두리)
      Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(top: BorderSide(color: _elevated)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(color: _text, fontSize: 13),
              cursorColor: _teal,
              decoration: InputDecoration(
                hintText: "메시지 입력...",
                hintStyle: const TextStyle(color: _text2, fontSize: 13),
                filled: true,
                fillColor: _surface,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: _elevated),
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: _teal),
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sending ? null : _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: _teal, width: 1),
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child:
                          CircularProgressIndicator(color: _teal, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: _teal, size: 20),
            ),
          ),
        ]),
      ),
    ]);
  }
}
