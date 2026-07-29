// الأخطاء بصيغتها اللي تعبر للواجهة. union بـfreezed لا صنف واحد بحقل نوع، حتى
// الشاشة تجبر على تغطية كل حالة بـwhen ولا تنسى واحدة.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// خطأ متوقَّع مع [message] عربية جاهزة للعرض — ما نمرّر نص استثناء إنجليزي للمستخدم.
@freezed
abstract class Failure with _$Failure {
  const factory Failure.server({required String message}) = ServerFailure;
  const factory Failure.cache({required String message}) = CacheFailure;
  const factory Failure.network({required String message}) = NetworkFailure;
  const factory Failure.notFound({required String message}) = NotFoundFailure;
  const factory Failure.permission({required String message}) =
      PermissionFailure;
  const factory Failure.unknown({required String message}) = UnknownFailure;
}
