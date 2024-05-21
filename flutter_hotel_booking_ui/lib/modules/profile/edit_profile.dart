import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ui/futures/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_hotel_booking_ui/language/appLocalizations.dart';
import 'package:flutter_hotel_booking_ui/utils/localfiles.dart';
import 'package:flutter_hotel_booking_ui/utils/text_styles.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_appbar_view.dart';
import 'package:flutter_hotel_booking_ui/widgets/common_card.dart';
import 'package:flutter_hotel_booking_ui/widgets/remove_focuse.dart';
import '../../futures/my_user_bloc/my_user_bloc.dart';
import '../../models/setting_list_data.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  List<SettingsListData> userInfoList = SettingsListData.userInfoList;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackgroundColor,
        body: RemoveFocuse(
          onClick: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: BlocProvider(
            create: (context) => MyUserBloc(
                myUserRepository:
                    context.read<AuthenticationBloc>().userRepository)
              ..add(GetMyUser(
                  myUserId:
                      context.read<AuthenticationBloc>().state.user!.uid)),
            child: BlocBuilder<MyUserBloc, MyUserState>(
              builder: (context, state) {
                if (state.status == MyUserStatus.success) {
                  return Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CommonAppbarView(
                        iconData: Icons.arrow_back,
                        titleText: AppLocalizations(context).of("edit_profile"),
                        onBackClick: () {
                          Navigator.pop(context);
                        },
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              bottom:
                                  16 + MediaQuery.of(context).padding.bottom),
                          child: getProfileUI(state.user!.picture!)),
                      Padding(
                          padding: EdgeInsets.only(
                              bottom:
                                  16 + MediaQuery.of(context).padding.bottom),
                          child: InkWell(
                            onTap: () {},
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 16),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0, bottom: 16, top: 16),
                                          child: Text(
                                            AppLocalizations(context)
                                                .of(userInfoList[1].titleTxt),
                                            style: TextStyles(context)
                                                .getDescriptionStyle()
                                                .copyWith(
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 16.0, bottom: 16, top: 16),
                                        child: Container(
                                          child: Text(
                                            "${state.user!.firstname} ${state.user!.lastname}",
                                            style: TextStyles(context)
                                                .getRegularStyle()
                                                .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Divider(
                                    height: 1,
                                  ),
                                )
                              ],
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              bottom:
                                  16 + MediaQuery.of(context).padding.bottom),
                          child: InkWell(
                            onTap: () {},
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 16),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0, bottom: 16, top: 16),
                                          child: Text(
                                            AppLocalizations(context)
                                                .of(userInfoList[2].titleTxt),
                                            style: TextStyles(context)
                                                .getDescriptionStyle()
                                                .copyWith(
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 16.0, bottom: 16, top: 16),
                                        child: Container(
                                          child: Text(
                                            "${state.user!.email}",
                                            style: TextStyles(context)
                                                .getRegularStyle()
                                                .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Divider(
                                    height: 1,
                                  ),
                                )
                              ],
                            ),
                          )),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget getProfileUI(String picture) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.of(context).dividerColor,
                        blurRadius: 8,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(60.0)),
                    child: Image.network(
                      picture,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: CommonCard(
                    color: AppTheme.primaryColor,
                    radius: 36,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.surface,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
