import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/providers/theme_provider.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/text_styles.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/bottom_top_move_animation_view.dart';
import 'package:provider/provider.dart';

import '../../futures/my_user_bloc/my_user_bloc.dart';
import '../../models/setting_list_data.dart';

class ProfileScreen extends StatefulWidget {
  final AnimationController animationController;

  const ProfileScreen({Key? key, required this.animationController})
      : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<SettingsListData> userSettingsList = SettingsListData.userSettingsList;

  @override
  void initState() {
    widget.animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomTopMoveAnimationView(
        animationController: widget.animationController,
        child: Consumer<ThemeProvider>(
          builder: (context, provider, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Container(child: appBar()),
              ),
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(0.0),
                  itemCount: userSettingsList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        //setting screen view
                        if (index == 5) {
                          context
                              .read<SignInBloc>()
                              .add(const SignOutRequired());
                        }
                        //help center screen view

                        if (index == 3) {
                          NavigationServices(context).gotoHeplCenterScreen();
                        }
                        //Chage password  screen view

                        if (index == 0) {
                          NavigationServices(context)
                              .gotoChangepasswordScreen();
                        }
                        //Invite friend  screen view

                        if (index == 1) {
                          NavigationServices(context).gotoInviteFriend();
                        }
                        if (index == 4) {
                          NavigationServices(context).gotoWallet();
                        }
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 16),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      AppLocalizations(context).of(
                                        userSettingsList[index].titleTxt,
                                      ),
                                      style: TextStyles(context)
                                          .getRegularStyle()
                                          .copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Container(
                                    child: Icon(
                                        userSettingsList[index].iconData,
                                        color: AppTheme.secondaryTextColor
                                            .withOpacity(0.7)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Divider(
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return InkWell(
      onTap: () {
        NavigationServices(context).gotoEditProfile();
      },
      child: BlocBuilder<MyUserBloc, MyUserState>(
        builder: (context, state) {
          if (state.status == MyUserStatus.success) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${state.user!.firstname} ${state.user!.lastname}",
                          style: new TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          AppLocalizations(context).of("view_edit"),
                          style: new TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 24, top: 16, bottom: 16, left: 24),
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: AppTheme.grey.withOpacity(0.6),
                            offset: const Offset(2.0, 4.0),
                            blurRadius: 8),
                      ],
                    ),
                    child: state.user!.picture == ""
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40.0)),
                            child: Icon(CupertinoIcons.person,
                                size: 75.0, color: Colors.white70),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40.0)),
                            child: Image.network(
                              state.user!.picture!,
                            ),
                          ),
                  ),
                )
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "User",
                          style: new TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          AppLocalizations(context).of("view_edit"),
                          style: new TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 24, top: 16, bottom: 16, left: 24),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: AppTheme.grey.withOpacity(0.6),
                            offset: const Offset(2.0, 4.0),
                            blurRadius: 8),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      child: Icon(CupertinoIcons.person,
                          size: 75.0, color: Colors.white70),
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
