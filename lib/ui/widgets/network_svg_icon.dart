import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

/// Downloads SVG icons once and keeps them in memory.
abstract final class SvgIconLoader {
  static final Map<String, String> _loaded = {};
  static final Map<String, Future<String?>> _pending = {};

  /// SVG markup for [url] if it was already downloaded.
  static String? cached(String url) => _loaded[url];

  /// Downloads [url]; completes with null when the request fails or the
  /// response is not an SVG, so callers can show a fallback instead.
  static Future<String?> load(String url) {
    final cached = _loaded[url];
    if (cached != null) return Future.value(cached);
    return _pending.putIfAbsent(url, () async {
      try {
        final response = await http.get(Uri.parse(url));
        final body = response.body;
        if (response.statusCode == 200 && body.contains('<svg')) {
          _loaded[url] = body;
          return body;
        }
      } catch (_) {
        // Offline or invalid url: the fallback icon is shown.
      } finally {
        _pending.remove(url);
      }
      return null;
    });
  }
}

/// Icon loaded from an SVG url in the data. Falls back to a Material icon
/// when there is no url or the SVG cannot be downloaded (e.g. offline).
class NetworkSvgIcon extends StatefulWidget {
  const NetworkSvgIcon({
    super.key,
    required this.url,
    required this.fallback,
    this.size = 20,
    this.color,
    this.fallbackColor,
  });

  final String? url;
  final IconData fallback;
  final double size;

  /// Overrides the colour baked into the SVG.
  final Color? color;

  /// Colour of the fallback icon; defaults to [color].
  final Color? fallbackColor;

  @override
  State<NetworkSvgIcon> createState() => _NetworkSvgIconState();
}

class _NetworkSvgIconState extends State<NetworkSvgIcon> {
  Future<String?>? _svg;

  @override
  void initState() {
    super.initState();
    _svg = _request(widget.url);
  }

  @override
  void didUpdateWidget(NetworkSvgIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _svg = _request(widget.url);
  }

  static Future<String?>? _request(String? url) =>
      url == null || url.isEmpty ? null : SvgIconLoader.load(url);

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    final cached = url == null ? null : SvgIconLoader.cached(url);
    if (cached != null) return _svgPicture(cached);
    if (_svg == null) return _fallbackIcon();

    return FutureBuilder<String?>(
      future: _svg,
      builder: (context, snapshot) {
        final svg = snapshot.data;
        if (svg != null) return _svgPicture(svg);
        if (snapshot.connectionState == ConnectionState.done) {
          return _fallbackIcon();
        }
        return SizedBox.square(dimension: widget.size);
      },
    );
  }

  Widget _svgPicture(String svg) {
    final color = widget.color;
    return SvgPicture.string(
      svg,
      width: widget.size,
      height: widget.size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
      errorBuilder: (_, _, _) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() => Icon(
    widget.fallback,
    size: widget.size,
    color: widget.fallbackColor ?? widget.color,
  );
}
