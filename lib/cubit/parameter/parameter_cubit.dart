import 'package:appsms/models/app_parameter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'parameter_state.dart';

class ParameterCubit extends Cubit<ParameterState> {
  final _sensitiveInfoKey = "SENSITIVE_INFO_KEY";
  final _appreciationDisplayKey = "APPRECIATION_DISPLAY_KEY";
  final _appreciationKey = "APPRECIATION_KEY";
  final _appreciationDefaultValue =
      "ETS SABIL vous remercie pour votre confiance.";

  final _sensitiveDisplayDefaultValue = false;
  final _appreciationDisplayDefaultValue = true;

  ParameterCubit() : super(ParameterInitial());

  void loadAppParameter() async {
    final pref = await SharedPreferences.getInstance();

    final sensitiveDisplay =
        pref.getBool(_sensitiveInfoKey) ?? _sensitiveDisplayDefaultValue;
    final appreciationDisplay = pref.getBool(_appreciationDisplayKey) ??
        _appreciationDisplayDefaultValue;
    final appreciation =
        pref.getString(_appreciationKey) ?? _appreciationDefaultValue;

    emit(ParameterLoaded(AppParameter(
      appreciation: appreciation,
      isSensitiveInfoDisplayed: sensitiveDisplay,
      isAppreciationDisplayed: appreciationDisplay,
    )));
  }

  void setSensitiveInfoVisibility(bool displaySensitiveInfo) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setBool(_sensitiveInfoKey, displaySensitiveInfo);

    final currentState = state as ParameterLoaded;

    emit(ParameterLoaded(currentState.parameter.copyWith(
      isSensitiveInfoDisplayed: displaySensitiveInfo,
    )));
  }

  void setAppreciation(String appreciation) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setString(_appreciationKey, appreciation);

    final currentState = state as ParameterLoaded;

    emit(ParameterLoaded(
        currentState.parameter.copyWith(appreciation: appreciation)));
  }

  void setAppreciationDisplay(bool appreciationDisplay) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setBool(_appreciationDisplayKey, appreciationDisplay);

    final currentState = state as ParameterLoaded;

    emit(ParameterLoaded(currentState.parameter
        .copyWith(isAppreciationDisplayed: appreciationDisplay)));
  }
}
