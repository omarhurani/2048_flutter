import 'package:flutter/material.dart';

class HomeScreenOverlayManager extends StatefulWidget {

  final Widget child;

  const HomeScreenOverlayManager({
    Key key,
    this.child
  }) : super(key: key);

  @override
  HomeScreenOverlayManagerState createState() => HomeScreenOverlayManagerState();
}

class HomeScreenOverlayManagerState extends State<HomeScreenOverlayManager> {

  Map<dynamic, HomeScreenOverlayManagerEntry> entries = {};

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverlayNotification>(
      onNotification: (notification) => onNotification(context, notification),
      child: widget.child
    );
  }

  bool onNotification(context, OverlayNotification notification){
    setState(() {

    });
    switch(notification.type){
      case OverlayNotificationType.insert:
        if(notification.entry != null && !entries.containsKey(notification.key)){
          Overlay.of(context).insert(notification.entry.entry);
          entries[notification.key] = notification.entry;
          notification.entry.animation?.forward();
        }
        break;
      case OverlayNotificationType.remove:
        if(entries.containsKey(notification.key)){
          var entry = entries[notification.key];
          Future exitAnimationFuture = Future.value();
          if(entry.animation != null)
            exitAnimationFuture = entry.animation.reverse();
          exitAnimationFuture.then((value){
            entry.entry.remove();
            entries.remove(notification.key);
            entry.animation?.dispose();
          });
        }
        break;
      default:
    }
    return true;
  }
}

class OverlayNotification extends Notification{
  final OverlayNotificationType type;
  final dynamic key;
  final HomeScreenOverlayManagerEntry entry;

  OverlayNotification(
    this.type,
      this.key,
      [this.entry,]
  );
}

enum OverlayNotificationType{
  insert, remove
}

class HomeScreenOverlayManagerEntry{
  OverlayEntry entry;
  AnimationController animation;

  HomeScreenOverlayManagerEntry(this.entry, [this.animation]);
}