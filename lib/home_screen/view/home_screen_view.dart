import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_2048/game_board/controller/bloc/game_board_bloc.dart';
import 'package:game_2048/game_board/controller/game_board_controller.dart';
import 'package:game_2048/game_board/repo/saved_game_board_repo.dart';
import 'package:game_2048/game_board/view/game_board_view.dart';
import 'package:game_2048/home_screen/view/home_screen_overlay_manager.dart';
import 'package:provider/provider.dart';

import 'home_screen_header.dart';

class HomeScreen extends StatelessWidget {

  static const maxGameWidth = 600;

  @override
  Widget build(BuildContext context) {
    return HomeScreenOverlayManager(
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () => OverlayNotification(
              OverlayNotificationType.remove,
              SettingsPopup.overlayKey,
            ).dispatch(context),
            child: Scaffold(
              body: Center(
                child: MultiRepositoryProvider(
                  providers: [
                    RepositoryProvider<SavedGameBoardRepository>(
                      create: (_) => SavedGameBoardRepository()
                    )
                  ],
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) =>
                          GameBoardBloc(RepositoryProvider.of<SavedGameBoardRepository>(context))
                      )
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: LayoutBuilder(
                        builder: (context, constraints){
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth.clamp(0, maxGameWidth),
                            ),
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // verticalDirection: VerticalDirection.up,
                            children: [
                              HomeScreenHeader(),
                              SizedBox(
                                height: 50,
                              ),
                              Flexible(
                                child: GameBoard()
                              ),
                            ],
                          ),);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
