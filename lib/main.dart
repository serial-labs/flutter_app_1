import 'package:flutter/widgets.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

const swipeThreshold = 110;

class MyAppState extends ChangeNotifier {
// ${AnimalParts[i][AniPartIdx[i]]}.png
// print('part:$ap ${AniPartIdx[ap.index]}');

  var current = WordPair.random();
  double _newpartOpacity = 0;
  List<double> _partOpacity = [1, 1, 1, 1];
  int _duration = 100;
  int _extraDuration = 200;
  double x = 0.0;
  double y = 0.0;
  double xStart = 0.0;
  double yStart = 0.0;
  int swipeDir = 0;
  int newIdx = -1;
  String newFileName = 'assets/LION_V_400crop400/pixelT.png';

//  Color c = Color.fromARGB(200, random.nextInt(55) + 200, 240, 190);

// clic bouton à droite ou swipe vers droite => idx++
// clic bouton à gauche ou swipe vers gauche => idx--

// SWIPE
// pendant le swipe, on utilise une image extra B qui représente la partie "suivante" ou "précedente"

  void _touchDown(PointerEvent details, AniParts ap) {
    //un swipe va potentiellement commencer
    print("-- Starting SWIPE -- $ap");
    swipeDir = 0;
    //on stocke la position actuelle du pointeur
    xStart = details.position.dx;
    yStart = details.position.dy;
    // on raccourcit les durées d'animation (pendant le swipe, l'opacité suit le doigt)
    _duration = 50;
    _extraDuration = 100;
  }

  void _touchMove(PointerMoveEvent details, AniParts ap) {
    var offset = details.position.dx - xStart;
    _duration = 0;
    _extraDuration = 100;
    //print('newFileName: $newFileName');
    // on vérifie si le swipe en cours change de direction, auquel cas, changer l'image utilisée par l'image extra B
    if (swipeDir == 0 ||
        (offset > 0 && swipeDir <= 0) ||
        (offset < 0 && swipeDir >= 0)) {
      swipeDir = offset > 0 ? 1 : -1;
      newIdx =
          (AniPartIdx[ap.index] + swipeDir) % AnimalPartsFN[ap.index].length;
      print(
          'newIdx => newIdx: $newIdx   [(AniPartIdx[ap.index]:${AniPartIdx[ap.index]} - swipeDir:$swipeDir]');
      //if (newIdx < 0) newIdx = AnimalParts[ap.index].length - 1;
      //if (newIdx > AnimalParts[ap.index].length - 1) newIdx = 0;
      newFileName =
          'assets/LION_V_400crop400/${AnimalPartsFN[ap.index][newIdx]}.png';
      print('$swipeDir : $newFileName');
    }

    //ajustement des opacités en fonction de la distance parcourue par le doigt
    var i = ap.index;
    _newpartOpacity = (details.position.dx - xStart).abs() / swipeThreshold;
    if (_newpartOpacity > 1) _newpartOpacity = 1;
    _partOpacity[i] = 1 - _newpartOpacity;

    //if (_partOpacity[i] < 0) _partOpacity[i] = 0;
    print('touchDown => newFileName: $newFileName');
    notifyListeners();
  }

  void _touchUp(PointerEvent details, AniParts ap) {
    //FIN DU SWIPE
    if (swipeDir == 0) return; // rien ne s'est passé depuis le touchDown

    var offset = details.position.dx - xStart;
    //deux cas à envisager : 1 swipe validé ou 2 swipe annulé
    if (offset.abs() > swipeThreshold) {
      //1. swipe valide => A récupère la nouvelle image, B l'ancienne,
      // A&B inversent leurs opacités et A va vers 1, B vers 0
      //changeBodyPart(ap, 1);
      //print('old : AniPartIdx[ap.index] ${AniPartIdx[ap.index]} - newIdx:$newIdx');
      var api = AniPartIdx[ap.index];
      AniPartIdx[ap.index] = newIdx;
      newIdx = api;
      //print('new : AniPartIdx[ap.index] ${AniPartIdx[ap.index]} - newIdx:$newIdx');

      //print('old : _partOpacity[ap.index] ${_partOpacity[ap.index]} - _newpartOpacity:$_newpartOpacity');
      var apiO = _partOpacity[ap.index];
      _partOpacity[ap.index] = _newpartOpacity;
      _newpartOpacity = apiO;
      //print('new : _partOpacity[ap.index] ${_partOpacity[ap.index]} - _newpartOpacity:$_newpartOpacity');

      // Eventuellement, possibilité de programmer un changement de valeur dans le futur.
      // Future.delayed(Duration(seconds: 1), () {
      //   _partOpacity[ap.index] = 1;
      //   _newpartOpacity = 0;
      //   print(
      //       'new : ap.index ${ap.index} - AniPartIdx[ap.index]:${AniPartIdx[ap.index]} - ${AnimalPartsFN[ap.index][AniPartIdx[ap.index]]}');
      //   print("Executed after 2 seconds");
      //});
      //(AniPartIdx[ap.index] + swipeDir) % AnimalPartsFN[ap.index].length;
    } else {
      //1. Cancel, on revient aux opaxités initiales, avec effet d'animation
      _partOpacity[ap.index] = 1;
      _newpartOpacity = 0;
      _duration = 700;
      _extraDuration = 500;
    }
    swipeDir = 0;
    notifyListeners();
  }

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

