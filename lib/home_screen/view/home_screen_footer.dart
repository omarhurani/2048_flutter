import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreenFooter extends StatelessWidget {

  static const String originalGameUrl = 'https://play2048.co/',
    buyMeACoffeeUrl = "https://www.buymeacoffee.com/omarhurani",
    githubUrl = "https://github.com/omarhurani/2048_flutter",
    websiteUrl = "https://portfolio.omarhurani.me";

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 13,
        fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
        height: 1.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  text: "Move the tiles using ",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 13,
                    fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
                  ),
                  children: [
                    TextSpan(
                      text: "keyboard arrow keys",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    TextSpan(
                      text: " or ",
                    ),
                    TextSpan(
                      text: "touch swipes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    TextSpan(
                      text: " to merge tiles and reach 2048.",
                    ),
                  ]
              )
          ),
          Text("Sound effects may not work with iOS and macOS users due to some browser restrictions."),
          GestureDetector(
            onTap: visitOriginalGame,
            child: RichText(
              text: TextSpan(
                text: "This game was created for demonstration purposes. Please ",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 13,
                  fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
                ),
                children: [
                  TextSpan(
                    text: "visit and support the original game.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline
                    )
                  )
                ]
              )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text("Omar Hurani, 2021"),
              ),

              Expanded(
                flex: 1,
                child: IconTheme(
                  data: IconThemeData(
                    color: Theme.of(context).primaryColor
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.local_pizza_rounded),
                        onPressed: visitBuyMeACoffee,
                        tooltip: "Buy me a pizza slice",
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.githubLogoFill),
                        onPressed: visitGithub,
                        tooltip: "GitHub repo",
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.globeSimpleBold),
                        onPressed: visitWebsite,
                        tooltip: "My website",
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void visitWebsite(){
    launch(websiteUrl);
  }

  void visitGithub(){
    launch(githubUrl);
  }

  void visitBuyMeACoffee(){
    launch(buyMeACoffeeUrl);
  }

  void visitOriginalGame(){
    launch(originalGameUrl);
  }
}
