import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  String _log = 'output:\n';
  final _apiKey =
      TextEditingController(text: "75e5d2b6-fbd2-4b38-9a22-3652d2833b0d");
  final _cluster = TextEditingController(text: "mt1");
  final _channelName = TextEditingController(text: "private-chatroom-1");
  final _eventName = TextEditingController(text: "newMessage");

  //test-channel , test-event
  final _channelFormKey = GlobalKey<FormState>();
  final _eventFormKey = GlobalKey<FormState>();
  final _listViewController = ScrollController();
  final _data = TextEditingController();

  void log(String text) {
    print("LOG: $text");
    setState(() {
      _log += text + "\n";
      Timer(
          const Duration(milliseconds: 100),
          () => _listViewController
              .jumpTo(_listViewController.position.maxScrollExtent));
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onConnectPressed() async {
    if (!_channelFormKey.currentState!.validate()) {
      return;
    }
    // Remove keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("apiKey", "75e5d2b6-fbd2-4b38-9a22-3652d2833b0d");
    prefs.setString("cluster", "mt1");
    prefs.setString("channelName", "private-chatroom-1");

    try {
      await pusher.init(
          apiKey: "75e5d2b6-fbd2-4b38-9a22-3652d2833b0d",
          cluster: "mt1",
          onConnectionStateChange: onConnectionStateChange,
          onError: onError,
          onSubscriptionSucceeded: onSubscriptionSucceeded,
          onEvent: onEvent,
          onSubscriptionError: onSubscriptionError,
          onDecryptionFailure: onDecryptionFailure,
          onMemberAdded: onMemberAdded,
          onMemberRemoved: onMemberRemoved,
          onSubscriptionCount: onSubscriptionCount,
          host: "soketi.migworld.net",
          authEndpoint: "https://migworld.net/broadcasting/auth",
          useTLS: false,
          wsPort: 6001,
          wssPort: 6001,
          authParams: {
            "headers": {
              "Authorization":
                  "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMWY4MGIwZmIyNDJjMmUxYzAyNmQzOTE0NjIxZGY3ODRlZDZlODJjZDdjYTI3ZjQ0NGM3ZGE4OTMzODdkODE5NGU0YzhjMTIzOTFiMjEyMmUiLCJpYXQiOjE3MDk4NzYxOTQuMjI1Mjg4LCJuYmYiOjE3MDk4NzYxOTQuMjI1MjkyLCJleHAiOjE3NDE0MTIxOTQuMjIwMTAxLCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.SErt0nc6vgQpfxHoC3WsLO80WcNTMFC6_R7i6fA8wDepUdlUI3uMvmr5pk3zspuFe6QByrAu7KNV3xWwmRfUPThjupwYIL-LZUjFER54Bx9xrEMOql1sVMjE8K5ZH-aPHPLmB82Lol_kLPrxaUGcF_kEPjMSNZkYfCI46DRGtUq1vpfmxzGiNsILFjp1nFiTRb5aVxX5rvITYJsidhdyjxKGWobXDfHW_bnCdkAZQTvidjRSR0UYd0wiVmBucVtn-dG3NLWiQBQRdglLSqs-fpK0K-mHuPNy_bir-TpY-l6El4ZC39rqKi67mhdVCTedzjkv2rSpgZdQkYaZ5c9609Zq4iAT-XfXfHDZHCbcuojUi6U0_RHBipgDtwEFhdy8JGu61YEYYLyrJPtXc_QsBXG4uAfwCW_SFi12wcjpCvi7PX9U4kVYHu1XtQUy2r1TAKG4_8MQs40bFSoLuGv42POZq9hbpQhgI3QTSkfQWEPb2a222HSqy2XJItFq9fu1d8l3BrtfQ7oLaR7p6pNZRTHC-B9E2OlK6SU4MgcJPwyx_N-a9VV6rOxsPeD8xhovXm8s40mt5UYzDNqTk11gap9-8lxbFP3ZA8DVv4N3jALlGsnS4w8aKZGJGCzdrrFlDRnM8ENeRbRDVGc24YGV0s6xEqLUlDczvP0aZm2VFmw"
            }
          });
      await pusher.subscribe(channelName: "private-chatroom-1");
      await pusher.connect();
    } catch (e) {
      log("ERROR: $e");
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  void onEvent(PusherEvent event) {
    log("onEvent: $event");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = pusher.getChannel(channelName)?.me;
    log("Me: $me");
  }

  void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: ${e.toString()}");
  }

  void onDecryptionFailure(String event, String reason) {
    log("onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    log("onMemberAdded: $channelName user: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    log("onMemberRemoved: $channelName user: $member");
  }

  void onSubscriptionCount(String channelName, int subscriptionCount) {
    log("onSubscriptionCount: $channelName subscriptionCount: $subscriptionCount");
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    return {
      "auth": "foo:bar",
      "channel_data": '{"user_id": 1}',
      "shared_secret": "foobar"
    };
  }

  void onTriggerEventPressed() async {
    var eventFormValidated = _eventFormKey.currentState!.validate();

    if (!eventFormValidated) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("eventName", "newMessage");
    prefs.setString("data", _data.text);
    pusher.trigger(PusherEvent(
        channelName: "private-chatroom-1",
        eventName: "newMessage",
        data: _data.text));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey.text = "75e5d2b6-fbd2-4b38-9a22-3652d2833b0d";
      _cluster.text = "mt1";
      _channelName.text = "private-chatroom-1";
      _eventName.text = "newMessage";
      _data.text = prefs.getString("data") ?? 'test';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(pusher.connectionState == 'DISCONNECTED'
              ? 'Pusher Channels Example'
              : "private-chatroom-1"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
              controller: _listViewController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                if (pusher.connectionState != 'CONNECTED')
                  Form(
                      key: _channelFormKey,
                      child: Column(children: <Widget>[
                        TextFormField(
                          controller: _apiKey,
                          validator: (String? value) {
                            return (value != null && value.isEmpty)
                                ? 'Please enter your API key.'
                                : null;
                          },
                          decoration:
                              const InputDecoration(labelText: 'API Key'),
                        ),
                        TextFormField(
                          controller: _cluster,
                          validator: (String? value) {
                            return (value != null && value.isEmpty)
                                ? 'Please enter your cluster.'
                                : null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Cluster',
                          ),
                        ),
                        TextFormField(
                          controller: _channelName,
                          validator: (String? value) {
                            return (value != null && value.isEmpty)
                                ? 'Please enter your channel name.'
                                : null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Channel',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onConnectPressed,
                          child: const Text('Connect'),
                        )
                      ]))
                else
                  Form(
                    key: _eventFormKey,
                    child: Column(children: <Widget>[
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: pusher
                              .channels[_channelName.text]?.members.length,
                          itemBuilder: (context, index) {
                            final member = pusher
                                .channels[_channelName.text]!.members.values
                                .elementAt(index);

                            return ListTile(
                                title: Text(member.userInfo.toString()),
                                subtitle: Text(member.userId));
                          }),
                      TextFormField(
                        controller: _eventName,
                        validator: (String? value) {
                          return (value != null && value.isEmpty)
                              ? 'Please enter your event name.'
                              : null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Event',
                        ),
                      ),
                      TextFormField(
                        controller: _data,
                        decoration: const InputDecoration(
                          labelText: 'Data',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onTriggerEventPressed,
                        child: const Text('Trigger Event'),
                      ),
                    ]),
                  ),
                SingleChildScrollView(
                    scrollDirection: Axis.vertical, child: Text(_log)),
              ]),
        ),
      ),
    );
  }
}
