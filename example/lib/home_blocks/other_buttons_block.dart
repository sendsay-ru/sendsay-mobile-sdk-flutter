import 'package:flutter/material.dart';

import '../page/app_inbox_list_page.dart';
import '../page/in_app_cb_carousel_page.dart';
import '../page/in_app_cb_page.dart';

class OtherButtonsBlock extends StatelessWidget {
  final Function(BuildContext) appInboxFetchAllCall;
  final Function(BuildContext) appInboxFetchItemCall;
  final Function(BuildContext) appInboxMarkItemAsReadCall;
  final Function(BuildContext) appInboxTrackItemAsOpenedCall;
  final Function(BuildContext) appInboxTrackItemAsClickedCall;
  final Function(BuildContext) trackPaymentEventCall;
  final Function(BuildContext) pluginSegmentsCallback;

  const OtherButtonsBlock({
    super.key,
    required this.appInboxFetchAllCall,
    required this.appInboxFetchItemCall,
    required this.appInboxMarkItemAsReadCall,
    required this.appInboxTrackItemAsOpenedCall,
    required this.appInboxTrackItemAsClickedCall,
    required this.trackPaymentEventCall,
    required this.pluginSegmentsCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: ElevatedButton(
            onPressed: () => appInboxFetchAllCall(context),
            child: const Text('Fetch all'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => appInboxFetchItemCall(context),
            child: const Text('Fetch first'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => appInboxMarkItemAsReadCall(context),
            child: const Text('Mark first as read'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => appInboxTrackItemAsOpenedCall(context),
            child: const Text('Track first as Opened'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => appInboxTrackItemAsClickedCall(context),
            child: const Text('Track first as Clicked'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => trackPaymentEventCall(context),
            child: const Text('Track payment event'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const InAppCbPage())),
            child: const Text('In App CB Example Page'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const InAppCbCarouselPage())),
            child: const Text('In App CB Carousel Example Page'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AppInboxListPage())),
            child: const Text('App inbox Example Page'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () => pluginSegmentsCallback(context),
            child: const Text('Get segments'),
          ),
        ),
      ],
    );
  }
}
