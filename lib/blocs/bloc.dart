export '../app/bloc.dart';
export '../signup/bloc.dart';
export '../search/bloc.dart';

export 'simple_bloc_delegate.dart';

class BaseState {

  bool isBusy;
  bool showError;
  String errorMessage;

}
