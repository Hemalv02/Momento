import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/co_organizer_add.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_bloc.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_event.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/fetch_organizer_state.dart';
import 'package:momento/screens/events/fetch_organizer_bloc/organizer_fetch_api.dart';

class EventCoOrganizer extends StatefulWidget {
  final int eventId;
  final String userId = prefs.getString('userId')!;

  EventCoOrganizer({super.key, required this.eventId});

  @override
  State<EventCoOrganizer> createState() => _EventCoOrganizerState();
}

class _EventCoOrganizerState extends State<EventCoOrganizer> {
  late FetchCoorganizerBloc fetchCoorganizerBloc;

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

  Future<void> _onRefresh() async {
    fetchCoorganizerBloc.add(RefreshCoorganizersByEventId(widget.eventId));
    await fetchCoorganizerBloc.stream.firstWhere((state) =>
        state is FetchCoorganizerLoaded || state is FetchCoorganizerError);
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
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showCoOrganizerModal(context, widget.eventId, widget.userId, () {
              // Trigger a refresh after modal pop
              _onRefresh();
            });
          },
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF003675),
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF003675),
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
                    return CoorganizerCard(coorganizer: coorganizer);
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

class CoorganizerCard extends StatelessWidget {
  final Coorganizer coorganizer;

  const CoorganizerCard({
    super.key,
    required this.coorganizer,
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
        leading: CircleAvatar(
          radius: 25.r,
          backgroundColor: Color(0xFF003675),
          foregroundColor: Colors.white,
          child: Text(coorganizer.username[0]),
          // backgroundColor: Colors.primaries[index % Colors.primaries.length],
        ),
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
