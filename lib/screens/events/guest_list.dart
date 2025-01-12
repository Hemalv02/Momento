import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:momento/screens/events/fetch_guest_bloc/fetch_guest_bloc.dart';
import 'package:momento/screens/events/fetch_guest_bloc/fetch_guest_event.dart';
import 'package:momento/screens/events/fetch_guest_bloc/fetch_guest_state.dart';
import 'package:momento/screens/events/fetch_guest_bloc/guest_api.dart';
import 'package:momento/screens/events/guest_add.dart';

class GuestList extends StatefulWidget {
  final int eventId;

  const GuestList({super.key, required this.eventId});

  @override
  State<GuestList> createState() => _GuestListState();
}

class _GuestListState extends State<GuestList> {
  late FetchGuestBloc fetchGuestBloc;

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
    fetchGuestBloc.add(RefreshGuestsByEventId(widget.eventId));
    await fetchGuestBloc.stream.firstWhere(
        (state) => state is FetchGuestLoaded || state is FetchGuestError);
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
          onPressed: () {
            showGuestModal(
              context,
              widget.eventId,
              () {
                // Trigger a refresh after modal pop
                _onRefresh();
              },
            );
          },
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
                  itemCount: guests.length,
                  itemBuilder: (context, index) {
                    final guest = guests[index];
                    return GuestCard(guest: guest);
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

class GuestCard extends StatelessWidget {
  final Guest guest;

  const GuestCard({
    super.key,
    required this.guest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color.fromARGB(255, 240, 246, 252),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          guest.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF003675),
          ),
        ),
        subtitle: Text(
          guest.email,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
