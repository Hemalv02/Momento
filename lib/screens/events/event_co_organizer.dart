import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/co_organizer_add.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_bloc.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_event.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_state.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/organizer_fetch_api.dart';
import 'package:momento/screens/profile/user_profile_view_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class EventCoOrganizer extends StatefulWidget {
  final int eventId;
  final String userId = prefs.getString('userId')!;

  EventCoOrganizer({super.key, required this.eventId});

  @override
  State<EventCoOrganizer> createState() => _EventCoOrganizerState();
}

class _EventCoOrganizerState extends State<EventCoOrganizer> {
  final supabase = Supabase.instance.client;
  late FetchCoorganizerBloc fetchCoorganizerBloc;
  final Map<String, Uint8List?> _profilePicsCache = {};
  String? organizerUsername;
  String? organizerEmail;
  String? organizerId;
  bool isLoading = true;
  bool isOrganizer = false;

  @override
  void initState() {
    super.initState();
    fetchCoorganizerBloc =
        FetchCoorganizerBloc(apiService: CoorganizerApiService());
    fetchCoorganizerBloc.add(FetchCoorganizerByEventId(widget.eventId));
    _fetchOrganizerInfo();
  }

  Future<void> _fetchOrganizerInfo() async {
    try {
      final eventResponse = await supabase
          .from('event')
          .select('created_by')
          .eq('id', widget.eventId)
          .single();

      if (eventResponse['created_by'] != null) {
        final organizerUserId = eventResponse['created_by'];

        setState(() {
          isOrganizer = organizerUserId == widget.userId;
          organizerId = organizerUserId;
        });

        final userResponse = await supabase
            .from('users')
            .select('username, email')
            .eq('id', organizerUserId)
            .single();

        setState(() {
          organizerUsername = userResponse['username'];
          organizerEmail = userResponse['email'];
          isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching organizer info: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    fetchCoorganizerBloc.close();
    super.dispose();
  }

  Future<Uint8List?> _getProfilePicture(String username) async {
    if (_profilePicsCache.containsKey(username)) {
      return _profilePicsCache[username];
    }

    try {
      final response = await supabase
          .from('profile_pics')
          .select('url')
          .eq('username', username)
          .single();

      if (response['url'] != null) {
        final url = response['url'];
        final imageResponse = await http.get(Uri.parse(url));

        if (imageResponse.statusCode == 200) {
          _profilePicsCache[username] = imageResponse.bodyBytes;
          return imageResponse.bodyBytes;
        }
      }
    } catch (error) {
      debugPrint('Error fetching profile picture: $error');
    }

    _profilePicsCache[username] = null;
    return null;
  }

  void _navigateToProfile(BuildContext context, String username) {
    if (username != prefs.getString('username')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileViewPage(
            viewedUsername: username,
          ),
        ),
      );
    }
  }

  Widget _buildOrganizerSection() {
    if (organizerUsername == null) {
      return const Center(child: Text('Organizer information not available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Organizer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003675),
            ),
          ),
        ),
        FutureBuilder<Uint8List?>(
          future: _getProfilePicture(organizerUsername!),
          builder: (context, snapshot) {
            final profilePic = snapshot.data;
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: const Color.fromARGB(255, 240, 246, 252),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () => _navigateToProfile(context, organizerUsername!),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: profilePic == null
                        ? const Color(0xFF003675)
                        : Colors.transparent,
                    foregroundColor: Colors.white,
                    backgroundImage:
                        profilePic != null ? MemoryImage(profilePic) : null,
                    child:
                        profilePic == null ? Text(organizerUsername![0]) : null,
                  ),
                ),
                onTap: () => _navigateToProfile(context, organizerUsername!),
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  organizerUsername!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF003675),
                  ),
                ),
                subtitle: Text(
                  organizerEmail!,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            );
          },
        ),
        const Divider(height: 32, thickness: 1),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Co-organizers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003675),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => fetchCoorganizerBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Organizers'),
          backgroundColor: const Color(0xFF003675),
          foregroundColor: Colors.white,
        ),
        floatingActionButton: isOrganizer
            ? FloatingActionButton(
                onPressed: () {
                  showCoOrganizerModal(context, widget.eventId, widget.userId,
                      () {
                    _onRefresh();
                  });
                },
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF003675),
                child: const Icon(Icons.add),
              )
            : null,
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: BlocBuilder<FetchCoorganizerBloc, FetchCoorganizerState>(
            builder: (context, state) {
              List<Coorganizer>? coorganizers = state is FetchCoorganizerLoaded
                  ? state.coorganizers
                  : state is FetchCoorganizerLoading
                      ? state.previousCoorganizers
                      : state is FetchCoorganizerError
                          ? state.previousCoorganizers
                          : null;

              // Show single loading indicator when either organizer info or co-organizers are loading
              if (isLoading ||
                  (state is FetchCoorganizerLoading && coorganizers == null)) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF003675),
                  ),
                );
              }

              return ListView(
                children: [
                  _buildOrganizerSection(),
                  if (coorganizers != null && coorganizers.isNotEmpty)
                    ...coorganizers.map((coorganizer) {
                      return FutureBuilder<Uint8List?>(
                        future: _getProfilePicture(coorganizer.username),
                        builder: (context, snapshot) {
                          final profilePic = snapshot.data;
                          return CoorganizerCard(
                            coorganizer: coorganizer,
                            profilePic: profilePic,
                            eventId: widget.eventId,
                            onProfileTap: () => _navigateToProfile(
                                context, coorganizer.username),
                            isOrganizer: isOrganizer,
                          );
                        },
                      );
                    }).toList()
                  else if (state is FetchCoorganizerError &&
                      coorganizers == null)
                    _buildEmptyState(message: 'No co-organizers found.')
                  else
                    _buildEmptyState(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({String message = 'No co-organizers available.'}) {
    return Center(child: Text(message));
  }

  Future<void> _onRefresh() async {
    fetchCoorganizerBloc.add(RefreshCoorganizersByEventId(widget.eventId));
    await fetchCoorganizerBloc.stream.firstWhere((state) =>
        state is FetchCoorganizerLoaded || state is FetchCoorganizerError);
    _fetchOrganizerInfo();
  }
}

class CoorganizerCard extends StatelessWidget {
  final Coorganizer coorganizer;
  final Uint8List? profilePic;
  final int eventId;
  final VoidCallback onProfileTap;
  final bool isOrganizer;

  const CoorganizerCard({
    super.key,
    required this.coorganizer,
    required this.profilePic,
    required this.eventId,
    required this.onProfileTap,
    required this.isOrganizer,
  });

  Future<void> deleteCoorganizer(String username, BuildContext context) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .single();

      if (response['id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User with username $username not found.'),
          ),
        );
        return;
      }

      final coorganizerId = response['id'];

      await supabase
          .from('event_coorganizers')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', coorganizerId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully removed $username as co-organizer.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove $username as co-organizer. $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color.fromARGB(255, 240, 246, 252),
      child: ListTile(
        leading: GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: profilePic == null
                ? const Color(0xFF003675)
                : Colors.transparent,
            foregroundColor: Colors.white,
            backgroundImage:
                profilePic != null ? MemoryImage(profilePic!) : null,
            child: profilePic == null ? Text(coorganizer.username[0]) : null,
          ),
        ),
        onTap: onProfileTap,
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          coorganizer.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF003675),
          ),
        ),
        subtitle: Text(
          coorganizer.email,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );

    if (isOrganizer) {
      return Dismissible(
        key: Key(coorganizer.username),
        direction: DismissDirection.startToEnd,
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
        onDismissed: (direction) async {
          await deleteCoorganizer(coorganizer.username, context);
        },
        confirmDismiss: (direction) async {
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Deletion'),
              content: Text(
                  'Are you sure you want to remove ${coorganizer.username}?'),
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
        child: cardContent,
      );
    }

    return cardContent;
  }
}
