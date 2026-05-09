import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../support/models/support_ticket.dart';
import '../../support/services/support_service.dart';
import '../../support/screens/customer_support_screen.dart'; // Reuse TicketChatScreen

class ManageTicketsScreen extends StatefulWidget {
  const ManageTicketsScreen({super.key});

  @override
  State<ManageTicketsScreen> createState() => _ManageTicketsScreenState();
}

class _ManageTicketsScreenState extends State<ManageTicketsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<SupportTicket> _allTickets = [];
  bool _isLoading = true;
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final tickets = await SupportService.instance.fetchAllTickets();
      if (mounted) {
        setState(() {
          _allTickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tickets: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SupportTicket> _filterAndSort(List<SupportTicket> tickets) {
    var filtered = tickets.where((t) {
      final query = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(query) ||
          (t.userName?.toLowerCase().contains(query) ?? false);
    }).toList();

    switch (_sortOption) {
      case _SortOption.dateDesc:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case _SortOption.dateAsc:
        filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case _SortOption.userAz:
        filtered.sort((a, b) => (a.userName ?? '').compareTo(b.userName ?? ''));
        break;
      case _SortOption.userZa:
        filtered.sort((a, b) => (b.userName ?? '').compareTo(a.userName ?? ''));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Manage Support Tickets',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search by title or user...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSortButton(),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Open'),
                  Tab(text: 'Closed'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _AdminTicketList(
                  tickets: _filterAndSort(
                    _allTickets.where((t) => t.status == TicketStatus.open).toList(),
                  ),
                  onRefresh: _fetchTickets,
                ),
                _AdminTicketList(
                  tickets: _filterAndSort(
                    _allTickets.where((t) => t.status == TicketStatus.closed).toList(),
                  ),
                  onRefresh: _fetchTickets,
                ),
              ],
            ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<_SortOption>(
      icon: const Icon(Icons.sort_rounded, color: Colors.white),
      onSelected: (opt) => setState(() => _sortOption = opt),
      itemBuilder: (context) => [
        const PopupMenuItem(value: _SortOption.dateDesc, child: Text('Newest first')),
        const PopupMenuItem(value: _SortOption.dateAsc, child: Text('Oldest first')),
        const PopupMenuItem(value: _SortOption.userAz, child: Text('User (A-Z)')),
        const PopupMenuItem(value: _SortOption.userZa, child: Text('User (Z-A)')),
      ],
    );
  }
}

class _AdminTicketList extends StatelessWidget {
  final List<SupportTicket> tickets;
  final VoidCallback onRefresh;

  const _AdminTicketList({required this.tickets, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No tickets found.'));
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return _AdminTicketCard(ticket: ticket, onRefresh: onRefresh);
        },
      ),
    );
  }
}

class _AdminTicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onRefresh;

  const _AdminTicketCard({required this.ticket, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketChatScreen(ticket: ticket, isAdminView: true),
          ),
        ).then((_) => onRefresh()),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: ticket.userAvatar != null
                        ? NetworkImage(ticket.userAvatar!)
                        : null,
                    child: ticket.userAvatar == null
                        ? Text(
                            (ticket.userName ?? '?')[0].toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.userName ?? 'Unknown User',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          DateFormat('MMM d, hh:mm a').format(ticket.updatedAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.title,
                style: const TextStyle(
                    color: AppColors.darkBrown,
                    fontWeight: FontWeight.w800,
                    fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isOpen = status == TicketStatus.open;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isOpen ? Colors.orange : Colors.blue).withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOpen ? 'OPEN' : 'CLOSED',
        style: TextStyle(
          color: isOpen ? Colors.orange : Colors.blue,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

enum _SortOption { dateDesc, dateAsc, userAz, userZa }
