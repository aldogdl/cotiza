import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/boxes_names.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';

import '../../entity/user_admin.dart';
import '../../repository/user_adm_repository.dart';

class GetTokenServer extends StatefulWidget {

  final ValueChanged<void> onSaveToken;
  const GetTokenServer({
    required this.onSaveToken,
    Key? key
  }) : super(key: key);

  @override
  State<GetTokenServer> createState() => _GetTokenServerState();
}

class _GetTokenServerState extends State<GetTokenServer> {

  final UserAdmRepository _userEm = UserAdmRepository();
  final globals = getSngOf<Globals>();

  final GlobalKey<FormState> _frmKey = GlobalKey<FormState>();
  final TextEditingController _ctrPassword = TextEditingController();
  late Box<UserAdmin> userB;
  late String _msg;
  late bool _isLoad;
  late bool _hiddePass;
  String username = '';

  @override
  void initState() {
    _isLoad = false;
    _hiddePass = true;
    _msg = 'Para restaurarlas indica tu contraseña y presiona "REFRESCAR"';
    userB = Hive.box(BoxesNames.userAdminBox);
    username = userB.getAt(0)!.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'HOLA ${username.toUpperCase()}',
            textAlign: TextAlign.center,
            textScaleFactor: 1,
            style: globals.styleText(20, Colors.black, true)
          ),
          const SizedBox(height: 10),
          Text(
            'Tus Llaves han Caducado',
            textAlign: TextAlign.center,
            textScaleFactor: 1,
            style: globals.styleText(18, Colors.red, false)
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              _msg,
              textAlign: TextAlign.center,
              textScaleFactor: 1,
              style: globals.styleText(16, Colors.grey, false)
            ),
          ),
          const SizedBox(height: 10),
          if(_isLoad)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: LinearProgressIndicator(),
            ),
          Form(
            key: _frmKey,
            child: TextFormField(
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
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                label: const Text(
                  '*Contraseña',
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Colors.black
                  ),
                ),
                border: _bordeFrmInput(),
                enabledBorder: _bordeFrmInput(),
                errorStyle: TextStyle(
                  color: Colors.orange[400]
                ),
                prefixIcon: const Icon(Icons.security, size: 20, color: Colors.blue),
                suffixIcon: InkWell(
                  onTap: () => setState((){ _hiddePass = !_hiddePass;}),
                  mouseCursor: SystemMouseCursors.click,
                  child: Icon(
                    (_hiddePass) ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: Colors.blue
                  ),
                )
              ),
            ),
          ),
          const SizedBox(height: 10),
          AbsorbPointer(
            absorbing: (_isLoad) ? true : false,
            child: OutlinedButton.icon(
              onPressed: () => _makeLogin(),
              icon: const Icon(Icons.send_and_archive),
              label: const Text(
                'REFRESCAR',
                textScaleFactor: 1,
              )
            ),
          )
        ],
      ),
    );
  }

  ///
  OutlineInputBorder _bordeFrmInput() {

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Colors.blue,
        width: 1
      )
    );
  }

  ///
  Future<void> _makeLogin() async {

    if(_frmKey.currentState!.validate()) {

      setState(() { _isLoad = true; });
      _msg = 'Revisando Datos';

      await _userEm.checkLogin({
        'username': username,
        'password': _ctrPassword.text.toLowerCase()
      });
      
      if(!_userEm.result['abort']) {
        UserAdmin? us = userB.getAt(0);
        if(us != null) {
          us.tkServer = _userEm.result['body'];
          await us.save();
          widget.onSaveToken(null);
        }else{
          widget.onSaveToken(null);
        }
      }else{
        setState(() { _isLoad = false; });
        _msg = _userEm.result['body'];
      }
    }

  }
}