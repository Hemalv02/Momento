import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/custom_widgets/build_loading_list.dart';
import 'package:momento/custom_widgets/empty_state.dart';
import 'package:momento/custom_widgets/error_state.dart';
import 'package:momento/custom_widgets/event_card.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_bloc.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_event.dart';
import 'package:momento/screens/events/fetch_event_bloc/fetch_event_state.dart';
import 'package:momento/custom_widgets/search_bar.dart' as custom_widgets;

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
                      ? custom_widgets.SearchBar(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },
                          onClose: () {
                            setState(() {
                              isSearchMode = false;
                              searchQuery = '';
                              searchController.clear();
                            });
                          },
                          isSearchMode: isSearchMode,
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
                    if (!isSearchMode)
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
                      onPressed: _onRefresh,
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
                          : Container(color: Colors.grey),
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

                return filteredEvents.isEmpty
                    ? const EmptyState(
                        message: 'No events match your search.',
                        icon: Icons.event_busy)
                    : ListView.builder(
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          return EventCard(
                              event: filteredEvents[index],
                              onEventTap: () {
                                Navigator.of(context).pushNamed(
                                  'event_home',
                                  arguments: filteredEvents[index],
                                );
                              });
                        },
                      );
              } else if (state is FetchEventLoading) {
                return buildLoadingList();
              } else if (state is FetchEventError) {
                return ErrorState(
                    message: state.message,
                    onRetry: () =>
                        fetchEventBloc.add(FetchEventsByCreator(creatorId)));
              } else {
                return const EmptyState(
                    message: 'No Events Yet', icon: Icons.event_busy);
              }
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
}
