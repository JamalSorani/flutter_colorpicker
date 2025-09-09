/// Material Color Picker

library material_colorpicker;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

// The Color Picker which contains Material Design Color Palette.
class MaterialPicker extends StatefulWidget {
  const MaterialPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.onPrimaryChanged,
    this.enableLabel = false,
    this.portraitOnly = false,
    required this.colorTypes,
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color>? onPrimaryChanged;
  final bool enableLabel;
  final bool portraitOnly;

  final List<List<Color>> colorTypes;

  @override
  State<StatefulWidget> createState() => _MaterialPickerState();
}

class _MaterialPickerState extends State<MaterialPicker> {
  late final List<List<Color>> _colorTypes;
  late List<Color> _currentColorType;
  Color _currentShading = Colors.transparent;

  @override
  void initState() {
    super.initState();

    // Use passed colorTypes or default ones
    _colorTypes = widget.colorTypes;

    // Use passed initialColorType or determine from pickerColor
    _currentColorType = _colorTypes.firstWhere(
      (group) => group.any((c) => c.value == widget.pickerColor.value),
      orElse: () => _colorTypes[0],
    );

    // Determine initial shading
    for (var group in _colorTypes) {
      for (var color in group) {
        if (color.value == widget.pickerColor.value) {
          _currentShading = color;
          break;
        }
      }
    }
  }

