// 기사 1:1 상담 — 전체배경→메인패널 구조 + 공용 ChatView (관리자와 동일 UI)
import 'package:flutter/material.dart';
import 'tokens.dart';
import 'driver_common.dart';
import 'chat_view.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _elevated = kElevated;
const List<BoxShadow> _panelShadow = kPanelShadow;

class DriverChatPage extends StatelessWidget {
  final String uid;
  final String riderName;
  const DriverChatPage({super.key, required this.uid, required this.riderName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _elevated, width: 1),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(children: [
                const SizedBox(height: 8),
                pageHeader(context, "관리자 1:1 상담"),
                const SizedBox(height: 10),
                Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    color: _elevated),
                Expanded(
                  child: ChatView(
                      uid: uid, mySide: 'rider', riderName: riderName),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
