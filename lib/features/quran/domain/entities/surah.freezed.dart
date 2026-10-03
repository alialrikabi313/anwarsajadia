// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'surah.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Surah {

 int get id; String get nameArabic; int get ayahCount;// 'meccan' أو 'medinan' — نص لا enum لأنه يوصل هكذا من ملف الأصول.
 String get revelationType; int get orderInMushaf; String? get audioUrl;
/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurahCopyWith<Surah> get copyWith => _$SurahCopyWithImpl<Surah>(this as Surah, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Surah&&(identical(other.id, id) || other.id == id)&&(identical(other.nameArabic, nameArabic) || other.nameArabic == nameArabic)&&(identical(other.ayahCount, ayahCount) || other.ayahCount == ayahCount)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.orderInMushaf, orderInMushaf) || other.orderInMushaf == orderInMushaf)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,nameArabic,ayahCount,revelationType,orderInMushaf,audioUrl);

@override
String toString() {
  return 'Surah(id: $id, nameArabic: $nameArabic, ayahCount: $ayahCount, revelationType: $revelationType, orderInMushaf: $orderInMushaf, audioUrl: $audioUrl)';
}


}

/// @nodoc
abstract mixin class $SurahCopyWith<$Res>  {
  factory $SurahCopyWith(Surah value, $Res Function(Surah) _then) = _$SurahCopyWithImpl;
@useResult
$Res call({
 int id, String nameArabic, int ayahCount, String revelationType, int orderInMushaf, String? audioUrl
});




}
/// @nodoc
class _$SurahCopyWithImpl<$Res>
    implements $SurahCopyWith<$Res> {
  _$SurahCopyWithImpl(this._self, this._then);

  final Surah _self;
  final $Res Function(Surah) _then;

/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameArabic = null,Object? ayahCount = null,Object? revelationType = null,Object? orderInMushaf = null,Object? audioUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameArabic: null == nameArabic ? _self.nameArabic : nameArabic // ignore: cast_nullable_to_non_nullable
as String,ayahCount: null == ayahCount ? _self.ayahCount : ayahCount // ignore: cast_nullable_to_non_nullable
as int,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,orderInMushaf: null == orderInMushaf ? _self.orderInMushaf : orderInMushaf // ignore: cast_nullable_to_non_nullable
as int,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Surah].
extension SurahPatterns on Surah {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Surah value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Surah() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Surah value)  $default,){
final _that = this;
switch (_that) {
case _Surah():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Surah value)?  $default,){
final _that = this;
switch (_that) {
case _Surah() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String nameArabic,  int ayahCount,  String revelationType,  int orderInMushaf,  String? audioUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Surah() when $default != null:
return $default(_that.id,_that.nameArabic,_that.ayahCount,_that.revelationType,_that.orderInMushaf,_that.audioUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String nameArabic,  int ayahCount,  String revelationType,  int orderInMushaf,  String? audioUrl)  $default,) {final _that = this;
switch (_that) {
case _Surah():
return $default(_that.id,_that.nameArabic,_that.ayahCount,_that.revelationType,_that.orderInMushaf,_that.audioUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String nameArabic,  int ayahCount,  String revelationType,  int orderInMushaf,  String? audioUrl)?  $default,) {final _that = this;
switch (_that) {
case _Surah() when $default != null:
return $default(_that.id,_that.nameArabic,_that.ayahCount,_that.revelationType,_that.orderInMushaf,_that.audioUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Surah implements Surah {
  const _Surah({required this.id, required this.nameArabic, required this.ayahCount, required this.revelationType, required this.orderInMushaf, this.audioUrl});
  

@override final  int id;
@override final  String nameArabic;
@override final  int ayahCount;
// 'meccan' أو 'medinan' — نص لا enum لأنه يوصل هكذا من ملف الأصول.
@override final  String revelationType;
@override final  int orderInMushaf;
@override final  String? audioUrl;

/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurahCopyWith<_Surah> get copyWith => __$SurahCopyWithImpl<_Surah>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Surah&&(identical(other.id, id) || other.id == id)&&(identical(other.nameArabic, nameArabic) || other.nameArabic == nameArabic)&&(identical(other.ayahCount, ayahCount) || other.ayahCount == ayahCount)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.orderInMushaf, orderInMushaf) || other.orderInMushaf == orderInMushaf)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,nameArabic,ayahCount,revelationType,orderInMushaf,audioUrl);

@override
String toString() {
  return 'Surah(id: $id, nameArabic: $nameArabic, ayahCount: $ayahCount, revelationType: $revelationType, orderInMushaf: $orderInMushaf, audioUrl: $audioUrl)';
}


}

/// @nodoc
abstract mixin class _$SurahCopyWith<$Res> implements $SurahCopyWith<$Res> {
  factory _$SurahCopyWith(_Surah value, $Res Function(_Surah) _then) = __$SurahCopyWithImpl;
@override @useResult
$Res call({
 int id, String nameArabic, int ayahCount, String revelationType, int orderInMushaf, String? audioUrl
});




}
/// @nodoc
class __$SurahCopyWithImpl<$Res>
    implements _$SurahCopyWith<$Res> {
  __$SurahCopyWithImpl(this._self, this._then);

  final _Surah _self;
  final $Res Function(_Surah) _then;

/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameArabic = null,Object? ayahCount = null,Object? revelationType = null,Object? orderInMushaf = null,Object? audioUrl = freezed,}) {
  return _then(_Surah(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameArabic: null == nameArabic ? _self.nameArabic : nameArabic // ignore: cast_nullable_to_non_nullable
as String,ayahCount: null == ayahCount ? _self.ayahCount : ayahCount // ignore: cast_nullable_to_non_nullable
as int,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,orderInMushaf: null == orderInMushaf ? _self.orderInMushaf : orderInMushaf // ignore: cast_nullable_to_non_nullable
as int,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
