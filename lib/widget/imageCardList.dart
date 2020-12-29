library image_card_list;

/// Flutter widgets implementing Material Design.
import 'package:flutter/material.dart';

/// The [RenderObject] hierarchy is used by the Flutter Widgets library to implement
/// its layout and painting back-end.
import 'package:flutter/rendering.dart';

/// A scrollable list of image cards with less boilerplate code. Quick, dynamic and reusable.
/// By using [ImageCardList] instead of manually creating such list, you get:
/// - A scrollable list of pictures in a single step.
/// - More readable and reusable code structure.
/// - A largely reduced boilerplate.
/// - Easy integration.
/// - Flexibility over changing a lot of properties.
/// Extending [StatelessWidget], since the widget dosen't manage it's own state.
/// However an inherited [_FieldsWidget] is used to pass the value of the properties
/// to the descendents.
class ImageCardList extends StatelessWidget {
  ImageCardList(
      {Key key,
        @required this.map,
        @required this.displayNameTag,
        this.height = 200.0,
        this.width = 200.0,
        this.titleColor = Colors.black,
        this.fontSize = 20.0,
        this.borderRadius = 5.0,
        this.padding = const EdgeInsets.all(5.0),
        this.spacing = 5.0,
        this.elevation = 1.0,
        this.align = NameTagAlign.center,
        this.color = Colors.white,
        this.shadowColor = Colors.grey,
        this.scrollDirection = Axis.horizontal,
        this.semanticContainer = false,
        this.margin = const EdgeInsets.all(8.0),
        this.reverse = false,
        this.onTap})
      : assert(map != null),
        assert(height >= 50.0),
        assert(width >= 50.0),
        assert(!(fontSize < 0)),
        assert(!(borderRadius < 0)),
        assert(!(spacing < 0)),
        assert(!(elevation < 0)),
        super(key: key);

  /// @required parameter.
  /// [Map] object takes a map of {"name-tag" : "path",...,...} corresponding to the
  /// images you wish to use. Either be an asset image 'assets/imag001.jpeg' or a
  /// network image, say, 'http://example.com/images/pic-010.jpg'. The 'key' and
  /// 'value' both are of type [String] for ease. Example map:-
  /// {
  ///   "Tiger": "assets/tiger.jpg",
  ///   "Wolf": "https://i.ibb.co/Gp8xvsx/images-15.jpg",
  ///   "Leopard": "assets/leopard.jpeg",
  ///   "Zebra": "assets/zebra.jpg",
  ///   "Giraffe": "assets/giraffe.jpeg",
  ///   "Bear": "assets/bear.jpeg",
  ///   "Monkey": "assets/monkey.jpeg"
  /// }
  final Map<String, String> map;

  /// The axis along which the scroll view scrolls.
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// The name of image should be displayed or it shouldn't be.
  /// @required parameter.
  final bool displayNameTag;

  /// The height of [_ImageView].
  /// Defaults to '200'.
  final double height;

  /// The width of [_ImageView].
  /// Defaults to '200'.
  final double width;

  /// Font size of the image tag.
  /// Defaults to 20
  final double fontSize;

  /// border radius for [Card] shape property
  /// Defaults to 5.0
  final double borderRadius;

  /// Name tag color
  /// defaults to [Colors.black]
  final Color titleColor;

  /// border radius for [Card] elevation property
  final double elevation;

  /// Padding around [Column] thats holds [_ImageView] and name tag [Title]
  /// inside the [Card]. Defaults to [EdgeInsets] 5.0 from all sides,
  final EdgeInsetsGeometry padding;

  /// space between name tag[Text] and [_ImageView].
  /// Defaults to 5.0
  final double spacing;

  /// Alignment of the name tag.
  /// Defaults to [NameTagAlign.center]
  final NameTagAlign align;

  /// [Color] property of the [Card]
  /// Defaults to [Colors.white]
  final Color color;

  /// Shadow [Color] property of the [Card]
  /// Defaults to [Colors.grey]
  final Color shadowColor;

  /// Whether this widget represents a single semantic container.
  /// Defaults to false.
  final bool semanticContainer;

  /// Reversing the order of display.
  /// Defaults to true.
  final bool reverse;

  /// Margin form parent Container.
  /// Defaults to [EdgeInsets] 8.0 from all sides,
  final EdgeInsetsGeometry margin;

  /// onTap callback function
  /// Defaults to null.
  final _OnTapFunction onTap;

