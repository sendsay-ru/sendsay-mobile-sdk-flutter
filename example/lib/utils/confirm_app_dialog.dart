import 'package:flutter/material.dart';

import '../colors.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

Future<bool> confirmCustomDialog(
    BuildContext context, String title, Function action) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        title: Text(
          toBeginningOfSentenceCase(title),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Вы уверены, что хотите $title?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Нет',
              style: TextStyle(color: AppColors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              action();
              Navigator.pop(context, true);
            },
            child: const Text(
              'Да',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      );
    },
  );

  return result ?? true;
}

/* 


import 'package:egs_mobile_flutter/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> confirmAppExit(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      title: FittedBox(
        child: Row(
          children: [
            Text(
              'Выход из ',
              style:
                  AppStyleText.logoStyle.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              'Цифровой Петербург',
              style: AppStyleText.logoStyle,
            ),
          ],
        ),
      ),
      content: Text(
        'Вы уверены, что хотите выйти из приложения?',
        style: AppStyleText.listTitle.copyWith(color: AppColors.textPrimary),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Нет',
            style: AppStyleText.shortDescriptionTextStyle
                .copyWith(color: AppColors.accentLight),
          ),
        ),
        TextButton(
          onPressed: () =>
              SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop'),
          child: Text(
            'Да',
            style: AppStyleText.shortDescriptionTextStyle
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}



 */
