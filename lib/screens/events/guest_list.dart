import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/screens/events/fetch_guest_bloc/fetch_guest_bloc.dart';
import 'package:momento/screens/events/fetch_guest_bloc/fetch_guest_event.dart';
import 'package:momento/screens/events/fetch_guest_bloc/fetch_guest_state.dart';
import 'package:momento/screens/events/fetch_guest_bloc/guest_api.dart';
import 'package:momento/screens/events/guest_add.dart';
import 'package:momento/screens/profile/user_profile_view_page.dart'; // Add this import
import 'package:supabase_flutter/supabase_flutter.dart';

class GuestList extends StatefulWidget {
  final int eventId;

  const GuestList({super.key, required this.eventId});

  @override
  State<GuestList> createState() => _GuestListState();
}

class _GuestListState extends State<GuestList> {
  late FetchGuestBloc fetchGuestBloc;
  Key _listKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    fetchGuestBloc = FetchGuestBloc(apiService: GuestApiService());
    fetchGuestBloc.add(FetchGuestByEventId(widget.eventId));
  }

  @override
  void dispose() {
    fetchGuestBloc.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _listKey = UniqueKey();
    });
    fetchGuestBloc.add(RefreshGuestsByEventId(widget.eventId));
    await fetchGuestBloc.stream.firstWhere(
        (state) => state is FetchGuestLoaded || state is FetchGuestError);
  }

  void _handleAddGuest() {
    showGuestModal(
      context,
      widget.eventId,
      () {
        setState(() {
          _listKey = UniqueKey();
        });
        _onRefresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => fetchGuestBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guest List'),
          backgroundColor: const Color(0xFF003675),
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: _handleAddGuest,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF003675),
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF003675),
          child: BlocBuilder<FetchGuestBloc, FetchGuestState>(
            builder: (context, state) {
              List<Guest>? guests = state is FetchGuestLoaded
                  ? state.guests
                  : state is FetchGuestLoading
                      ? state.previousGuests
                      : state is FetchGuestError
                          ? state.previousGuests
                          : null;

              if (state is FetchGuestLoading && guests == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF003675),
                  ),
                );
              }

              if (guests != null && guests.isNotEmpty) {
                return ListView.builder(
                  key: _listKey,
                  itemCount: guests.length,
                  itemBuilder: (context, index) {
                    final guest = guests[index];
                    return GuestCard(
                      key: ValueKey('guest_${guest.id}_${_listKey}'),
                      guest: guest,
                    );
                  },
                );
              }

              if (state is FetchGuestError && guests == null) {
                return _buildEmptyState(message: 'No guests found.');
              }

              return _buildEmptyState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({String message = 'No guests available.'}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - kToolbarHeight - 50,
        child: Center(
          child: Text(message),
        ),
      ),
    );
  }
}

class GuestCard extends StatefulWidget {
  final Guest guest;

  const GuestCard({
    super.key,
    required this.guest,
  });

  @override
  State<GuestCard> createState() => _GuestCardState();
}

class _GuestCardState extends State<GuestCard> {
  String? username;
  String? profilePicUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final supabase = Supabase.instance.client;

    try {
      // Check if user exists
      final userResponse = await supabase
          .from('users')
          .select('username')
          .eq('email', widget.guest.email)
          .single();

      if (userResponse != null) {
        final fetchedUsername = userResponse['username'] as String;

        // Check if profile picture exists
        final profilePicResponse = await supabase
            .from('profile_pics')
            .select('url')
            .eq('username', fetchedUsername)
            .maybeSingle();

        setState(() {
          username = fetchedUsername;
          profilePicUrl = profilePicResponse?['url'] as String?;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> onDelete(Guest guest, BuildContext context) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('guests').delete().eq('id', guest.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${guest.name} deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildAvatar() {
    if (isLoading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF003675),
        ),
      );
    }

    if (username == null) {
      return const SizedBox.shrink();
    }

    if (profilePicUrl != null) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserProfileViewPage(viewedUsername: username!),
          ),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(profilePicUrl!),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileViewPage(viewedUsername: username!),
        ),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFF003675),
        child: Text(
          username![0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.guest.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        onDelete(widget.guest, context);
      },
      confirmDismiss: (direction) async {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content:
                Text('Are you sure you want to remove ${widget.guest.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      background: Container(
        color: const Color(0xFF003675),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: const Color(0xFF003675),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: const Color.fromARGB(255, 240, 246, 252),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: _buildAvatar(),
          title: Text(
            widget.guest.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF003675),
            ),
          ),
          subtitle: Text(
            widget.guest.email,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
