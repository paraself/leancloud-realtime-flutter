import 'dart:typed_data';

class AVFile
{
  String url;
  String name;
  String filePath;
  Uint8List data;
  Map<String,dynamic> metaData;

  AVFile({
    this.url,
    this.name,
    this.filePath,
    this.data,
    this.metaData
  });

  static final String _thumbnailURL =  "?imageMogr2/thumbnail/";
  getThumbnailURLByScale(num scale){
    if(url==null){
      return null;
    }
    scale = scale*100;
    return url+_thumbnailURL+"!"+scale.toString()+"p";
  }
  getThumbnailURLBySize(num width,num height){
    if(url==null){
      return null;
    }
    return url+_thumbnailURL+width.toString()+"x"+height.toString()+"!";
  }
  decoding(Map<dynamic, dynamic> data){
    this.url = data['url'];
    this.name = data['name'];
    this.filePath = data['filePath'];
    this.data = data['data'];
    if(data['metaData']!=null){
       this.metaData = (data['metaData'] as Map<dynamic, dynamic>).map<String,dynamic>((a, b) => MapEntry(a as String, b));
    }
  }

  Map<String, dynamic> encoding(){
    var out = {
      "url":url,
      "name":name,
      "filePath":filePath,
      "data":data,
      "metaData":metaData,
    };
    out.removeWhere((k,v)=>v==null);
    return out;
  }
}