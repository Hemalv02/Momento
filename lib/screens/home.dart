import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_bloc.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_event.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FetchEventBloc fetchEventBloc;
  String creatorId = "";

  @override
  void initState() {
    super.initState();
    creatorId = prefs.getString('userId') ?? "";
    fetchEventBloc = FetchEventBloc(apiService: EventApiService());
    fetchEventBloc.add(FetchEventsByCreator(creatorId));
  }

  @override
  void dispose() {
    fetchEventBloc.close();
    super.dispose();
  }

  Future<Future<FetchEventState>> _onRefresh() async {
    fetchEventBloc.add(RefreshEventsByCreator(creatorId));
    return fetchEventBloc.stream.firstWhere(
        (state) => state is FetchEventLoaded || state is FetchEventError);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => fetchEventBloc,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 3.h),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  title: Text(
                    'Momento',
                    style: TextStyle(
                      fontFamily: "Lalezar",
                      fontSize: 36.sp,
                    ),
                  ),
                  foregroundColor: const Color(0xFF003675),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.sort_rounded),
                      onPressed: () {},
                    ),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.search)),
                  ],
                ),
                BlocBuilder<FetchEventBloc, FetchEventState>(
                  builder: (context, state) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3.h,
                      child: state is FetchEventLoading
                          ? LinearProgressIndicator(
                              backgroundColor: Colors.grey[400],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF003675),
                              ),
                            )
                          : Container(
                              color: Colors.grey,
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('create_event').then((_) {
              fetchEventBloc.add(FetchEventsByCreator(creatorId));
            });
          },
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF003675),
          child: const Icon(Icons.add),
        ),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF003675),
          child: BlocBuilder<FetchEventBloc, FetchEventState>(
            builder: (context, state) {
              if (state is FetchEventLoading) {
                // Show previous events during loading if available
                final previousEvents = state.previousEvents;
                if (previousEvents != null) {
                  return ListView.builder(
                    itemCount: previousEvents.length,
                    itemBuilder: (context, index) {
                      return EventCard(event: previousEvents[index]);
                    },
                  );
                }
                return _buildLoadingList();
              } else if (state is FetchEventLoaded) {
                if (state.events.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  itemCount: state.events.length,
                  itemBuilder: (context, index) {
                    // Sort events by createdAt in descending order (newest first)
                    final sortedEvents = List<Event>.from(state.events)
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return EventCard(event: sortedEvents[index]);
                  },
                );
              } else if (state is FetchEventError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return const Center(
                child: Text('Unexpected state occurred.'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header shimmer
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: const BoxDecoration(
                  color: Color(0xFF003675),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Container(
                  height: 24.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Content shimmer
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F6FC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: List.generate(
                      4,
                      (index) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  width: 200.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - kToolbarHeight - 50,
        child: const Center(
          child: Text('No events available.'),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, y, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).pushNamed(
          'event_home',
          arguments: event,
        ),
      },
      child: Card(
        // clickable
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: const Color.fromARGB(255, 240, 246, 252),
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF003675),
                child: Text(
                  event.eventName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dates
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        _buildDateInfo(
                          context,
                          Icons.calendar_today,
                          'Start Date',
                          formatDate(event.startDate),
                        ),
                        _buildDateInfo(
                          context,
                          Icons.calendar_today,
                          'End Date',
                          formatDate(event.endDate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Location:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "event.location",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Organizer
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Organized by ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          event.organizedBy,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(
    BuildContext context,
    IconData icon,
    String label,
    String date,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        // const SizedBox(height: 4),
        Text(
          date,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
