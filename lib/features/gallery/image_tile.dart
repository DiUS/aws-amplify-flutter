
import 'package:amplify/data/models/FileInfo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final FileInfo fileInfo;
  final Function onTap;

  ImageTile({this.fileInfo, this.onTap});

  Widget _buildPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
          child: Hero(
            tag: fileInfo.key,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: fileInfo.isReady
                    ? CachedNetworkImage(
                        imageUrl: fileInfo.url,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) => Icon(Icons.error)
                    )
                    : _buildPlaceholder()
              ),
            ),
          ),
          onTap: () => onTap?.call()),
    );
  }
}
