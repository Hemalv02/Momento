import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/events/budget_bloc/budget_api_service.dart';
import 'package:momento/screens/events/budget_bloc/budget_bloc.dart';
import 'package:momento/screens/events/event_budget.dart';
import 'package:momento/screens/events/event_co_organizer.dart';
import 'package:momento/screens/events/event_qa.dart';
import 'package:momento/screens/events/review/event_review.dart';
import 'package:momento/screens/events/event_schedule.dart';
import 'package:momento/screens/events/event_summary.dart';
import 'package:momento/screens/events/fetch_event_bloc/event_api.dart';
import 'package:momento/screens/events/food/food_list_screen.dart';
import 'package:momento/screens/events/guest_list.dart';
import 'package:momento/screens/events/notifications/notification_add.dart';
import 'package:momento/screens/events/todo_page.dart';

class EventHome extends StatefulWidget {
  const EventHome({super.key});

  @override
  State<EventHome> createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  bool isInitialized = false;
  late int eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final event = ModalRoute.of(context)?.settings.arguments;
      if (event is Event) {
        setState(() {
          eventId = event.id;
        });
      }
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Dashboard'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildQuickActions(),
            _buildEventManagement(),
            _buildSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: const BoxDecoration(
        color: Color(0xFF003675),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Events Await!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Manage your event efficiently',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _buildSection(
      'Quick Actions',
      [
        _buildFeatureItem(
          icon: Icons.people,
          label: 'Guests',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => GuestList(eventId: eventId)),
          ),
          isPrimary: true,
        ),
        _buildFeatureItem(
          icon: Icons.checklist,
          label: 'To-Do',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ToDoPage(eventId: eventId),
              ),
            );
          },
          isPrimary: true,
        ),
        _buildFeatureItem(
          icon: Icons.qr_code_scanner,
          label: 'Scanner',
          onTap: () => Navigator.of(context).pushNamed('ticket_scanner'),
        ),
        _buildFeatureItem(
          icon: Icons.monetization_on,
          label: 'Budget',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => BudgetBloc(BudgetApiService()),
                child: EventBudget(eventId: eventId),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventManagement() {
    return _buildSection(
      'Event Management',
      [
        _buildFeatureItem(
          icon: Icons.fastfood,
          label: 'Food',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodListScreen(eventId: eventId),
              ),
            );
          },
        ),
        _buildFeatureItem(
          icon: Icons.schedule,
          label: 'Schedule',
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventSchedule(
                  eventId: eventId,
                  isGuest: false,
                ),
              ),
            )
          },
        ),
        _buildFeatureItem(
          icon: Icons.notifications,
          label: 'Notify',
          onTap: () => showNotificationModal(context, eventId: eventId),
        ),
        _buildFeatureItem(
          icon: Icons.bar_chart,
          label: 'Reports',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TransactionSummaryWidget(eventId: eventId),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return _buildSection(
      'Additional Options',
      [
        _buildFeatureItem(
          icon: Icons.group_add,
          label: 'Organizers',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventCoOrganizer(eventId: eventId),
            ),
          ),
        ),
        _buildFeatureItem(
          icon: Icons.question_answer,
          label: 'Q&A',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionsScreen(eventId: eventId),
            ),
          ),
        ),
        _buildFeatureItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {},
        ),
        _buildFeatureItem(
          icon: Icons.reviews,
          label: 'Reviews',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReviewsScreen(eventId: eventId, isGuest: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF003675),
            ),
          ),
          SizedBox(height: 16.h),
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 0.9,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: items,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF003675).withAlpha(204),
          borderRadius: BorderRadius.circular(15),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withAlpha(13),
          //     blurRadius: 10,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(height: 8.h),
            Text(
              label.length > 10 ? '${label.substring(0, 10)}...' : label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
