import 'package:appsms/models/app_parameter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'parameter_state.dart';

class ParameterCubit extends Cubit<ParameterState> {
  final sensitiveInfoKey = "SENSITIVE_INFO_KEY";
  final appreciationKey = "APPRECIATION_KEY";
  final appreciationDefaultValue =
      "ETS SABIL vous remercie pour votre confiance";
  final sensitiveDisplayDefaultValue = false;

  final _parameterBehaviorSubject = BehaviorSubject<AppParameter>();

  ParameterCubit() : super(ParameterInitial());

  void loadAppParameter() async {
    final pref = await SharedPreferences.getInstance();

    final sensitiveDisplay =
        pref.getBool(sensitiveInfoKey) ?? sensitiveDisplayDefaultValue;
    final appreciation =
        pref.getString(sensitiveInfoKey) ?? appreciationDefaultValue;

    _notifyStateChange(AppParameter(
      appreciation: appreciation,
      isSensitiveInfoDisplayed: sensitiveDisplay,
    ));
  }

  void setSensitiveInfoVisibility(bool displaySensitiveInfo) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setBool(sensitiveInfoKey, displaySensitiveInfo);

    final currentState = state as ParameterLoaded;

    _notifyStateChange(
      currentState.appParameter.copyWith(
        isSensitiveInfoDisplayed: displaySensitiveInfo,
      ),
    );
  }

  void setAppreciation(String appreciation) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setString(appreciationKey, appreciation);

    final currentState = state as ParameterLoaded;

    _notifyStateChange(
      currentState.appParameter.copyWith(appreciation: appreciation),
    );
  }

  void _notifyStateChange(AppParameter parameter) {
    _parameterBehaviorSubject.add(parameter);
    emit(ParameterLoaded(parameter));
  }

  Stream<AppParameter> watch() => _parameterBehaviorSubject.stream;

  @override
  Future<void> close() async {
    _parameterBehaviorSubject.close();
    await super.close();
  }
}
