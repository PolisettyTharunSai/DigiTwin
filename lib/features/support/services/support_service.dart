import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../models/support_ticket.dart';

class SupportService {
  SupportService._();
  static final SupportService instance = SupportService._();

  final _supabase = Supabase.instance.client;

  /// Returns the currently authenticated user.
  User? get currentUser => _supabase.auth.currentUser;

  /// Fetches all tickets (for admin).
  Future<List<SupportTicket>> fetchAllTickets() async {
    final response = await _supabase
        .from(AppConstants.TABLE_SUPPORT_TICKETS)
        .select('*, profile:user_id(name, avatar_url)')
        .order('updated_at', ascending: false);
    
    return (response as List).map((json) => SupportTicket.fromMap(json)).toList();
  }

  /// Fetches tickets for a specific user.
  Future<List<SupportTicket>> fetchUserTickets(String userId) async {
    final response = await _supabase
        .from(AppConstants.TABLE_SUPPORT_TICKETS)
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    
    return (response as List).map((json) => SupportTicket.fromMap(json)).toList();
  }

  /// Creates a new support ticket.
  Future<SupportTicket> createTicket({
    required String title,
    required String description,
    Uint8List? imageBytes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ticketResponse = await _supabase
        .from(AppConstants.TABLE_SUPPORT_TICKETS)
        .insert({
          'user_id': user.id,
          'title': title,
          'description': description,
          'status': 'open',
        })
        .select()
        .single();

    final ticket = SupportTicket.fromMap(ticketResponse);

    // Add initial message
    await sendMessage(
      ticketId: ticket.id,
      text: description.isEmpty ? title : description,
      imageBytes: imageBytes,
    );

    return ticket;
  }

  /// Sends a message in a ticket.
  Future<void> sendMessage({
    required String ticketId,
    required String text,
    Uint8List? imageBytes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    String? imageUrl;
    if (imageBytes != null) {
      final fileName = 'public/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage
          .from(AppConstants.STORAGE_BUCKET_SUPPORT)
          .uploadBinary(fileName, imageBytes);
      imageUrl = _supabase.storage.from(AppConstants.STORAGE_BUCKET_SUPPORT).getPublicUrl(fileName);
    }

    await _supabase.from(AppConstants.TABLE_TICKET_MESSAGES).insert({
      'ticket_id': ticketId,
      'sender_id': user.id,
      'message_text': text,
      'image_url': imageUrl,
    });

    // Update ticket's updated_at timestamp in UTC
    await _supabase
        .from(AppConstants.TABLE_SUPPORT_TICKETS)
        .update({'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', ticketId);
  }

  /// Fetches all messages for a ticket.
  Future<List<TicketMessage>> fetchMessages(String ticketId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from(AppConstants.TABLE_TICKET_MESSAGES)
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    
    return (response as List).map((json) => TicketMessage.fromMap(json, user.id)).toList();
  }

  /// Closes a ticket with optional rating and feedback.
  Future<void> closeTicket({
    required String ticketId,
    int? rating,
    String? feedback,
  }) async {
    await _supabase
        .from(AppConstants.TABLE_SUPPORT_TICKETS)
        .update({
          'status': 'closed', 
          'updated_at': DateTime.now().toUtc().toIso8601String(),
          'rating': rating,
          'closing_feedback': feedback,
        })
        .eq('id', ticketId);
  }
}
