// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuranSearchResult {

 Ayah get ayah; String get surahName; String get matchedText;
/// Create a copy of QuranSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranSearchResultCopyWith<QuranSearchResult> get copyWith => _$QuranSearchResultCopyWithImpl<QuranSearchResult>(this as QuranSearchResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranSearchResult&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.matchedText, matchedText) || other.matchedText == matchedText));
}


@override
int get hashCode => Object.hash(runtimeType,ayah,surahName,matchedText);

@override
String toString() {
  return 'QuranSearchResult(ayah: $ayah, surahName: $surahName, matchedText: $matchedText)';
}


}

/// @nodoc
abstract mixin class $QuranSearchResultCopyWith<$Res>  {
  factory $QuranSearchResultCopyWith(QuranSearchResult value, $Res Function(QuranSearchResult) _then) = _$QuranSearchResultCopyWithImpl;
@useResult
$Res call({
 Ayah ayah, String surahName, String matchedText
});


$AyahCopyWith<$Res> get ayah;

}
/// @nodoc
class _$QuranSearchResultCopyWithImpl<$Res>
    implements $QuranSearchResultCopyWith<$Res> {
  _$QuranSearchResultCopyWithImpl(this._self, this._then);

  final QuranSearchResult _self;
  final $Res Function(QuranSearchResult) _then;

/// Create a copy of QuranSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ayah = null,Object? surahName = null,Object? matchedText = null,}) {
  return _then(_self.copyWith(
ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as Ayah,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,matchedText: null == matchedText ? _self.matchedText : matchedText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of QuranSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahCopyWith<$Res> get ayah {
  
  return $AyahCopyWith<$Res>(_self.ayah, (value) {
    return _then(_self.copyWith(ayah: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuranSearchResult].
extension QuranSearchResultPatterns on QuranSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _QuranSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _QuranSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Ayah ayah,  String surahName,  String matchedText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranSearchResult() when $default != null:
return $default(_that.ayah,_that.surahName,_that.matchedText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Ayah ayah,  String surahName,  String matchedText)  $default,) {final _that = this;
switch (_that) {
case _QuranSearchResult():
return $default(_that.ayah,_that.surahName,_that.matchedText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Ayah ayah,  String surahName,  String matchedText)?  $default,) {final _that = this;
switch (_that) {
case _QuranSearchResult() when $default != null:
return $default(_that.ayah,_that.surahName,_that.matchedText);case _:
  return null;

}
}

}

/// @nodoc


class _QuranSearchResult implements QuranSearchResult {
  const _QuranSearchResult({required this.ayah, required this.surahName, required this.matchedText});
  

@override final  Ayah ayah;
@override final  String surahName;
@override final  String matchedText;

/// Create a copy of QuranSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranSearchResultCopyWith<_QuranSearchResult> get copyWith => __$QuranSearchResultCopyWithImpl<_QuranSearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranSearchResult&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.surahName, surahName) || other.surahName == surahName)&&(identical(other.matchedText, matchedText) || other.matchedText == matchedText));
}


@override
int get hashCode => Object.hash(runtimeType,ayah,surahName,matchedText);

@override
String toString() {
  return 'QuranSearchResult(ayah: $ayah, surahName: $surahName, matchedText: $matchedText)';
}


}

/// @nodoc
abstract mixin class _$QuranSearchResultCopyWith<$Res> implements $QuranSearchResultCopyWith<$Res> {
  factory _$QuranSearchResultCopyWith(_QuranSearchResult value, $Res Function(_QuranSearchResult) _then) = __$QuranSearchResultCopyWithImpl;
@override @useResult
$Res call({
 Ayah ayah, String surahName, String matchedText
});


@override $AyahCopyWith<$Res> get ayah;

}
/// @nodoc
class __$QuranSearchResultCopyWithImpl<$Res>
    implements _$QuranSearchResultCopyWith<$Res> {
  __$QuranSearchResultCopyWithImpl(this._self, this._then);

  final _QuranSearchResult _self;
  final $Res Function(_QuranSearchResult) _then;

/// Create a copy of QuranSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ayah = null,Object? surahName = null,Object? matchedText = null,}) {
  return _then(_QuranSearchResult(
ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as Ayah,surahName: null == surahName ? _self.surahName : surahName // ignore: cast_nullable_to_non_nullable
as String,matchedText: null == matchedText ? _self.matchedText : matchedText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of QuranSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahCopyWith<$Res> get ayah {
  
  return $AyahCopyWith<$Res>(_self.ayah, (value) {
    return _then(_self.copyWith(ayah: value));
  });
}
}

// dart format on
