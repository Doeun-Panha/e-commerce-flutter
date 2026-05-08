import 'package:ecommerce/core/theme/app_theme.dart';
import 'package:ecommerce/features/auth/presentation/login_screen.dart';
import 'package:ecommerce/features/products/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class StartUpScreen extends StatelessWidget{
  const StartUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildMainContent(context),
    );
  }
  
  Widget _buildMainContent(BuildContext context){
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIllustration(),
              SizedBox(height: 100,),
              _buildComponent(context),
            ],
          ),
        ),
    );
  }

  Widget _buildIllustration(){
    return Image.asset(
      'assets/images/illustration.jpg',
      height: 300,
      fit: BoxFit.contain,
    );
  }

  Widget _buildComponent(BuildContext context){
    return Column(
      children: [
        _buildTextSection(context),
        SizedBox(height: 74,),
        _buildButtonRow(context)
      ],
    );
  }

  Widget _buildTextSection(BuildContext context){
    return Column(
      children: [
        Text(
          'Start Purchasing \n All Kinds of Products Here',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        SizedBox(height: 33,),
        Text(
          'Explore the vase varieties of products online with our E-Commerce App',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildButtonRow(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.buttonContainerBorderRadius),
      ),
      padding: EdgeInsets.all(10),
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Login",
              color: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  )
                );
              },
            ),
          ),
      
          SizedBox(width: 10,),
      
          Expanded(
            child: CustomButton(
              text: "Register",
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                  )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}