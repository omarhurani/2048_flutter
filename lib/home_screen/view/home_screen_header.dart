import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_2048/game_board/controller/bloc/game_board_bloc.dart';
import 'package:game_2048/game_board/controller/event/game_board_event.dart';
import 'package:game_2048/game_board/controller/state/game_board_state.dart';
import 'package:game_2048/home_screen/view/home_screen_overlay_manager.dart';
import 'package:game_2048/sound_effect/controller/bloc/sound_effect_bloc.dart';
import 'package:game_2048/sound_effect/controller/event/sound_effect_event.dart';
import 'package:game_2048/utils/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'home_screen_view.dart';

class HomeScreenHeader extends StatelessWidget {
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var smallScreen = constraints.maxWidth < HomeScreen.maxGameWidth;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: (smallScreen ? 0 : 10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: smallScreen ? MainAxisAlignment.spaceAround : MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: smallScreen ? 1 : 5,
                  child: Align(
                    alignment: smallScreen ? Alignment.center : Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                          text: "2048",
                          style: smallScreen ? Theme.of(context).textTheme.headline2.copyWith(
                            height: 1,
                            fontWeight: FontWeight.bold,
                          ):
                          Theme.of(context).textTheme.headline1.copyWith(height: 1),

                          children: [
                            TextSpan(
                              text: "\nby Omar Hurani",
                              style: smallScreen ? Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600
                              ) :
                              Theme.of(context).textTheme.headline6,
                            )
                          ]
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: smallScreen ? 1 : 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: smallScreen
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.end,
                    children: [
                      Flex(
                        // direction: smallScreen ? Axis.vertical : Axis.horizontal,
                        direction: smallScreen ? Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BlocBuilder<GameBoardBloc, GameBoardState>(
                            builder: (context, state) =>
                                TweenAnimationBuilder<double>(
                                    tween: Tween(
                                        begin: 0, end: state?.score?.toDouble() ?? 0),
                                    duration: Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) {
                                      return ScoreIndicator(
                                        title: "Score",
                                        score: value.toInt(),
                                      );
                                    }),
                          ),
                          SizedBox(
                            width: 10,
                            height: 5,
                          ),
                          BlocBuilder<GameBoardBloc, GameBoardState>(
                            builder: (context, state) =>
                                TweenAnimationBuilder<double>(
                                    tween: Tween(
                                        begin: 0,
                                        end: state?.bestScore?.toDouble() ?? 0),
                                    duration: Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) {
                                      return ScoreIndicator(
                                        title: "Best " +
                                            (state != null
                                                ? "(${state.x} × ${state.y})"
                                                : ""),
                                        score: value.toInt(),
                                      );
                                    }),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if(!smallScreen)
                        NewGameWidget(),
                      if(!smallScreen)
                        SizedBox(
                          height: 10,
                        ),
                      if(!smallScreen)
                        SoundEffectMuteButton(),

                    ],
                  ),
                )
              ],
            ),
            if(smallScreen)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SoundEffectMuteButton(),
                  SizedBox(width: 5,),
                  NewGameWidget(),
                ],
              )
          ],
        ),
      );
    });
  }
}

class ScoreIndicator extends StatelessWidget {
  final String title;
  final int score;

  const ScoreIndicator({Key key, @required this.title, @required this.score})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor, borderRadius: borderRadius),
      padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title ?? '',
            style: Theme.of(context).textTheme.headline6.copyWith(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 18,
                ),
          ),
          Text(
            score?.toString() ?? '',
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontSize: 17,
                ),
          ),
        ],
      ),
    );
  }
}

class NewGameWidget extends StatefulWidget {
  @override
  _NewGameWidgetState createState() => _NewGameWidgetState();
}

