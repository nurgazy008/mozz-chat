import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = 'current_user';
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      final chatsSnapshot = await _firestore.collection('chats').get();
      
      if (chatsSnapshot.docs.isEmpty) {
        await _createInitialData();
      }
      
      _isInitialized = true;
    } catch (e) {
      try {
        await _createInitialData();
      } catch (_) {}
      _isInitialized = true;
    }
  }

  Future<void> _createInitialData() async {
    final users = [
      {
        'id': '1',
        'name': 'Виктор Власов',
        'initials': 'BB',
        'avatarColor': '#4CAF50',
        'isOnline': true,
      },
      {
        'id': '2',
        'name': 'Саша Алексеев',
        'initials': 'CA',
        'avatarColor': '#FF9800',
        'isOnline': false,
      },
      {
        'id': '3',
        'name': 'Пётр Жаринов',
        'initials': 'ПЖ',
        'avatarColor': '#2196F3',
        'isOnline': false,
      },
      {
        'id': '4',
        'name': 'Алина Жукова',
        'initials': 'АЖ',
        'avatarColor': '#F44336',
        'isOnline': false,
      },
    ];

    final now = DateTime.now();
    final oldDate = DateTime(2022, 1, 12);

    for (var userData in users) {
      await _firestore.collection('users').doc(userData['id'] as String).set(userData);
    }

    final chatsData = [
      {
        'userId': '1',
        'lastMessageTime': now.subtract(const Duration(minutes: 2)),
      },
      {
        'userId': '2',
        'lastMessageTime': oldDate,
      },
      {
        'userId': '3',
        'lastMessageTime': now.subtract(const Duration(minutes: 2)),
      },
      {
        'userId': '4',
        'lastMessageTime': DateTime(2022, 1, 27, 9, 23),
      },
    ];

    for (int i = 0; i < chatsData.length; i++) {
      final chatId = (i + 1).toString();
      await _firestore.collection('chats').doc(chatId).set({
        'userId': chatsData[i]['userId'] as String,
        'lastMessageTime': (chatsData[i]['lastMessageTime'] as DateTime),
      });
    }

    final initialMessages = [
      {
        'chatId': '1',
        'senderId': currentUserId,
        'text': 'Сделай мне кофе, пожалуйста',
        'timestamp': DateTime(2022, 1, 27, 21, 41),
        'isRead': true,
      },
      {
        'chatId': '1',
        'senderId': '1',
        'text': 'Хорошо',
        'timestamp': DateTime(2022, 1, 27, 21, 41),
        'isRead': true,
      },
      {
        'chatId': '1',
        'senderId': currentUserId,
        'text': 'Уже сделал?',
        'timestamp': now.subtract(const Duration(minutes: 2)),
        'isRead': true,
      },
    ];

    for (var msgData in initialMessages) {
      await _firestore.collection('messages').add({
        'chatId': msgData['chatId'] as String,
        'senderId': msgData['senderId'] as String,
        'text': msgData['text'] as String,
        'timestamp': (msgData['timestamp'] as DateTime),
        'isRead': msgData['isRead'] as bool,
        'imageUrl': null,
      });
    }

    await _firestore.collection('chats').doc('1').update({
      'lastMessage': {
        'text': 'Уже сделал?',
        'senderId': currentUserId,
      },
      'lastMessageTime': now.subtract(const Duration(minutes: 2)),
    });
  }

  Stream<List<Chat>> getChatsStream() {
    return _firestore
        .collection('chats')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final chats = <Chat>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userDoc = await _firestore
            .collection('users')
            .doc(data['userId'] as String)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final user = User(
            id: userData['id'] as String,
            name: userData['name'] as String,
            initials: userData['initials'] as String,
            avatarColor: userData['avatarColor'] as String,
            isOnline: (userData['isOnline'] as bool?) ?? false,
          );

          Message? lastMessage;
          if (data['lastMessage'] != null) {
            final lastMsgData = data['lastMessage'] as Map<String, dynamic>;
            lastMessage = Message(
              id: 'last',
              chatId: doc.id,
              senderId: lastMsgData['senderId'] as String,
              text: lastMsgData['text'] as String,
              timestamp: (data['lastMessageTime'] as Timestamp).toDate(),
              isRead: true,
            );
          }

          chats.add(Chat(
            id: doc.id,
            user: user,
            lastMessage: lastMessage,
            lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
          ));
        }
      }
      
      return chats;
    });
  }

  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Message(
          id: doc.id,
          chatId: data['chatId'] as String,
          senderId: data['senderId'] as String,
          text: data['text'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: (data['isRead'] as bool?) ?? false,
          imageUrl: data['imageUrl'] as String?,
        );
      }).toList();
    });
  }

  Future<void> sendMessage(String chatId, String text) async {
    final messageRef = _firestore.collection('messages').doc();
    final now = DateTime.now();

    await messageRef.set({
      'chatId': chatId,
      'senderId': currentUserId,
      'text': text,
      'timestamp': now,
      'isRead': false,
      'imageUrl': null,
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': {
        'text': text,
        'senderId': currentUserId,
      },
      'lastMessageTime': now,
    });
  }

  Future<Chat?> getChatById(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return null;

      final data = chatDoc.data()!;
      final userDoc = await _firestore
          .collection('users')
          .doc(data['userId'] as String)
          .get();
      
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      final user = User(
        id: userData['id'] as String,
        name: userData['name'] as String,
        initials: userData['initials'] as String,
        avatarColor: userData['avatarColor'] as String,
        isOnline: (userData['isOnline'] as bool?) ?? false,
      );

      Message? lastMessage;
      if (data['lastMessage'] != null) {
        final lastMsgData = data['lastMessage'] as Map<String, dynamic>;
        lastMessage = Message(
          id: 'last',
          chatId: chatId,
          senderId: lastMsgData['senderId'] as String,
          text: lastMsgData['text'] as String,
          timestamp: (data['lastMessageTime'] as Timestamp).toDate(),
          isRead: true,
        );
      }

      return Chat(
        id: chatId,
        user: user,
        lastMessage: lastMessage,
        lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      );
    } catch (e) {
      return null;
    }
  }

  List<Chat> getChats() {
    return [];
  }

  List<Message> getMessages(String chatId) {
    return [];
  }
}
