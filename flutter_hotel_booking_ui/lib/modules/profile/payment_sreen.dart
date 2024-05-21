  import 'dart:async';

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/widgets/widget_support.dart';
import 'package:user_repository/user_repository.dart';

import '../../routes/route_names.dart';


  class PaymentScreen extends StatefulWidget {
    const PaymentScreen({super.key});

    @override
    State<PaymentScreen> createState() => _PaymentScreenState();
  }

  class _PaymentScreenState extends State<PaymentScreen> {
  String? userId, wallet;
  num total=0;
  int amount2=0,amount1=0;

  void startTimer(){
    Timer(Duration(seconds: 3), () { 
      
      amount2= int.parse(total.toString());  
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
            return snapshot.hasData
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];          
                      total =  total + ds["PerNight"];                       
                      return Container(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Container(
                                    height: 90,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Center(child: Text("\$")),
                                  ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.network(ds["ImagePath"],
                                      height: 90,
                                      width: 90,
                                      fit: BoxFit.cover,
                                    )),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      ds["Name"],
                                      //style: AppWidget.semiBoldTextFeildStyle(),
                                    ),
                                    Text(
                                    "\$"+ ds["PerNight"].toString(),
                                      //style: AppWidget.semiBoldTextFeildStyle(),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                : CircularProgressIndicator();
          });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 60.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                  elevation: 2.0,
                  child: Container(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Center(
                          child: Text(
                        "PAYMENT",                         
                          style: AppWidget.LightTextFeildStyle(),
                      )))),
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: MediaQuery.of(context).size.height/2,
                child: roomPayment()),
              Spacer(),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Price",
                     // style: AppWidget.boldTextFeildStyle(),
                    ),
                    Text(
                "\$"+ total.toString(),
                     // style: AppWidget.semiBoldTextFeildStyle(),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: ()async{
                int amount= int.parse(wallet!)-amount2;
                await FirebaseUserRepository().updateUserWallet(userId!, amount.toString());
                await FirebaseUserRepository().saveUserWallet(amount.toString());
               
                openEdit();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.black, borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
                  child: Center(
                      child: Text(
                    "CheckOut",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              )
            ],
          ),
        ),
      );
    }

  Future openEdit() => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                                NavigationServices(context).gotoIntroductionScreen();
                            },
                            child: Icon(Icons.check_circle,color: Colors.green,),),
                        SizedBox(
                          width: 60.0,
                        ),
                        Center(
                          child: Text(
                            "Payment Success",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.lightGreen.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text("Thanks you"),
                    SizedBox(
                      height: 10.0,
                    ),
                    
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: (){
                         NavigationServices(context).gotoLoginApp();
                        },
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Color(0xFF008080),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: Text(
                            "Home",
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
          );
  }
