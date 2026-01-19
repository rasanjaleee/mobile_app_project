import 'package:flutter/material.dart';
import 'package:mobileapp/widgets/gradient_button.dart';

import '../theme/theme.dart';
import 'login_screen.dart';
import 'package:mobileapp/screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage('assets/images/welcome_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ), //
            ), //
          ), //
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ), // BoxDecoration
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 32,
                          color: AppTheme.primaryColor,
                        ), //
                      ), //
                      SizedBox(width:12),
                      Text(
                        "ShopNow",
                        style: TextStyle(
                          color :Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ), //
                  SizedBox(height: 12),
                  Text(
                    "Discover\nYour Style",
                    style: TextStyle(
                      color:Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height:1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "The best way to shop your favourite brands and discover new ones",
                    style: TextStyle(
                      color:Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height:1.5,
                    ),
                  ),
                  SizedBox(height: 48),
                  GradientButton(text:"Get Started",
                  onPressed: (){
                    Navigator.push(context,MaterialPageRoute(
                     builder: (context)=> SignupScreen()));
                  },),

                  SizedBox(height: 20),
                  SizedBox(
                    width : double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding:EdgeInsets.symmetric(vertical:16),
                        side : BorderSide(color:Colors.white),
                        shape :RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      ),
                        onPressed:(){
                       Navigator.push(context,MaterialPageRoute(
                      builder: (context)=> LoginScreen()));
                         } , child: Text(
                      'I already have an account',
                      style:TextStyle(
                        color:Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )


                    )
                    ),
                  ),
                  SizedBox(height:48),
                ],
              ), //
            ), //
          ) //
        ],
      ), //
    ); //
  }
}