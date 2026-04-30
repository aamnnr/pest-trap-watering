abstract class ControlState {
  const ControlState();
}

class ControlInitial extends ControlState {}

class ControlLoading extends ControlState {}

class ControlSuccess extends ControlState {
  final String message;

  const ControlSuccess(this.message);
}

class ControlError extends ControlState {
  final String message;

  const ControlError(this.message);
}
