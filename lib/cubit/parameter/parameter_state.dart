part of 'parameter_cubit.dart';

sealed class ParameterState extends Equatable {
  const ParameterState();

  @override
  List<Object> get props => [];
}

final class ParameterInitial extends ParameterState {}

final class ParameterLoaded extends ParameterState {
  final AppParameter appParameter;

  const ParameterLoaded(this.appParameter);

  @override
  List<Object> get props => [appParameter];
}