  /// Find [_FieldsWidget] up in the widget tree and access the card list instance.
  /// This returns the current state of [ImageCardList].
  static ImageCardList of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_FieldsWidget>()
        .imageCardList;
  }

  @override
  Widget build(BuildContext context) {
    /// The [List] object will hold the map of key,value pairs which in this
    /// case are image title and image path. The https:// paths won't be checked here.
    List<_ImageCard> list = List();

    /// If 'dispalyNameTag' is true, form [_ImageCard] list
    /// with imagePath and imageTitle.
    if (displayNameTag) {
      map.forEach((key, value) {
        list.add(_ImageCard(
          imagePath: value,
          imageTitle: key,
          onTap: onTap,
        ));
      });

      /// else if 'dispalyNameTag' is false, do it without imageTitle.
    } else {
      map.forEach((key, value) {
        list.add(_ImageCard(
          imagePath: value,
          onTap: onTap,
        ));
      });
    }

    /// Return [SingleChildScrollView] wrapped inside the [_FieldsWidget] for
    /// accessing properties in the hierarchy.
    return _FieldsWidget(
      imageCardList: this,
      child: Container(
        child: scrollDirection == Axis.horizontal
            ? SingleChildScrollView(
          reverse: reverse,
          padding: margin,
          scrollDirection: scrollDirection,
          child: Row(
            children: list,
          ),
        )
            : SingleChildScrollView(
          reverse: reverse,
          padding: margin,
          scrollDirection: scrollDirection,
          child: Column(
            children: list,
          ),
        ),
      ),
    );
  }
}

/// An image [Card] that holds [_ImageView] and [Title] (image name) in a [Column]
/// 'imagePath' could be one from assets or from network
class _ImageCard extends StatelessWidget {
  _ImageCard({Key key, @required this.imagePath, this.imageTitle, this.onTap})
      : super(key: key);

  /// @required
  /// Path of the image.
  final String imagePath;

  /// Image title which is not necessary in this class but parent class [ImageCardList]
  /// make it mandatory with the [Map] object.
  final String imageTitle;

  /// onTap callback function
  /// Defaults to null.
  final _OnTapFunction onTap;

  @override
  Widget build(BuildContext context) {
    /// get the card list instance for accessing the properties.
    var hicl = ImageCardList.of(context);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap(
              imageTitle,
              imagePath.contains("http")
                  ? Image.network(imagePath).image
                  : Image.asset(imagePath).image);
        }
      },
      child: Card(
        color: hicl.color,
        semanticContainer: hicl.semanticContainer,
        shadowColor: hicl.shadowColor,
        elevation: hicl.elevation,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(hicl.borderRadius)),
        child: Padding(
          padding: hicl.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: hicl.align == NameTagAlign.left
                ? CrossAxisAlignment.start
                : hicl.align == NameTagAlign.right
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center,
            children: <Widget>[
              _ImageView(
                height: hicl.height,
                // imageTitle == null
                //     ? hicl.height
                //     : hicl.height - (hicl.fontSize + 5),
                width: hicl.width,
                imagePath: imagePath,
              ),
              imageTitle != null
                  ? Padding(
                padding: EdgeInsets.only(top: hicl.spacing),
                child: Text(
                  imageTitle,
                  style: TextStyle(
                    color: hicl.titleColor,
                    fontSize: hicl.fontSize,
                  ),
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

/// For the alignment of the image title in the [_ImageCard].
enum NameTagAlign { left, right, center }

/// A wrapper around [SingleChildScrollView] which represents the [ImageCardList],
/// uses [InheritedWidget] efectively.
/// InheritedWidget is base class for widgets that efficiently propagate information down the tree.
/// To obtain the nearest instance of a particular type of inherited widget from a
/// build context, use [BuildContext.dependOnInheritedWidgetOfExactType].
class _FieldsWidget extends InheritedWidget {
  final ImageCardList imageCardList;

  _FieldsWidget({
    Key key,
    @required this.imageCardList,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_FieldsWidget oldWidget) => true;
}

/// A [Container] with [BoxDecoration] holding the actual image.
class _ImageView extends StatelessWidget {
  _ImageView({
    Key key,
    @required this.imagePath,
    this.height = 200.0,
    this.width = 200.0,
  }) : super(key: key);

  /// Image path, assets/network image
  final String imagePath;

  ///height defaults to 200
  final double height;

  ///width defaults to 200
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          /// Checking if it's a network image or an asset image and
          /// acting accordingly.
          image: imagePath.contains("http")
              ? Image.network(imagePath).image
              : AssetImage(imagePath),
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

/// On tap function scheme. Uses [ImageProvider] and [String] parameters.
typedef void _OnTapFunction(String name, ImageProvider<dynamic> image);