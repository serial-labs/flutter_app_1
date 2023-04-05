import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe/swipe.dart';

void main() {
  runApp(MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class MyApp extends MaterialApp {
  const MyApp({super.key, ScrollBehavior: MyCustomScrollBehavior});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void changeBodyPart(AniParts ap, int delta) {
    print('part:$ap ${AniPartIdx[ap.index]}');
    AniPartIdx[ap.index] += delta;
    if (AniPartIdx[ap.index] < 0)
      AniPartIdx[ap.index] = AnimalParts[ap.index].length - 1;
    if (AniPartIdx[ap.index] >= AnimalParts[ap.index].length)
      AniPartIdx[ap.index] = 0;
    print('part:$ap ${AniPartIdx[ap.index]}');
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = AnimalCompo();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    String _message = 'Swipe your screen';
    return Swipe(
      child: Container(
        color: Colors.teal,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: Center(
            child: Text(_message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                )),
          ),
        ),
      ),
      onSwipeUp: () {
        setState(() {
          _message = 'Swiping up';
          print(_message);
        });
      },
      onSwipeDown: () {
        setState(() {
          _message = 'Swiping down';
          print(_message);
        });
      },
      onSwipeLeft: () {
        setState(() {
          _message = 'Swiping left';
          print(_message);
        });
      },
      onSwipeRight: () {
        setState(() {
          _message = 'Swiping right';
          print(_message);
        });
      },
    );

    //_ScaffoldAsRowWithBottomNav(page);
  }

  Widget _ScaffoldAsRowWithBottomNav(Widget page) {
    return Scaffold(
        appBar: AppBar(title: Text("MyBlazon")),
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorites'),
            BottomNavigationBarItem(
                icon: Icon(Icons.cruelty_free_outlined), label: 'Animal Compo'),
          ],
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              print("$selectedIndex => $value");
              selectedIndex = value;
            });
          },
        ));
  }

  Widget _ScaffoldAsRowWithNavRail(Widget page) {
    return Scaffold(
      body: Row(children: [
        SafeArea(
            child: NavigationRail(
          destinations: [
            NavigationRailDestination(
                icon: Icon(Icons.home), label: Text('Home')),
            NavigationRailDestination(
                icon: Icon(Icons.favorite), label: Text('Favorites')),
            NavigationRailDestination(
                icon: Icon(Icons.cruelty_free_outlined),
                label: Text('Animal Compo')),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) {
            setState(() {
              print("$selectedIndex => $value");
              selectedIndex = value;
            });
          },
        )),
        Expanded(
            child: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        ))
      ]),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('A random AWESOME idea:'),
          BigCard(pair: pair),
          Text('A random AWESOME idea:'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second} xx",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

enum AniParts { head, torso, legs, tail }

List<List<String>> AnimalParts = [
  ["LION_T1_V", "LION_T2_V", "LION_T3_V"],
  [
    "LION_HOLD_apple",
    "LION_HOLD_cross",
    "LION_HOLD_heart",
    "LION_HOLD_pilgrim",
    "LION_HOLD_sword"
  ],
  ["LION_RAMP_legs", "LION_SALI_legs", "LION_SEAA_legs", "LION_DRAG_legs"],
  ["LION_Qf_V", "LION_Qn_V", "LION_Q-_V", "LION_Qno_V"]
];
List<int> AniPartIdx = [0, 0, 0, 0];

class AnimalCompo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Row(
      children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          for (var ee in AniParts.values)
            ElevatedButton.icon(
              onPressed: () {
                appState.changeBodyPart(ee, -1);
              },
              icon: Icon(Icons.arrow_left),
              label: Text(ee.toString()),
            ),
        ]),
        Stack(
          children: [
            for (int i = 0; i < 4; i++)
              Image.asset(
                  'assets/LION_V_400crop400/${AnimalParts[i][AniPartIdx[i]]}.png'),
          ],
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          for (var ee in AniParts.values)
            ElevatedButton.icon(
              onPressed: () {
                appState.changeBodyPart(ee, 1);
              },
              icon: Icon(Icons.arrow_left),
              label: Text(ee.toString()),
            ),
        ]),
      ],
    );
  }
}
