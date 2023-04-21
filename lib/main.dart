import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Flutter Learning 001',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
          home: MyHomePage(),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  var allpairs = <WordPair>[];

  GlobalKey? allpairsKey;

  void getNext() {
    allpairs.insert(0, current);
    var animationList = allpairsKey?.currentState as AnimatedListState?;
    animationList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }

    notifyListeners();
  }

  void dismissFav(int index) {
    if (favorites.length > index) {
      favorites.removeAt(index);
      notifyListeners();
    }
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
    var colorScheme = Theme.of(context).colorScheme;
    Widget page;

    if (selectedIndex == 0) {
      page = GeneratorPage();
    } else if (selectedIndex == 1) {
      page = FavoritePage();
    } else {
      throw UnimplementedError("No widget for $selectedIndex");
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: page,
      ),
    );

    return LayoutBuilder(builder: (context, contraints) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text(
              "Flutter Learning 001",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          body: Row(
            children: [
              SafeArea(
                  child: NavigationRail(
                extended: contraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                      icon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(
                      icon: Icon(Icons.favorite), label: Text('Like'))
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              )),
              Expanded(
                  child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: mainArea))
            ],
          ));
    });
  }
}

class FavoritePage extends StatefulWidget {
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var items = appState.favorites.map((e) => e.asLowerCase).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.all(
              30.0,
            ),
            child: Text(items.isNotEmpty
                ? 'You\'ve got ${items.length} favorite${items.length > 1 ? 's' : ''}:'
                : "No favorites!")),
        Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400, childAspectRatio: 400 / 80),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.delete_outline, semanticLabel: "Delete",),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => appState.dismissFav(index),
                    ),
                    title: Text(items[index]),
                  );
                })
            ),
      ],
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
          Expanded(flex: 3, child: HistoryListView()),
          SizedBox(
            height: 10,
          ),
          BigCard(pair: pair),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next')),
            ],
          ),
          Spacer(flex: 2),
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
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(children: [
              Text(
                pair.first,
                style: style.copyWith(fontWeight: FontWeight.w200),
              ),
              Text(
                pair.second,
                style: style.copyWith(fontWeight: FontWeight.bold),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HistoryListViewPageState();
}

class _HistoryListViewPageState extends State<HistoryListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
      colors: [Colors.transparent, Colors.black],
      stops: [0.0, 0.5],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.allpairsKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        initialItemCount: appState.allpairs.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.allpairs[index];
          return SizeTransition(
              sizeFactor: animation,
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    appState.toggleFavorite(pair);
                  },
                  icon: appState.favorites.contains(pair)
                      ? Icon(
                          Icons.favorite,
                          size: 12,
                        )
                      : SizedBox(),
                  label: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
              ));
        },
      ),
    );
  }
}
