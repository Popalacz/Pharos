import 'package:flutter/material.dart';
import 'package:pharos/core/error/failures.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';

class PharosAsyncSection<T> extends StatelessWidget {
  final bool isLoading;
  final Failure? failure;
  final T? data;
  final bool Function(T data)? isEmptyUserContent;
  final VoidCallback? onRetry;
  final Widget Function(T data) successBuilder;
  final Widget Function()? emptyBuilder;
  final Widget? loadingWidget;

  const PharosAsyncSection({
    super.key,
    required this.isLoading,
    required this.failure,
    required this.data,
    required this.successBuilder,
    this.isEmptyUserContent,
    this.onRetry,
    this.emptyBuilder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const SizedBox.shrink();
    }

    if (failure != null) {
      return NetworkErrorState(message: failure!.message, onRetry: onRetry ?? () {});
    }

    if (data == null) {
      return const SizedBox.shrink();
    }

    if (isEmptyUserContent != null && isEmptyUserContent!(data as T)) {
      return emptyBuilder?.call() ?? const SizedBox.shrink();
    }

    return successBuilder(data as T);
  }
}
