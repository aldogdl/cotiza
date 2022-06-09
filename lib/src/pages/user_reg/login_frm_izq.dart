import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import '../../entity/last_data_in.dart';
import '../../entity/user_admin.dart';
import '../../providers/check_login.dart';
import '../../repository/user_adm_repository.dart';

class LoginFrmIzq extends StatefulWidget {

  final BoxConstraints constraints;
  const LoginFrmIzq({
    required this.constraints,
    Key? key
  }) : super(key: key);

  @override
  State<LoginFrmIzq> createState() => _LoginFrmIzqState();
}

class _LoginFrmIzqState extends State<LoginFrmIzq> {

  final UserAdmRepository _userEm = UserAdmRepository();
  final GlobalKey<FormState> _frmKey = GlobalKey<FormState>();
  final TextEditingController _ctrUsername = TextEditingController();
  final TextEditingController _ctrPassword = TextEditingController();
  final ScrollController _ctrScroll = ScrollController();

  final globals = getSngOf<Globals>();
  final double tamRadius = 10;
  final ValueNotifier<String> _msg = ValueNotifier('Autenticate por favor.');
  late final CheckLoginProvider _prov;

  bool _isLoad = false;
  bool _isInit = false;
  bool _hiddePass = true;

  @override
  void initState() {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prov.initCheck(onlyOpen: true);
    });

    super.initState();
  }

  @override
  void dispose() {
    _ctrUsername.dispose();
    _ctrPassword.dispose();
    _ctrScroll.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _prov = context.read<CheckLoginProvider>();
    }

    return ListView(
      children: [
        Container(
          padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height * 0.09)),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xcc5FB131),
                Color(0xcc5FB131),
                Color(0xcc5FB131),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.45,
          width: widget.constraints.maxWidth,
          child: const Image(
            image: AssetImage('assets/images/logo.png'),
            alignment: Alignment.topCenter,
          )
        ),
        Center(
          child: ValueListenableBuilder<String>(
            valueListenable: _msg,
            builder: (_, String mss, __) {
              return Text(
                mss,
                textScaleFactor: 1,
                style: globals.styleText(13, Colors.white, false),
              );
            },
          ),
        ),
        (_isLoad)
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: LinearProgressIndicator(),
          )
        : const SizedBox(height: 10),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _frmKey,
            child: Column(
              children: _frm(),
            ),
          ),
        )
      ]
    );
  }

  ///
  List<Widget> _frm() {

    return [
      _inputUsername(),
      const SizedBox(height: 20),
      _inputPassword(),
      const SizedBox(height: 20),
      AbsorbPointer(
        absorbing: (_isLoad) ? true : false,
        child: _btnMakeLogin()
      ),
      const SizedBox(height: 40),
      Text(
        'Rastrea y encuentra la Autoparte que necesitas.',
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.withOpacity(0.5),
          fontSize: 25,
          fontWeight: FontWeight.w300
        ),
      )
    ];
  }

  ///
  Widget _inputUsername() {

    return TextFormField(
      controller: _ctrUsername,
      autocorrect: true,
      validator: (String? newVal) {
        if(newVal != null) {
          if(newVal.length < 4) {
            return 'Tu CURC no fué encontrado';  
          }
        }else{
          return 'El CURC es requerido';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        label: getLabel(label: '*CURC'),
        hintStyle: getStyHint(),
        border: _bordeFrmInput(),
        errorStyle: _getStyErrs(),
        enabledBorder: _bordeFrmInput(),
        prefixIcon: const Icon(Icons.account_circle_rounded, size: 20, color: Colors.blue),
      ),
    );
  }

  ///
  Widget _inputPassword() {

    return TextFormField(
      controller: _ctrPassword,
      autocorrect: true,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _hiddePass,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _makeLogin();
      },
      validator: (String? newVal) {
        if(newVal != null) {
          if(newVal.length < 4) {
            return 'La contraseña no es valida';  
          }
        }else{
          return 'La contraseña es requerida';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        label: getLabel(label: '*Contraseña'),
        hintStyle: getStyHint(),
        border: _bordeFrmInput(),
        enabledBorder: _bordeFrmInput(),
        errorStyle: _getStyErrs(),
        prefixIcon: const Icon(Icons.security, size: 20, color: Colors.blue),
        suffixIcon: ExcludeFocus(
          child: InkWell(
            canRequestFocus: false,
            onTap: () => setState((){ _hiddePass = !_hiddePass;}),
            mouseCursor: SystemMouseCursors.click,
            child: Icon(
              (_hiddePass) ? Icons.visibility : Icons.visibility_off,
              size: 20,
              color: Colors.blue
            ),
          ),
        )
      ),
    );
  }

  ///
  Widget _btnMakeLogin() {

    return Align(
      alignment: Alignment.center,
        child: OutlinedButton.icon(
        onPressed: () => _makeLogin(),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 30, vertical: 20)
          ),
          side: MaterialStateProperty.all(
            const BorderSide(
              color: Colors.blue,
              width: 1
            )
          )
        ),
        icon: const Icon(Icons.send_and_archive_sharp, size: 15),
        label: Text(
          'INGRESAR',
          textScaleFactor: 1,
          style: globals.styleText(16, Colors.white, true, sw: 1.1)
        )
      )
    );
  }

  ///
  OutlineInputBorder _bordeFrmInput() {

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(tamRadius),
      borderSide: const BorderSide(
        color: Colors.blue,
        width: 1
      )
    );
  }

  ///
  TextStyle _getStyErrs() {
    return TextStyle(
      color: Colors.orange[400]
    );
  }

  ///
  TextStyle getStyHint() {
    return TextStyle(
      color: Colors.green[100]
    );
  }

  ///
  Widget getLabel({required String label}) {

    return Text(
      label,
      textScaleFactor: 1,
      style: const TextStyle(
        color: Colors.grey
      ),
    );
  }

  ///
  Future<void> _makeLogin() async {

    if(_frmKey.currentState!.validate()) {

      setState(() { _isLoad = true; });
      _msg.value = 'Revisando Datos';
      await _userEm.checkLogin({
        'username': _ctrUsername.text.toLowerCase(),
        'password': _ctrPassword.text.toLowerCase()
      });
      if(!_userEm.result['abort']) {
        await _recoveryDataUser(_userEm.result['body']);
      }else{
        setState(() { _isLoad = false; });
        _msg.value = _userEm.result['body'];
      }
    }

  }

  ///
  Future<void> _recoveryDataUser(String token) async {
    
    _msg.value = 'Recuperando DATOS';
    await _userEm.getUsersByCampo(
      campo: 'curc', valor: _ctrUsername.text.toLowerCase(),
      tokenServer: token
    );
    if(!_userEm.result['abort']) {
      await _saveDataUser(Map<String, dynamic>.from(_userEm.result['body']), token);
    }else{
      setState(() { _isLoad = false; });
      _msg.value = _userEm.result['body'];
    }
  }

  ///
  Future<void> _saveDataUser(Map<String, dynamic> dataUser, String token) async {

    _msg.value = 'Guardando DATOS';
    final userObj = _prov.user;
    
    final user = UserAdmin(
      id: dataUser['u_id'],
      username: _ctrUsername.text.toLowerCase(),
      password: _ctrPassword.text.toLowerCase(),
      role: dataUser['u_roles'][0],
      tkServer: token
    );
    Iterable<UserAdmin> usHas = userObj.values.where((user) => user.id == dataUser['u_id']);
    if(usHas.isEmpty) {
      if(userObj.isNotEmpty) {
        userObj.clear();
      }
      final future = userObj.add(user);
      await future;
    }else{
      usHas.first.tkServer = token;
      usHas.first.save();
    }
    globals.idUser = user.id;
    await _prov.openBoxLastDataIn();
    if(_prov.lastDataIn != null) {

      if(_prov.lastDataIn!.values.isNotEmpty) {
        _prov.lastDataIn!.values.first.fecha = DateTime.now().toIso8601String();
        _prov.lastDataIn!.values.first.save();
      }else{
        final lastData = LastDataIn(fecha: DateTime.now().toIso8601String());
        _prov.lastDataIn!.add(lastData);
      }
    }
    _msg.value = 'Bienvendio ${_ctrUsername.text.toUpperCase()}';
    _prov.setIsUserAutenticado(IsLoged.isAutorized);
  }

}