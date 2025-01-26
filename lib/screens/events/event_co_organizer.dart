import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/co_organizer_add.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_bloc.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_event.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_state.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/organizer_fetch_api.dart';
import 'package:momento/screens/profile/UserProfileViewPage.dart';
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

  @override
  void initState() {
    super.initState();
    fetchCoorganizerBloc =
        FetchCoorganizerBloc(apiService: CoorganizerApiService());
    fetchCoorganizerBloc.add(FetchCoorganizerByEventId(widget.eventId));
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

      if (response != null && response['url'] != null) {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => fetchCoorganizerBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Co-organizer List'),
          backgroundColor: const Color(0xFF003675),
          foregroundColor: Colors.white,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showCoOrganizerModal(context, widget.eventId, widget.userId, () {
              _onRefresh();
            });
          },
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF003675),
          child: const Icon(Icons.add),
        ),
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

              if (state is FetchCoorganizerLoading && coorganizers == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF003675),
                  ),
                );
              }

              if (coorganizers != null && coorganizers.isNotEmpty) {
                return ListView.builder(
                  itemCount: coorganizers.length,
                  itemBuilder: (context, index) {
                    final coorganizer = coorganizers[index];
                    return FutureBuilder<Uint8List?>(
                      future: _getProfilePicture(coorganizer.username),
                      builder: (context, snapshot) {
                        final profilePic = snapshot.data;
                        return CoorganizerCard(
                          coorganizer: coorganizer,
                          profilePic: profilePic,
                        );
                      },
                    );
                  },
                );
              }

              if (state is FetchCoorganizerError && coorganizers == null) {
                return _buildEmptyState(message: 'No co-organizers found.');
              }

              return _buildEmptyState();
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
  }
}

class CoorganizerCard extends StatelessWidget {
  final Coorganizer coorganizer;
  final Uint8List? profilePic;

  const CoorganizerCard({
    super.key,
    required this.coorganizer,
    required this.profilePic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color.fromARGB(255, 240, 246, 252),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileViewPage(
                  viewedUsername: coorganizer.username,
                ),
              ),
            );
          },
          child: CircleAvatar(
            radius: 25.r,
            backgroundColor: profilePic == null
                ? const Color(0xFF003675)
                : Colors.transparent,
            foregroundColor: Colors.white,
            backgroundImage:
                profilePic != null ? MemoryImage(profilePic!) : null,
            child: profilePic == null ? Text(coorganizer.username[0]) : null,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileViewPage(
                viewedUsername: coorganizer.username,
              ),
            ),
          );
        },
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
  }
}