class _NewGameWidgetState extends State<NewGameWidget>
    with TickerProviderStateMixin {
  TextEditingController widthController, heightController;
  GlobalKey<FormState> formKey;
  GlobalKey settingsIconKey;

  // bool showSettings = false;

  // AnimationController settingsPopupAnimationController;

  OverlayEntry _settingsPopupEntry;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey();
    settingsIconKey = GlobalKey();
    initInputControllers();
    initAnimationControllers();
  }

  void initInputControllers() {
    widthController = TextEditingController();
    heightController = TextEditingController();
    var game = context.read<GameBoardBloc>().state;
  }

  void initAnimationControllers() {
    // settingsPopupAnimationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 250),
    // );
  }



  @override
  void dispose() {
    // settingsPopupAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBoardBloc, GameBoardState>(
      listener: onGameStateChanged,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: startNewGame,
            child: Icon(
              PhosphorIcons.arrowsClockwiseBold,
              color: Theme.of(context).textTheme.bodyText1.color,
            )

            // Text("New Game", style: Theme.of(context).textTheme.headline6.copyWith(
            //     color: Theme.of(context).scaffoldBackgroundColor
            // ),)
            ),
          SizedBox(
            width: 5,
          ),
          TextButton(
              key: settingsIconKey,
              onPressed: toggleSettingsShown,
              child: Icon(
                /*(_settingsPopupEntry?.mounted ?? false) ? Icons.add_circle : */
                PhosphorIcons.plusBold,
                color: Theme.of(context).textTheme.bodyText1.color,
              )

              // Text("New Game", style: Theme.of(context).textTheme.headline6.copyWith(
              //     color: Theme.of(context).scaffoldBackgroundColor
              // ),)
              ),
        ],
      ),
    );
  }

  void toggleSettingsShown() async {
    // var settings = showSettings;
    setState(() {
      //   showSettings = !showSettings;
    });
    if (!(_settingsPopupEntry?.mounted ?? false)) {
      var animation = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      );
      _settingsPopupEntry = createSettingsPopupEntry(animation);
      OverlayNotification(
        OverlayNotificationType.insert,
        SettingsPopup.overlayKey,
        HomeScreenOverlayManagerEntry(
          _settingsPopupEntry,
          animation,
        ),
      ).dispatch(context);
      // Overlay.of(context).insert(_settingsPopupEntry);
      // settingsPopupAnimationController.forward();
    } else {
      // await settingsPopupAnimationController.reverse();
      OverlayNotification(
        OverlayNotificationType.remove,
        SettingsPopup.overlayKey,
      ).dispatch(context);
      // _settingsPopupEntry?.remove();
      _settingsPopupEntry = null;
    }
  }

  OverlayEntry createSettingsPopupEntry(Animation animation) {
    RenderBox renderBox = settingsIconKey.currentContext.findRenderObject();

    var offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(builder: (context) {
      return Positioned(
        right: MediaQuery.of(context).size.width -
            offset.dx -
            renderBox.size.width,
        top: offset.dy + 45,
        child: FadeTransition(
          opacity: animation,
          child: SettingsPopup(
            formKey: formKey,
            heightController: heightController,
            widthController: widthController,
            onStartPressed: startNewGame,
          ),
        ),
      );
    });
  }

  void startNewGame([int x, int y]) {
    // Provider.of<GameController>(context, listen: false)
    //     .initGame(x: x, y: y);
    context.read<GameBoardBloc>().add(GameBoardResetEvent(x, y));

    if ((_settingsPopupEntry?.mounted ?? false)) toggleSettingsShown();
  }

  void onGameStateChanged(_, GameBoardState game){
    if(game == null)
      return;
    widthController.text = game.x.toString();
    heightController.text = game.y.toString();
  }
}

class SettingsPopup extends StatelessWidget {
  static final overlayKey = 'settings-popup';

  final TextEditingController widthController, heightController;
  final GlobalKey<FormState> formKey;
  final void Function(int, int) onStartPressed;

  const SettingsPopup({
    Key key,
    @required this.widthController,
    @required this.heightController,
    @required this.formKey,
    @required this.onStartPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      borderRadius: borderRadius,
      elevation: 10,
      shadowColor: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   "Size",
            //   style:Theme.of(context).textTheme.headline6,
            //   textAlign: TextAlign.right,
            // ),

            Form(
              key: formKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      controller: widthController,
                      validator: sizeValidator,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(child: Icon(PhosphorIcons.xBold)),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      controller: heightController,
                      validator: sizeValidator,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: TextButton(
                  onPressed: startNewGame,
                  child: Text(
                    "Start",
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).scaffoldBackgroundColor),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void startNewGame() {
    if (!formKey.currentState.validate()) return;
    int width = int.tryParse(widthController.text) ?? 4;
    int height = int.tryParse(heightController.text) ?? 4;
    onStartPressed(width, height);
  }

  String sizeValidator(String value) {
    var intValue = int.tryParse(value);
    if (intValue == null) {
      return "";
    }
    if (intValue.clamp(GameBoardState.minSize, GameBoardState.maxSize) !=
        intValue) {
      return "Between ${GameBoardState.minSize} and ${GameBoardState.maxSize}";
    }
    return null;
  }
}

class SoundEffectMuteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var soundEffectBloc = context.watch<SoundEffectBloc>();
    return TextButton(
      onPressed: () => toggleMute(soundEffectBloc),
      child: Icon(
        (soundEffectBloc.state ?? true) ? PhosphorIcons.speakerHighFill : PhosphorIcons.speakerSlashFill,
        color: Theme.of(context).textTheme.bodyText1.color,
      )
    );
  }

  void toggleMute(SoundEffectBloc bloc){
    bloc.add(SoundEffectEvent.soundEnabledToggled);
  }
}
