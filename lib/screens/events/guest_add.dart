import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showGuestModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: const GuestModal(),
        ),
      );
    },
  );
}

class GuestModal extends StatefulWidget {
  const GuestModal({super.key});

  @override
  State<GuestModal> createState() => _GuestModalState();
}

class _GuestModalState extends State<GuestModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isInvited = false;
  String _guestType = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final guestData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'isInvited': _isInvited,
        'guestType': _guestType,
      };
      print(guestData); // Replace with your submission logic
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Add Guest',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF003675),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 5.h),
                      child: Text(
                        'Guest Name',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                              color: const Color(0xFF003675), width: 2.w),
                        ),
                        hintText: 'Enter guest name',
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      margin: EdgeInsets.only(bottom: 5.h),
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                              color: const Color(0xFF003675), width: 2.w),
                        ),
                        hintText: 'Enter email',
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      margin: EdgeInsets.only(bottom: 5.h),
                      child: Text(
                        'Guest Type',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: [
                        ChoiceChip(
                          side: BorderSide(
                            color: const Color(0xFF003675),
                            width: 1.w,
                          ),
                          backgroundColor: Colors.white,
                          label: Text(
                            'Chief',
                            style: TextStyle(
                                color: _guestType == 'Chief'
                                    ? Colors.white
                                    : const Color(0xFF003675)),
                          ),
                          selected: _guestType == 'Chief',
                          selectedColor: const Color(0xFF003675),
                          onSelected: (selected) {
                            setState(() {
                              _guestType = selected ? 'Chief' : '';
                            });
                          },
                        ),
                        ChoiceChip(
                          side: BorderSide(
                            color: const Color(0xFF003675),
                            width: 1.w,
                          ),
                          backgroundColor: Colors.white,
                          label: Text(
                            'Regular',
                            style: TextStyle(
                                color: _guestType == 'Regular'
                                    ? Colors.white
                                    : const Color(0xFF003675)),
                          ),
                          selected: _guestType == 'Regular',
                          selectedColor: const Color(0xFF003675),
                          onSelected: (selected) {
                            setState(() {
                              _guestType = selected ? 'Regular' : '';
                            });
                          },
                        ),
                        ChoiceChip(
                          side: BorderSide(
                            color: const Color(0xFF003675),
                            width: 1.w,
                          ),
                          backgroundColor: Colors.white,
                          label: Text(
                            'VIP',
                            style: TextStyle(
                                color: _guestType == 'VIP'
                                    ? Colors.white
                                    : const Color(0xFF003675)),
                          ),
                          selected: _guestType == 'VIP',
                          selectedColor: const Color(0xFF003675),
                          onSelected: (selected) {
                            setState(() {
                              _guestType = selected ? 'VIP' : '';
                            });
                          },
                        ),
                        ChoiceChip(
                          side: BorderSide(
                            color: const Color(0xFF003675),
                            width: 1.w,
                          ),
                          backgroundColor: Colors.white,
                          label: Text(
                            'Alumni',
                            style: TextStyle(
                                color: _guestType == 'Alumni'
                                    ? Colors.white
                                    : const Color(0xFF003675)),
                          ),
                          selected: _guestType == 'Alumni',
                          selectedColor: const Color(0xFF003675),
                          onSelected: (selected) {
                            setState(() {
                              _guestType = selected ? 'Alumni' : '';
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invite Guest',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Switch(
                          value: _isInvited,
                          activeColor: const Color(0xFF003675),
                          onChanged: (bool value) {
                            setState(() {
                              _isInvited = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    FilledButton(
                      onPressed: _handleSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF003675),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Add Guest',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