  List<Map<Color, String>> _shadingTypes(List<Color> colors) {
    List<Map<Color, String>> result = [];

    for (Color colorType in colors) {
      if (colorType == Colors.grey) {
        result.addAll([
          50,
          100,
          200,
          300,
          350,
          400,
          500,
          600,
          700,
          800,
          850,
          900
        ].map((int shade) => {Colors.grey[shade]!: shade.toString()}).toList());
      } else if (colorType == Colors.black || colorType == Colors.white) {
        result.addAll([
          {Colors.black: ''},
          {Colors.white: ''}
        ]);
      } else if (colorType is MaterialAccentColor) {
        result.addAll([100, 200, 400, 700]
            .map((int shade) => {colorType[shade]!: 'A$shade'})
            .toList());
      } else if (colorType is MaterialColor) {
        result.addAll([50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
            .map((int shade) => {colorType[shade]!: shade.toString()})
            .toList());
      } else {
        // For custom colors not MaterialColor/MaterialAccentColor
        result.add({colorType: ''});
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait ||
            widget.portraitOnly;

    Widget _colorList() {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Container(
          margin: _isPortrait
              ? const EdgeInsets.only(right: 10)
              : const EdgeInsets.only(bottom: 10),
          width: _isPortrait ? 60 : null,
          height: _isPortrait ? null : 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: (Theme.of(context).brightness == Brightness.light)
                    ? Colors.grey[300]!
                    : Colors.black38,
                blurRadius: 10,
              )
            ],
            border: _isPortrait
                ? Border(
                    right: BorderSide(
                        color:
                            (Theme.of(context).brightness == Brightness.light)
                                ? Colors.grey[300]!
                                : Colors.black38,
                        width: 1))
                : Border(
                    top: BorderSide(
                        color:
                            (Theme.of(context).brightness == Brightness.light)
                                ? Colors.grey[300]!
                                : Colors.black38,
                        width: 1)),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
            child: ListView(
              scrollDirection: _isPortrait ? Axis.vertical : Axis.horizontal,
              children: [
                _isPortrait
                    ? const Padding(padding: EdgeInsets.only(top: 7))
                    : const Padding(padding: EdgeInsets.only(left: 7)),
                ..._colorTypes.map((List<Color> _colors) {
                  Color _colorType = _colors[0];
                  return GestureDetector(
                    onTap: () {
                      if (widget.onPrimaryChanged != null)
                        widget.onPrimaryChanged!(_colorType);
                      setState(() => _currentColorType = _colors);
                    },
                    child: Container(
                      color: const Color(0x00000000),
                      padding: _isPortrait
                          ? const EdgeInsets.fromLTRB(0, 7, 0, 7)
                          : const EdgeInsets.fromLTRB(7, 0, 7, 0),
                      child: Align(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: _colorType,
                            shape: BoxShape.circle,
                            boxShadow: _currentColorType == _colors
                                ? [
                                    _colorType == Theme.of(context).cardColor
                                        ? BoxShadow(
                                            color:
                                                (Theme.of(context).brightness ==
                                                        Brightness.light)
                                                    ? Colors.grey[300]!
                                                    : Colors.black38,
                                            blurRadius: 10,
                                          )
                                        : BoxShadow(
                                            color: _colorType,
                                            blurRadius: 10,
                                          ),
                                  ]
                                : null,
                            border: _colorType == Theme.of(context).cardColor
                                ? Border.all(
                                    color: (Theme.of(context).brightness ==
                                            Brightness.light)
                                        ? Colors.grey[300]!
                                        : Colors.black38,
                                    width: 1)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                _isPortrait
                    ? const Padding(padding: EdgeInsets.only(top: 5))
                    : const Padding(padding: EdgeInsets.only(left: 5)),
              ],
            ),
          ),
        ),
      );
    }

    Widget _shadingList() {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context)
            .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: ListView(
          scrollDirection: _isPortrait ? Axis.vertical : Axis.horizontal,
          children: [
            _isPortrait
                ? const Padding(padding: EdgeInsets.only(top: 15))
                : const Padding(padding: EdgeInsets.only(left: 15)),
            ..._shadingTypes(_currentColorType).map((Map<Color, String> color) {
              final Color _color = color.keys.first;
              return GestureDetector(
                onTap: () {
                  setState(() => _currentShading = _color);
                  widget.onColorChanged(_color);
                },
                child: Container(
                  color: const Color(0x00000000),
                  margin: _isPortrait
                      ? const EdgeInsets.only(right: 10)
                      : const EdgeInsets.only(bottom: 10),
                  padding: _isPortrait
                      ? const EdgeInsets.fromLTRB(0, 7, 0, 7)
                      : const EdgeInsets.fromLTRB(7, 0, 7, 0),
                  child: Align(
                    child: AnimatedContainer(
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(milliseconds: 500),
                      width: _isPortrait
                          ? (_currentShading == _color ? 250 : 230)
                          : (_currentShading == _color ? 50 : 30),
                      height: _isPortrait ? 50 : 220,
                      decoration: BoxDecoration(
                        color: _color,
                        boxShadow: _currentShading == _color
                            ? [
                                (_color == Colors.white) ||
                                        (_color == Colors.black)
                                    ? BoxShadow(
                                        color: (Theme.of(context).brightness ==
                                                Brightness.light)
                                            ? Colors.grey[300]!
                                            : Colors.black38,
                                        blurRadius: 10,
                                      )
                                    : BoxShadow(
                                        color: _color,
                                        blurRadius: 10,
                                      ),
                              ]
                            : null,
                        border:
                            (_color == Colors.white) || (_color == Colors.black)
                                ? Border.all(
                                    color: (Theme.of(context).brightness ==
                                            Brightness.light)
                                        ? Colors.grey[300]!
                                        : Colors.black38,
                                    width: 1)
                                : null,
                      ),
                      child: widget.enableLabel
                          ? _isPortrait
                              ? Row(
                                  children: [
                                    Text(
                                      '  ${color.values.first}',
                                      style: TextStyle(
                                          color: useWhiteForeground(_color)
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '#${(_color.value.toRadixString(16).padLeft(8, '0')).substring(2).toUpperCase()}  ',
                                          style: TextStyle(
                                            color: useWhiteForeground(_color)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: _currentShading == _color ? 1 : 0,
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 16),
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      color.values.first,
                                      style: TextStyle(
                                        color: useWhiteForeground(_color)
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      softWrap: false,
                                    ),
                                  ),
                                )
                          : const SizedBox(),
                    ),
                  ),
                ),
              );
            }),
            _isPortrait
                ? const Padding(padding: EdgeInsets.only(top: 15))
                : const Padding(padding: EdgeInsets.only(left: 15)),
          ],
        ),
      );
    }

    if (_isPortrait) {
      return SizedBox(
        width: 350,
        height: 500,
        child: Row(
          children: <Widget>[
            _colorList(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _shadingList(),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: 500,
        height: 300,
        child: Column(
          children: <Widget>[
            _colorList(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _shadingList(),
              ),
            ),
          ],
        ),
      );
    }
  }
}
