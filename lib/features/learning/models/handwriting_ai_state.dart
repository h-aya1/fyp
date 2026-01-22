import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/evaluation_result.dart';

abstract class HandwritingAIState {
  const HandwritingAIState();
}

class HandwritingAIInitial extends HandwritingAIState {
  const HandwritingAIInitial();
}

class HandwritingAILoading extends HandwritingAIState {
  const HandwritingAILoading();
}

class HandwritingAISuccess extends HandwritingAIState {
  final EvaluationResult result;
  const HandwritingAISuccess(this.result);
}

class HandwritingAIError extends HandwritingAIState {
  final String message;
  const HandwritingAIError(this.message);
}
