import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_bloc.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_event.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_state.dart';
import 'package:momento/screens/events/user_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FetchEventBloc fetchEventBloc;
  String creatorId = "";
  bool isSearchMode = false; // Move isSearchMode to state
  String searchQuery = ""; // To store the search query
  final TextEditingController searchController = TextEditingController();

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
    searchController.dispose(); // Dispose the search controller
    super.dispose();
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
                  automaticallyImplyLeading: false,
                  scrolledUnderElevation: 0,
                  title: isSearchMode
                      ? TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search events...',
                            hintStyle: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey[600],
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.black,
                          ),
                        )
                      : Text(
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
                    if (isSearchMode)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isSearchMode = false;
                            searchQuery = '';
                            searchController.clear();
                          });
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            isSearchMode = true;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _onRefresh();
                      },
                    ),
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
              if (state is FetchEventLoaded) {
                final filteredEvents = state.events
                    .where((event) =>
                        event.eventName.toLowerCase().contains(searchQuery) ||
                        event.description.toLowerCase().contains(searchQuery))
                    .toList();

                if (filteredEvents.isEmpty) {
                  return const Center(
                    child: Text('No events match your search.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    return EventCard(event: filteredEvents[index]);
                  },
                );
              } else if (state is FetchEventLoading) {
                return _buildLoadingList();
              } else if (state is FetchEventError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state is FetchEventEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Events Yet',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Text(
                          'Create your first event by tapping the + button below',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is FetchEventError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[300],
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          fetchEventBloc.add(FetchEventsByCreator(creatorId));
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
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

  Future<Future<FetchEventState>> _onRefresh() async {
    fetchEventBloc.add(RefreshEventsByCreator(creatorId));
    return fetchEventBloc.stream.firstWhere((state) =>
        state is FetchEventLoaded ||
        state is FetchEventError ||
        state is FetchEventEmpty);
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
                    color: Colors.white.withAlpha(51),
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
}

class EventCard extends StatelessWidget {
  final Event event;
  final String userId = prefs.getString('userId')!;

  EventCard({
    super.key,
    required this.event,
  });

  String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, y, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        bool isGuest = await isUserEventOrganizerOrCoorganizer(
            Supabase.instance.client, userId, event.id);

        print(!isGuest);
        if (!isGuest) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => GuestHome(
                    eventId: event.id,
                  )));
        } else {
          Navigator.of(context).pushNamed(
            'event_home',
            arguments: event,
          );
        }
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
                          event.location,
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

  Future<bool> isUserEventOrganizerOrCoorganizer(
    SupabaseClient supabase,
    String userId,
    int eventId,
  ) async {
    try {
      // First, check if user is the event creator
      final eventResponse = await supabase
          .from('event') // assuming your events table is named 'events'
          .select(
              'created_by') // assuming the creator column is named 'created_by'
          .eq('id', eventId)
          .single();

      // If user is the event creator, return true
      if (eventResponse != null && eventResponse['created_by'] == userId) {
        return true;
      }

      // If not the creator, check if user is a co-organizer
      final coorganizerResponse = await supabase
          .from('event_coorganizers')
          .select('user_id')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .single();

      // Return true if user is found in co-organizers
      return coorganizerResponse != null;
    } catch (error) {
      // Handle the case where no rows are found (not an error case)
      if (error is PostgrestException && error.code == 'PGRST116') {
        return false;
      }

      // Log other errors and rethrow
      print('Error checking user event role: $error');
      rethrow;
    }
  }
}
