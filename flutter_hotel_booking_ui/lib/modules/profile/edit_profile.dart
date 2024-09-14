import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/my_user_bloc/my_user_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/update_profile_bloc/profile_controller.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.scaffoldBackgroundColor,
        body: ChangeNotifierProvider(
          create: (_) => ProfileController(),
          child: Consumer<ProfileController>(
            builder: (context, provider, child) {
              return SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: BlocProvider(
                          create: (context) => MyUserBloc(
                              myUserRepository: context
                                  .read<AuthenticationBloc>()
                                  .userRepository)
                            ..add(GetMyUser(
                                myUserId: context
                                    .read<AuthenticationBloc>()
                                    .state
                                    .user!
                                    .uid)),
                          child: BlocBuilder<MyUserBloc, MyUserState>(
                              builder: (context, state) {
                            if (state.status == MyUserStatus.success) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  AppBar(
                                    leading: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(
                                          Icons.arrow_back_ios_new_outlined,
                                          color: Color(0xFF373866),
                                        )),
                                    centerTitle: true,
                                    title: const Text(
                                      'Chỉnh Sửa Thông Tin',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Center(
                                            child: Container(
                                          height: 130,
                                          width: 130,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: AppTheme.primaryColor,
                                                  width: 5)),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: provider.image == null
                                                  ? state
                                                              .user!.picture
                                                              .toString() ==
                                                          ""
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 40,
                                                        )
                                                      : Image(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                              state
                                                                  .user!.picture
                                                                  .toString()),
                                                          loadingBuilder: (context,
                                                              child,
                                                              loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          },
                                                          errorBuilder:
                                                              (context, object,
                                                                  stack) {
                                                            return Container(
                                                              child: Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color: AppTheme
                                                                    .redErrorColor,
                                                              ),
                                                            );
                                                          })
                                                  : Image.file(
                                                      File(provider.image!.path)
                                                          .absolute)),
                                        )),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          provider.pickeImage(
                                              context, state.user!.userId);
                                        },
                                        child: CircleAvatar(
                                          radius: 14,
                                          backgroundColor:
                                              AppTheme.primaryColor,
                                          child: const Icon(
                                            Icons.add,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      provider.showUserNameDialogAlert(
                                          context,
                                          state.user!.firstname,
                                          state.user!.userId);
                                    },
                                    child: ReusbaleRow(
                                        title: 'Họ',
                                        iconData: Icons.person_outlined,
                                        value: state.user!.firstname),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        provider.showUserLastNameDialogAlert(
                                            context,
                                            state.user!.lastname,
                                            state.user!.userId);
                                      },
                                      child: ReusbaleRow(
                                          title: 'Tên',
                                          iconData: Icons.person_outlined,
                                          value: state.user!.lastname)),
                                  GestureDetector(
                                      onTap: () {
                                        provider.showUserNumberDialogAlert(
                                            context,
                                            state.user!.number,
                                            state.user!.userId);
                                      },
                                      child: ReusbaleRow(
                                          title: 'Số điện thoại',
                                          iconData:
                                              Icons.phone_android_outlined,
                                          value: state.user!.number == ""
                                              ? 'xxx-xxx-xxx'
                                              : state.user!.number)),
                                  GestureDetector(
                                      onTap: () {
                                        provider.showUserBirthDayDialogAlert(
                                            context,
                                            state.user!.birthday,
                                            state.user!.userId);
                                      },
                                      child: ReusbaleRow(
                                          title: 'Ngày sinh',
                                          iconData: Icons.cake_outlined,
                                          value: state.user!.birthday == ""
                                              ? 'dd/MM/YYY'
                                              : state.user!.birthday)),
                                  ReusbaleRow(
                                      title: 'Email',
                                      iconData: Icons.email_outlined,
                                      value: state.user!.email),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: 400,
                                    height: 50,
                                    child: TextButton(
                                        onPressed: () {
                                          NavigationServices(context)
                                              .gotoLoginApp();
                                        },
                                        style: TextButton.styleFrom(
                                            elevation: 3.0,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(60))),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25, vertical: 5),
                                          child: Text(
                                            'Cập nhật thông tin',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        )),
                                  )
                                ],
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }))));
            },
          ),
        ));
  }
}

class ReusbaleRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;
  const ReusbaleRow(
      {Key? key,
      required this.title,
      required this.iconData,
      required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: Icon(iconData),
          trailing: Text(value),
        ),
        Divider(
          color: AppTheme.fontcolor,
        )
      ],
    );
  }
}
