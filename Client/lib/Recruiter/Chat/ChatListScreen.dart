import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Server/Services/ChatListService.dart';
import 'package:client/Server/Services/ChatUserResolver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatListService _chatListService = ChatListService();
  // Cache user info to avoid multiple network calls
  final Map<String, Map<String, dynamic>> _userCache = {};
  final ChatUserResolver _resolver = ChatUserResolver();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';



  Future<Map<String, dynamic>> _getUser(String userId) async {
  if (_userCache.containsKey(userId)) return _userCache[userId]!;

  final data = await _resolver.resolveUser(userId);

  if (data != null) {
    _userCache[userId] = data;
    return data;
  }

  return {'name': AppLocalizations.of(context)!.anonymous_candidate, 'avatar': null}; // ← null, not 'Unknown'
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ImageProvider? _validAvatar(dynamic url) {
  if (url == null || url.toString().isEmpty || url == 'Unknown') return null;
  return NetworkImage(url.toString());
}

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              AppLocalizations.of(context)!.chats,
              style: const TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase().trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search_chats,
                      border: InputBorder.none,
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _chatListService.chatListStream(user.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.no_chats_yet,
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final chats = snapshot.data!.docs;

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 19,
                        vertical: 10,
                      ),
                      itemCount: chats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final chat =
                            chats[index].data() as Map<String, dynamic>;
                        final otherUserId = (chat['users'] as List).firstWhere(
                          (id) => id != user.userId,
                        );

                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getUser(otherUserId),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) return const SizedBox();

                            final otherUser = userSnapshot.data!;
                            final lastMessage = chat['lastMessage'] ?? '';
                            final time = chat['lastMessageTime'] as Timestamp?;

                            final unreadCount =
                                chat['unreadCount_${user.userId}'] ?? 0;

                            final lastSenderId = chat['lastMessageSenderId'];
                            final isMe = lastSenderId == user.userId;

                            final displayMessage = isMe
                                ? AppLocalizations.of(context)!.you(lastMessage)
                                : lastMessage;

                            String formattedTime = '';
                            if (time != null) {
                              final dateTime = time.toDate();
                              final now = DateTime.now();
                              final difference = now.difference(dateTime);
                              if (difference.inMinutes < 60) {
                                formattedTime = AppLocalizations.of(context)!.min_ago(difference.inMinutes);
                              } else if (difference.inHours < 24) {
                                formattedTime = AppLocalizations.of(context)!.hours_ago(difference.inHours);
                              } else if (difference.inDays < 7) {
                                formattedTime = AppLocalizations.of(context)!.days_ago(difference.inDays);
                              } else {
                                formattedTime =
                                    '${dateTime.day}/${dateTime.month}/${dateTime.year}';
                              }
                            }
                            final name = (otherUser['name'] ?? '')
                                .toString()
                                .toLowerCase();

                            if (_searchQuery.isNotEmpty &&
                                !name.contains(_searchQuery)) {
                              return const SizedBox.shrink();
                            }
                           
                            return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          personName: otherUser['name'],
          otherUserId: otherUserId,
          chatId: chats[index].id,
        ),
      ),
    );
  },
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        CircleAvatar(
  radius: 32,
  backgroundImage: _validAvatar(otherUser['avatar']),
  child: _validAvatar(otherUser['avatar']) == null
      ? const Icon(Icons.person, color: Colors.white)
      : null,
),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherUser['name'],
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: unreadCount > 0
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: unreadCount > 0
                    ? AppColors.greenwa
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            if (unreadCount > 0)
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.greenCeladon,
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  ),
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
        );
      },
    );
  }
}
