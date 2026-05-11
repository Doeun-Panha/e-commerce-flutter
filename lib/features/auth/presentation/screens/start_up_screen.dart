import 'package:ecommerce/core/theme/app_theme.dart';
import 'package:ecommerce/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartUpScreen extends StatelessWidget{
  const StartUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Spacer(flex: 2,),
              _IllustrationSection(),
              Spacer(flex: 2,),
              _WelcomeText(),
              Spacer(flex: 1,),
              _ActionContainer(),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustrationSection extends StatelessWidget{
  const _IllustrationSection();

  @override
  Widget build(BuildContext context){
    return Image.asset(
      'assets/images/illustration.jpg',
      height: 300,
      fit: BoxFit.contain,
    );
  }
}

class _WelcomeText extends StatelessWidget{
  const _WelcomeText();

  @override
  Widget build(BuildContext context){
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'Start Purchasing \n All Kinds of Products Here',
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 24),
        Text(
          'Explore the vast varieties of products online with our E-Commerce App',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ActionContainer extends StatelessWidget{
  const _ActionContainer();

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.buttonContainerBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
                text: "Login",
                color: colorScheme.primary,
                textColor: colorScheme.onPrimary,
                onPressed: () => context.push('/login')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
                text: "Register",
                onPressed: () => context.push('/register')),
          )
        ],
      ),
    );
  }
}
