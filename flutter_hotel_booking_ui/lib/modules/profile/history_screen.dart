  import 'dart:async';

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:user_repository/user_repository.dart';

import '../../language/appLocalizations.dart';
import '../../routes/route_names.dart';
import '../../widgets/common_appbar_view.dart';


 class HistoryScreen extends StatefulWidget {
    const HistoryScreen({super.key});

    @override
    State<HistoryScreen> createState() => _HistoryScreenState();
  }

  class _HistoryScreenState extends State<HistoryScreen> {
  String? userId, wallet;
  num total=0;
  int amount2=0,note=0;
  bool isSelected = false;  
 

  void startTimer(){
    Timer(Duration(seconds: 3), () { 
      
      amount2 = int.parse(total.toString());  
      setState(() {
        
      });
    });
  }

  getthesharedpref()async{
   
    userId= await FirebaseUserRepository().getUserId();
    wallet= await FirebaseUserRepository().getUserWallet();
  
  setState(() {
    
  });
  }

  ontheload()async{
  await getthesharedpref();


  roomStream = await FirebaseUserRepository().getRoomPayment(userId!);
  setState(() {
    
  });
  } 

  @override
    void initState() {
      ontheload();
      startTimer();
      super.initState();
    }
    
    Stream? roomStream;
    
  Widget roomPayment() {
  return StreamBuilder(
    stream: roomStream,
    builder: (context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }
      
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: snapshot.data.docs.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          DocumentSnapshot ds = snapshot.data.docs[index];
       
          if (ds["isSelected"] == true) {
            return Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(width: 20.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          ds["ImagePath"],
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Column(
                        children: [           
                          Text(ds["Name"],
                          style: AppWidget.semiBoldTextFeildStyle(),),
                          Text("\$" + ds["PerNight"].toString(),
                          style: AppWidget.semiBoldTextFeildStyle(),),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(width: 50),
                              Text("Thanh toán thành công",
                              style: TextStyle(
                                color: Color.fromARGB(255, 104, 159, 56),
                                fontSize: 15,
                                fontWeight: FontWeight.normal, 
                              ),
                              ),                         
                            ],
                          )   
                        ],
                        
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          // Trả về một Widget rỗng nếu điều kiện không thỏa mãn
         else{
          if (ds["isSelected"] == false) {
            return Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(width: 20.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          ds["ImagePath"],
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Column(
                        children: [           
                          Text(ds["Name"],
                          style: AppWidget.semiBoldTextFeildStyle(),),
                          Text("\$" + ds["PerNight"].toString(),
                          style: AppWidget.semiBoldTextFeildStyle(),),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(width: 60),
                              
                              Text("Lỗi thanh toán",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.normal, 
                              ),
                              ),                         
                            ],
                          )   
                        ],
                        
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
         }
        },
      );
    },
  );
}


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(        
          padding: EdgeInsets.only(top: 2.0),
          child: Column(            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                _appBar(),
              Material(    
                  elevation: 5.0,
                  child: Container(                   
                      padding: EdgeInsets.only(bottom: 2.0),        
                      )),
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: MediaQuery.of(context).size.height/1.5,
                child: roomPayment()),

              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      );
    }

  _appBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                              Icons.arrow_back_ios_new_outlined,
                               color: Color(0xFF373866),
                              )),
                              centerTitle: true,
                              title: Text(
                              "Lịch Sử Thanh Toán",
                              style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                            ),
                      );
  }

  
  }
