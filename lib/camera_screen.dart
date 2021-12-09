import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> _cameras = [];
  CameraController _controller;
  int _cameraIndex;
  bool _isRecording = false;
  String myFilePath;

  @override
  void initState() {
    super.initState();
    // Verificar la lista de cámaras disponibles al iniciar el Widget
    availableCameras().then((cameras) {
      // Guardar la lista de cámaras
      _cameras = cameras;
      // Inicializar la cámara solo si la lista de cámaras tiene cámaras disponibles
      if (_cameras.length != 0) {
        // Inicializar el índice de cámara actual en 0 para obtener la primera
        _cameraIndex = 0;
        // Inicializar la cámara pasando el CameraDescription de la cámara seleccionada
        _initCamera(_cameras[_cameraIndex]);
      }
    });
  }

  _initCamera(CameraDescription pCam) async {
    // Si el controlador está en uso,
    // realizar un dispose para detenerlo antes de continuar
    if (_controller != null) await _controller.dispose();
    // Indicar al controlador la nueva cámara a utilizar
    _controller = CameraController(pCam, ResolutionPreset.medium);
    // Agregar un Listener para refrescar la pantalla en cada cambio
    _controller.addListener(() => this.setState(() {}));
    // Inicializar el controlador
    _controller.initialize();
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // Ícono para cambiar la cámara
        IconButton(
          icon: Icon(_getCameraIcon(_cameras[_cameraIndex].lensDirection)),
          onPressed: _onSwitchCamera,
        ),
        IconButton(
          icon: Icon(Icons.radio_button_checked),
          onPressed: _isRecording ? null : _onRecord,
        ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: _isRecording ? _onStop : null,
        ),
        // Ícono para reproducir el video grabado
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: _isRecording ? null : _onPlay,
        ),
      ],
    );
  }

  IconData _getCameraIcon(CameraLensDirection lensDirection) {
    return lensDirection == CameraLensDirection.back
        ? Icons.camera_front
        : Icons.camera_rear;
  }

  void _onSwitchCamera() {
    // Si la cantidad de cámaras es 1 o inferior,
    // no hacer el cambio
    if (_cameras.length < 2) return;
    // Cambiar 1 por 0 ó 0 por 1
    _cameraIndex = (_cameraIndex + 1) % 2;
    // Inicializar la cámara pasando el CameraDescription de la cámara seleccionada
    _initCamera(_cameras[_cameraIndex]);
  }

  Future<void> _onRecord() async {
    // Obtener la dirección temporal
    var directory = await getTemporaryDirectory();
    // Añadir el nombre del archivo a la dirección temporal
    myFilePath = directory.path + '/${DateTime.now()}.mp4';
    // Utilizar el controlador para iniciar la grabación
    _controller.startVideoRecording(myFilePath);
    // Actualizar la bandera de grabación
    setState(() => _isRecording = true);
  }

  Future<void> _onStop() async {
    await _controller.stopVideoRecording();
    setState(() => _isRecording = false);
  }

  void _onPlay() => OpenFile.open(myFilePath);

  Widget _buildCamera() {
    if (_controller == null || !_controller.value.isInitialized) {
      return Center(
        child: Text('load'),
      );
    }
    return CustomPaint(
      foregroundPainter: new GuidelinePainter(),
      child: new AspectRatio(
        // Solicitar la relación alto/ancho al controlador
        aspectRatio: _controller.value.aspectRatio,
        // Mostrar el contenido del controlador mediante el Widget CameraPreview
        child: CameraPreview(_controller),
      ),
      // child: new Column(
      //   children: [
      //     Center(
      //       child: AspectRatio(
      //           aspectRatio: _controller.value.aspectRatio,
      //     ),
      //   ],
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DrawVideo')),
      body: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height - 130,
              width: MediaQuery.of(context).size.width,
              child: _buildCamera()),
          _buildControls(),
        ],
      ),
    );
  }
}

class GuidelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 3.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    var path = new Path()..lineTo(250.0, 250.0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}




// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class CameraScreen extends StatefulWidget {
//   const CameraScreen({Key? key}) : super(key: key);

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late List<CameraDescription> _cameras = [];
//   late CameraController _controller;
//   late int _camareIndex;
//   bool _isRecording = false;
//   String filePath = "";

//   @override
//   void initState() {
//     super.initState();
//     availableCameras().then((cameras) {
//       _cameras = cameras;
//       if (_cameras.isNotEmpty) {
//         _camareIndex = 0;
//         _initCamera(_cameras[_camareIndex]);
//       }
//     });
//   }

//   _initCamera(CameraDescription pCam) async {
//     // if (_controller != null) {
//     //   await _controller.dispose();
//     // }
//     _controller = CameraController(pCam, ResolutionPreset.medium);
//     try {
//       await _controller.initialize();
//     } catch (e) {
//       print(e);
//     }
//   }

//   void _onSwitchCamera() {
//     if (_cameras.length < 2) return;
//     _camareIndex = ( _camareIndex + 1 % 2);
//     _initCamera(_cameras[_camareIndex]);
//   }

//   // _getCameraIcon(CameraLensDirection lensDirection) {
//   //   if (lensDirection == CameraLensDirection.back) {
//   //     return Icons.camera_front;
//   //   } else {
//   //     return Icons.camera_rear;
//   //   }
//   // }

//   Widget _buildControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: <Widget>[
//         // IconButton(
//         //   onPressed: _onSwitchCamera,
//         //   icon: Icon(_getCameraIcon(_cameras[_camareIndex].lensDirection)),
//         // ),
//         IconButton(
//           onPressed: _isRecording ? null : 
//           _onRecord,
//           icon: Icon(Icons.radio_button_checked),
//         ),
//         IconButton(
//           onPressed: _isRecording ? _onStop : null,
//           icon: Icon(Icons.stop),
//         ),
//       ],
//     );
//   }

//   Future<void> _onStop() async {
//     await _controller.stopVideoRecording();
//     setState(() => _isRecording = false);
//   }

//   Future<void> _onRecord() async {
//     var dir = await getTemporaryDirectory();
//     filePath = dir.path + '/${DateTime.now()}.mp4';
//     _controller.startVideoRecording();
//     setState(() => _isRecording = true);
//   }

//   Widget _buildCamera() {
//     // if (_controller == null || !_controller.value.isInitialized) {
//     //   return Center(
//     //     child: Text('load'),
//     //   );
//     // }
//     return AspectRatio(
//       aspectRatio: _controller.value.aspectRatio,
//       child: CameraPreview(_controller),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('DrawVideo')),
//       body: Column(
//         children: [
//           Container(height: 500, child: _buildCamera()),
//           _buildControls(),
//         ],
//       ),
//     );
//   }
// }
