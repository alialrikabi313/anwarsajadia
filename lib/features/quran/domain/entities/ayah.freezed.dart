// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Ayah {

 int get id; int get surahId; int get numberInSurah; String get textArabic; String? get audioUrl; int get juzNumber; int get pageNumber;
/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahCopyWith<Ayah> get copyWith => _$AyahCopyWithImpl<Ayah>(this as Ayah, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ayah&&(identical(other.id, id) || other.id == id)&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.numberInSurah, numberInSurah) || other.numberInSurah == numberInSurah)&&(identical(other.textArabic, textArabic) || other.textArabic == textArabic)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.juzNumber, juzNumber) || other.juzNumber == juzNumber)&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber));
}


@override
int get hashCode => Object.hash(runtimeType,id,surahId,numberInSurah,textArabic,audioUrl,juzNumber,pageNumber);

@override
String toString() {
  return 'Ayah(id: $id, surahId: $surahId, numberInSurah: $numberInSurah, textArabic: $textArabic, audioUrl: $audioUrl, juzNumber: $juzNumber, pageNumber: $pageNumber)';
}


}

/// @nodoc
abstract mixin class $AyahCopyWith<$Res>  {
  factory $AyahCopyWith(Ayah value, $Res Function(Ayah) _then) = _$AyahCopyWithImpl;
@useResult
$Res call({
 int id, int surahId, int numberInSurah, String textArabic, String? audioUrl, int juzNumber, int pageNumber
});




}
/// @nodoc
class _$AyahCopyWithImpl<$Res>
    implements $AyahCopyWith<$Res> {
  _$AyahCopyWithImpl(this._self, this._then);

  final Ayah _self;
  final $Res Function(Ayah) _then;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? surahId = null,Object? numberInSurah = null,Object? textArabic = null,Object? audioUrl = freezed,Object? juzNumber = null,Object? pageNumber = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,numberInSurah: null == numberInSurah ? _self.numberInSurah : numberInSurah // ignore: cast_nullable_to_non_nullable
as int,textArabic: null == textArabic ? _self.textArabic : textArabic // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,juzNumber: null == juzNumber ? _self.juzNumber : juzNumber // ignore: cast_nullable_to_non_nullable
as int,pageNumber: null == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Ayah].
extension AyahPatterns on Ayah {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ayah value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ayah() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ayah value)  $default,){
final _that = this;
switch (_that) {
case _Ayah():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ayah value)?  $default,){
final _that = this;
switch (_that) {
case _Ayah() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int surahId,  int numberInSurah,  String textArabic,  String? audioUrl,  int juzNumber,  int pageNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ayah() when $default != null:
return $default(_that.id,_that.surahId,_that.numberInSurah,_that.textArabic,_that.audioUrl,_that.juzNumber,_that.pageNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int surahId,  int numberInSurah,  String textArabic,  String? audioUrl,  int juzNumber,  int pageNumber)  $default,) {final _that = this;
switch (_that) {
case _Ayah():
return $default(_that.id,_that.surahId,_that.numberInSurah,_that.textArabic,_that.audioUrl,_that.juzNumber,_that.pageNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int surahId,  int numberInSurah,  String textArabic,  String? audioUrl,  int juzNumber,  int pageNumber)?  $default,) {final _that = this;
switch (_that) {
case _Ayah() when $default != null:
return $default(_that.id,_that.surahId,_that.numberInSurah,_that.textArabic,_that.audioUrl,_that.juzNumber,_that.pageNumber);case _:
  return null;

}
}

}

/// @nodoc


class _Ayah implements Ayah {
  const _Ayah({required this.id, required this.surahId, required this.numberInSurah, required this.textArabic, this.audioUrl, required this.juzNumber, required this.pageNumber});
  

@override final  int id;
@override final  int surahId;
@override final  int numberInSurah;
@override final  String textArabic;
@override final  String? audioUrl;
@override final  int juzNumber;
@override final  int pageNumber;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahCopyWith<_Ayah> get copyWith => __$AyahCopyWithImpl<_Ayah>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ayah&&(identical(other.id, id) || other.id == id)&&(identical(other.surahId, surahId) || other.surahId == surahId)&&(identical(other.numberInSurah, numberInSurah) || other.numberInSurah == numberInSurah)&&(identical(other.textArabic, textArabic) || other.textArabic == textArabic)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.juzNumber, juzNumber) || other.juzNumber == juzNumber)&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber));
}


@override
int get hashCode => Object.hash(runtimeType,id,surahId,numberInSurah,textArabic,audioUrl,juzNumber,pageNumber);

@override
String toString() {
  return 'Ayah(id: $id, surahId: $surahId, numberInSurah: $numberInSurah, textArabic: $textArabic, audioUrl: $audioUrl, juzNumber: $juzNumber, pageNumber: $pageNumber)';
}


}

/// @nodoc
abstract mixin class _$AyahCopyWith<$Res> implements $AyahCopyWith<$Res> {
  factory _$AyahCopyWith(_Ayah value, $Res Function(_Ayah) _then) = __$AyahCopyWithImpl;
@override @useResult
$Res call({
 int id, int surahId, int numberInSurah, String textArabic, String? audioUrl, int juzNumber, int pageNumber
});




}
/// @nodoc
class __$AyahCopyWithImpl<$Res>
    implements _$AyahCopyWith<$Res> {
  __$AyahCopyWithImpl(this._self, this._then);

  final _Ayah _self;
  final $Res Function(_Ayah) _then;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? surahId = null,Object? numberInSurah = null,Object? textArabic = null,Object? audioUrl = freezed,Object? juzNumber = null,Object? pageNumber = null,}) {
  return _then(_Ayah(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,surahId: null == surahId ? _self.surahId : surahId // ignore: cast_nullable_to_non_nullable
as int,numberInSurah: null == numberInSurah ? _self.numberInSurah : numberInSurah // ignore: cast_nullable_to_non_nullable
as int,textArabic: null == textArabic ? _self.textArabic : textArabic // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,juzNumber: null == juzNumber ? _self.juzNumber : juzNumber // ignore: cast_nullable_to_non_nullable
as int,pageNumber: null == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
