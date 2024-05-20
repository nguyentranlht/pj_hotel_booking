import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/my_user_bloc/my_user_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/update_profile_bloc/profile_controller.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_appbar_view.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
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
                                  CommonAppbarView(
                                    iconData: Icons.check,
                                    titleText: AppLocalizations(context)
                                        .of("edit_profile"),
                                    onBackClick: () {
                                      provider.showConformDialogAlert(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  SizedBox(
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
                                                      ? Icon(
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
                                                                null)
                                                              return child;
                                                            return Center(
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
                                          child: Icon(
                                            Icons.add,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
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
                                        title: 'First name',
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
                                          title: 'Last name',
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
                                          title: 'Phone',
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
                                          title: 'Birthday',
                                          iconData: Icons.cake_outlined,
                                          value: state.user!.birthday == ""
                                              ? 'dd/MM/YYY'
                                              : state.user!.birthday)),
                                  ReusbaleRow(
                                      title: 'Email',
                                      iconData: Icons.email_outlined,
                                      value: state.user!.email),
                                ],
                              );
                            } else {
                              return Center(
                                  child: Text(
                                'Something went wrong',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ));
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
// class _EditProfileState extends State<EditProfile> {
//   List<SettingsListData> userInfoList = SettingsListData.userInfoList;
//   FireBaseProvider get provider => provider;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Scaffold(
//         backgroundColor: AppTheme.scaffoldBackgroundColor,
//         body: RemoveFocuse(
//           onClick: () {
//             FocusScope.of(context).requestFocus(FocusNode());
//           },
//           child: BlocProvider(
//             create: (context) => MyUserBloc(
//                 myUserRepository:
//                     context.read<AuthenticationBloc>().userRepository)
//               ..add(GetMyUser(
//                   myUserId:
//                       context.read<AuthenticationBloc>().state.user!.uid)),
//             child: BlocBuilder<MyUserBloc, MyUserState>(
//               builder: (context, state) {
//                 if (state.status == MyUserStatus.success) {
//                   return Column(
//                     //mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       CommonAppbarView(
//                         iconData: Icons.arrow_back,
//                         titleText: AppLocalizations(context).of("edit_profile"),
//                         onBackClick: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                       Padding(
//                           padding: EdgeInsets.only(
//                               bottom:
//                                   16 + MediaQuery.of(context).padding.bottom),
//                           child: getProfileUI(state.user!.picture!)),
//                       Padding(
//                           padding: EdgeInsets.only(
//                               bottom:
//                                   16 + MediaQuery.of(context).padding.bottom),
//                           child: InkWell(
//                             onTap: () {},
//                             child: Column(
//                               children: <Widget>[
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 8, right: 16),
//                                   child: Row(
//                                     children: <Widget>[
//                                       GestureDetector(
//                                         onTap: () {
//                                           provider.showUserNameDialogAlert(
//                                               context,
//                                               '${state.user!.firstname} ${state.user!.lastname}');
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 16.0, bottom: 16, top: 16),
//                                           child: Text(
//                                             AppLocalizations(context)
//                                                 .of(userInfoList[1].titleTxt),
//                                             style: TextStyles(context)
//                                                 .getDescriptionStyle()
//                                                 .copyWith(
//                                                   fontSize: 16,
//                                                 ),
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 16.0, bottom: 16, top: 16),
//                                         child: Container(
//                                           child: Text(
//                                             "${state.user!.firstname} ${state.user!.lastname}",
//                                             style: TextStyles(context)
//                                                 .getRegularStyle()
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.w500,
//                                                   fontSize: 16,
//                                                 ),
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16, right: 16),
//                                   child: Divider(
//                                     height: 1,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )),
//                       Padding(
//                           padding: EdgeInsets.only(
//                               bottom:
//                                   16 + MediaQuery.of(context).padding.bottom),
//                           child: InkWell(
//                             onTap: () {},
//                             child: Column(
//                               children: <Widget>[
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 8, right: 16),
//                                   child: Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 16.0, bottom: 16, top: 16),
//                                           child: Text(
//                                             AppLocalizations(context)
//                                                 .of(userInfoList[2].titleTxt),
//                                             style: TextStyles(context)
//                                                 .getDescriptionStyle()
//                                                 .copyWith(
//                                                   fontSize: 16,
//                                                 ),
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 16.0, bottom: 16, top: 16),
//                                         child: Container(
//                                           child: Text(
//                                             "${state.user!.email}",
//                                             style: TextStyles(context)
//                                                 .getRegularStyle()
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.w500,
//                                                   fontSize: 16,
//                                                 ),
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16, right: 16),
//                                   child: Divider(
//                                     height: 1,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )),
//                       Padding(
//                           padding: EdgeInsets.only(
//                               bottom:
//                                   16 + MediaQuery.of(context).padding.bottom),
//                           child: InkWell(
//                             onTap: () {},
//                             child: Column(
//                               children: <Widget>[
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 8, right: 16),
//                                   child: Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 16.0, bottom: 16, top: 16),
//                                           child: Text(
//                                             AppLocalizations(context)
//                                                 .of(userInfoList[4].titleTxt),
//                                             style: TextStyles(context)
//                                                 .getDescriptionStyle()
//                                                 .copyWith(
//                                                   fontSize: 16,
//                                                 ),
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 16.0, bottom: 16, top: 16),
//                                         child: Container(
//                                           child: Text(
//                                             "${state.user!.number}",
//                                             style: TextStyles(context)
//                                                 .getRegularStyle()
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.w500,
//                                                   fontSize: 16,
//                                                 ),
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16, right: 16),
//                                   child: Divider(
//                                     height: 1,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )),
//                       Padding(
//                           padding: EdgeInsets.only(
//                               bottom:
//                                   16 + MediaQuery.of(context).padding.bottom),
//                           child: InkWell(
//                             onTap: () {},
//                             child: Column(
//                               children: <Widget>[
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 8, right: 16),
//                                   child: Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 16.0, bottom: 16, top: 16),
//                                           child: Text(
//                                             AppLocalizations(context)
//                                                 .of(userInfoList[5].titleTxt),
//                                             style: TextStyles(context)
//                                                 .getDescriptionStyle()
//                                                 .copyWith(
//                                                   fontSize: 16,
//                                                 ),
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 16.0, bottom: 16, top: 16),
//                                         child: Container(
//                                           child: Text(
//                                             "${state.user!.birthday}",
//                                             style: TextStyles(context)
//                                                 .getRegularStyle()
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.w500,
//                                                   fontSize: 16,
//                                                 ),
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16, right: 16),
//                                   child: Divider(
//                                     height: 1,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )),
//                       CommonButton(
//                         padding: const EdgeInsets.only(
//                             right: 16.0, bottom: 16, top: 16),
//                         backgroundColor: Colors.lightGreen.shade700,
//                         buttonText:
//                             AppLocalizations(context).of("edit_profile"),
//                         onTap: () {},
//                       )
//                     ],
//                   );
//                 } else {
//                   return Container();
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget getProfileUI(String picture) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             width: 130,
//             height: 130,
//             child: Stack(
//               alignment: Alignment.center,
//               children: <Widget>[
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryColor,
//                     shape: BoxShape.circle,
//                     boxShadow: <BoxShadow>[
//                       BoxShadow(
//                         color: Theme.of(context).dividerColor,
//                         blurRadius: 8,
//                         offset: Offset(4, 4),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.all(Radius.circular(60.0)),
//                     child: Image.network(
//                       picture,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 6,
//                   right: 6,
//                   child: CommonCard(
//                     color: AppTheme.primaryColor,
//                     radius: 36,
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.all(Radius.circular(24.0)),
//                         onTap: () {},
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Icon(
//                             Icons.camera_alt,
//                             color: Theme.of(context).backgroundColor,
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
