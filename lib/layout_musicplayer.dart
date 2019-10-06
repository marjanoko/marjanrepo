import 'globalvar.dart';
import 'package:http/http.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

typedef void OnError(Exception exception);

class AudioScreen extends StatefulWidget {
  @override
  _AudioScreenState createState() => new _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  AudioPlayer audioPlayer;
  AudioPlayerState audioPlayerState;
  

  @override 
  void initState(){
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayerState = null;
  }

  Future loadAsset() async{
    return await rootBundle.load('assets/audio.mp3');
  }

  Future<void> play() async{
    if(urlSelectedFile!=""){
      String localUrl = await loadSelected(urlSelectedFile);
      print(localUrl);
      audioPlayer.play(localUrl, isLocal: true);
      setState(() {
      audioPlayerState = AudioPlayerState.PLAYING;
      if(audioPlayer.state == AudioPlayerState.COMPLETED){
        audioPlayerState = AudioPlayerState.COMPLETED;
      } 
      });
    }else{
      final file = new File('${(await getTemporaryDirectory()).path}/audio.mp3');
      await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
      await audioPlayer.play(file.path,isLocal: true);
      setState(() {
      audioPlayerState = AudioPlayerState.PLAYING;
      if(audioPlayer.state == AudioPlayerState.COMPLETED){
        audioPlayerState = AudioPlayerState.COMPLETED;
      } 
      });
    }
  }  

  Future<Uint8List> _bacaFileByte(String filePath) async {
      Uri myUri = Uri.parse(filePath);
      File audioFile = new File.fromUri(myUri);
      Uint8List bytes;
      await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value); 
      print('reading of bytes is completed');
    }).catchError((onError) {
        print('Exception Error while reading audio from path:' +
        onError.toString());
    });
    return bytes;
  }
  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await _bacaFileByte(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future<String> loadSelected(String url) async {
    final bytes = await _loadFileBytes(url,
        onError: (Exception exception) =>
            print('audio_provider.load => exception ${exception}'));

    final dir = await getApplicationDocumentsDirectory();
    final file = new File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      return file.path;
    }
    return '';
  }
  Future<void> playSelectedSong(String url) async{

    String localUrl = await loadSelected(url);
    print(localUrl);
    audioPlayer.play(localUrl, isLocal: true);
    setState(() {
     audioPlayerState = AudioPlayerState.PLAYING;
     if(audioPlayer.state == AudioPlayerState.COMPLETED){
       audioPlayerState = AudioPlayerState.COMPLETED;
     } 
    });
  }

  Future<void> pause() async{
    await audioPlayer.pause();
    setState(() {
     audioPlayerState = AudioPlayerState.PAUSED; 
    });
  }
  Future<void> stop() async{
    await audioPlayer.stop();
    setState(() {
     audioPlayerState = AudioPlayerState.STOPPED; 
    });
  }

  String _extension="mp3";
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType=FileType.AUDIO;
  String _path;
  Map<String, String> _paths;
  String _fileName;
  String urlSelectedFile="";
  void _openFileExplorer() async {
    print(_pickingType);
    print(_extension);
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
        }
      }  catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null? _path.split('/').last: _paths != null ? _paths.keys.toString() : '...';
        setState(() => urlSelectedFile = _path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      //key: _formKey,
      appBar: new AppBar(
          title: Text("Music Player"),
          backgroundColor: Colors.green[HeaderMenuColor],// lebih satur
      ),
      backgroundColor: Colors.green[BackgroundColor],// lebih terangan dikit

      body: Container(
          padding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Builder(
              builder: (context) => Form(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: RaisedButton(
                                      color: Theme.of(context).primaryColorDark,
                                      textColor: Theme.of(context).primaryColorLight,
                                      child: Text('Play',textScaleFactor: 1.5),
                                      onPressed: audioPlayerState == null || 
                                        audioPlayerState == AudioPlayerState.PAUSED || 
                                        audioPlayerState == AudioPlayerState.STOPPED || 
                                        audioPlayerState == AudioPlayerState.COMPLETED ? play:null, 
                                  )
                              ),
                              Container(width: 5.0),//spasi antar tombol
                              Expanded(
                                  child: RaisedButton(
                                      color: Theme.of(context).primaryColorDark,
                                      textColor: Theme.of(context).primaryColorLight,
                                      child: Text('Pause',textScaleFactor: 1.5),
                                      onPressed: audioPlayerState == AudioPlayerState.PLAYING ? pause:null
                                  )
                              ),
                              Container(width: 5.0),//spasi antar tombol
                              Expanded(
                                  child: RaisedButton(
                                      color: Theme.of(context).primaryColorDark,
                                      textColor: Theme.of(context).primaryColorLight,
                                      child: Text('Stop',textScaleFactor: 1.5),
                                      onPressed: audioPlayerState == AudioPlayerState.PLAYING ? stop:null
                                  )
                              ),
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                          child: new RaisedButton(
                            onPressed: () => _openFileExplorer(),
                            child: new Text("Choose a File"),
                          ),
                        ),
                        new Builder(
                          builder: (BuildContext context) => _loadingPath
                              ? Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: const CircularProgressIndicator())
                              : _path != null || _paths != null
                              ? new Container(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: new Scrollbar(
                                child: new ListView.separated(
                                  itemCount: _paths != null && _paths.isNotEmpty? _paths.length: 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    final bool isMultiPath = _paths != null && _paths.isNotEmpty;
                                    final String name = 'File $index: ' +
                                        (isMultiPath ? _paths.keys.toList()[index] : _fileName ?? '...');
                                    final path = isMultiPath? _paths.values.toList()[index].toString(): _path;
                                    return new ListTile(
                                      title: new Text(
                                        name,
                                      ),
                                      subtitle: new Text(path),
                                    );
                                  },
                                  separatorBuilder:(BuildContext context, int index) => new Divider(),
                                )),
                          )
                              : new Container(),
                        ),
                      ]
                  )
              )
          )
      ),
    );
  }
}