  // void changeBodyPart(AniParts ap, int delta) {
  //   print('part:$ap ${AniPartIdx[ap.index]}');
  //   AniPartIdx[ap.index] += delta;
  //   if (AniPartIdx[ap.index] < 0)
  //     AniPartIdx[ap.index] = AnimalPartsFN[ap.index].length - 1;
  //   if (AniPartIdx[ap.index] >= AnimalPartsFN[ap.index].length)
  //     AniPartIdx[ap.index] = 0;
  //   print('part:$ap ${AniPartIdx[ap.index]}');
  //   notifyListeners();
  // }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 2;
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

enum AniParts { torso, head, tail, legs }

List<int> AniPartsSwipeZonesIdx = [1, 0, 2, 3];
List<List<String>> AnimalPartsFN = [
  [
    "LION_HOLD_apple",
    "LION_HOLD_cross",
    "LION_HOLD_heart",
    "LION_HOLD_pilgrim",
    "LION_HOLD_sword"
  ],
  ["LION_T1_V", "LION_T2_V", "LION_T3_V"],
  ["LION_Qf_V", "LION_Qn_V", "LION_Q-_V", "LION_Qno_V"],
  ["LION_RAMP_legs", "LION_SALI_legs", "LION_SEAA_legs", "LION_DRAG_legs"],
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
                AniPartIdx[ee.index] =
                    (AniPartIdx[ee.index] - 1) % AnimalPartsFN[ee.index].length;
                appState.notifyListeners();
              },
              icon: Icon(Icons.arrow_left),
              label: Text(
                  '${ee.toString().replaceAll('AniParts.', '')}(${AniPartIdx[ee.index]})'),
            ),
        ]),

        //////// HERE COMES THE STACK
        Stack(
          children: [
            AnimatedOpacity(
              opacity: appState._newpartOpacity,
              duration: Duration(milliseconds: appState._extraDuration),
              child: Image.asset(appState.newFileName),
            ),
            for (int i = 0; i < 4; i++)
              AnimatedOpacity(
                opacity: appState._partOpacity[i],
                duration: Duration(milliseconds: appState._duration),
                child: Image.asset(
                    'assets/LION_V_400crop400/${AnimalPartsFN[i][AniPartIdx[i]]}.png'),
              ),
            Column(
              children: [
                for (int i = 0; i < 4; i++)
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Listener(
                      onPointerDown: (PointerDownEvent pde) {
                        appState._touchDown(
                            pde, AniParts.values[AniPartsSwipeZonesIdx[i]]);
                      },
                      onPointerUp: (PointerUpEvent pue) {
                        appState._touchUp(
                            pue, AniParts.values[AniPartsSwipeZonesIdx[i]]);
                      },
                      onPointerMove: (PointerMoveEvent pme) {
                        appState._touchMove(
                            pme, AniParts.values[AniPartsSwipeZonesIdx[i]]);
                      },
                      child: Container(
                          height: 50,
                          width: 350,
                          color: Color.fromARGB(55, 120 + i * 40, 150, i * 80)),
                    ),
                  ),
              ],
            ),
          ],
        ),

        Column(mainAxisSize: MainAxisSize.min, children: [
          for (var ee in AniParts.values)
            ElevatedButton.icon(
              onPressed: () {
                AniPartIdx[ee.index] =
                    (AniPartIdx[ee.index] + 1) % AnimalPartsFN[ee.index].length;
                appState.notifyListeners();
                //appState.changeBodyPart(ee, 1);
              },
              icon: Icon(Icons.arrow_right),
              label: Text(
                  '${ee.toString().replaceAll('AniParts.', '')}(${AniPartIdx[ee.index]})'),
            ),
        ]),
      ],
    );
  }
}
