enum TicketStatus { open, closed }

class SupportTicket {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName; // For admin display
  final String? userAvatar; // For admin display
  final int? rating;
  final String? closingFeedback;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.rating,
    this.closingFeedback,
  });

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'] ?? '',
      status: map['status'] == 'open' ? TicketStatus.open : TicketStatus.closed,
      createdAt: _parseUtcDateTime(map['created_at']),
      updatedAt: _parseUtcDateTime(map['updated_at']),
      userName: map['profile']?['name'],
      userAvatar: map['profile']?['avatar_url'],
      rating: map['rating'],
      closingFeedback: map['closing_feedback'],
    );
  }
}

class TicketMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String text;
  final String? imageUrl;
  final bool isUser;
  final DateTime timestamp;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.isUser,
    required this.timestamp,
  });

  factory TicketMessage.fromMap(Map<String, dynamic> map, String currentUserId) {
    return TicketMessage(
      id: map['id'],
      ticketId: map['ticket_id'],
      senderId: map['sender_id'],
      text: map['message_text'],
      imageUrl: map['image_url'],
      isUser: map['sender_id'] == currentUserId,
      timestamp: _parseUtcDateTime(map['created_at']),
    );
  }
}

/// Robustly parses a date string from Supabase and ensures it is converted to local time.
DateTime _parseUtcDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    String dateStr = value.toString();
    if (!dateStr.contains('Z') && !dateStr.contains(RegExp(r'[+-]\d{2}:?\d{2}'))) {
      dateStr = dateStr.replaceFirst(' ', 'T') + 'Z';
    }
    return DateTime.parse(dateStr).toLocal();
  } catch (e) {
    return DateTime.now();
  }
}
