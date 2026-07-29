// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ziyara.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Ziyara {

 int get id; String get title; String get content; String get occasion; String? get audioUrl;
/// Create a copy of Ziyara
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZiyaraCopyWith<Ziyara> get copyWith => _$ZiyaraCopyWithImpl<Ziyara>(this as Ziyara, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ziyara&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,content,occasion,audioUrl);

@override
String toString() {
  return 'Ziyara(id: $id, title: $title, content: $content, occasion: $occasion, audioUrl: $audioUrl)';
}


}

/// @nodoc
abstract mixin class $ZiyaraCopyWith<$Res>  {
  factory $ZiyaraCopyWith(Ziyara value, $Res Function(Ziyara) _then) = _$ZiyaraCopyWithImpl;
@useResult
$Res call({
 int id, String title, String content, String occasion, String? audioUrl
});




}
/// @nodoc
class _$ZiyaraCopyWithImpl<$Res>
    implements $ZiyaraCopyWith<$Res> {
  _$ZiyaraCopyWithImpl(this._self, this._then);

  final Ziyara _self;
  final $Res Function(Ziyara) _then;

/// Create a copy of Ziyara
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? content = null,Object? occasion = null,Object? audioUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,occasion: null == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Ziyara].
extension ZiyaraPatterns on Ziyara {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ziyara value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ziyara() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ziyara value)  $default,){
final _that = this;
switch (_that) {
case _Ziyara():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ziyara value)?  $default,){
final _that = this;
switch (_that) {
case _Ziyara() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String content,  String occasion,  String? audioUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ziyara() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.occasion,_that.audioUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String content,  String occasion,  String? audioUrl)  $default,) {final _that = this;
switch (_that) {
case _Ziyara():
return $default(_that.id,_that.title,_that.content,_that.occasion,_that.audioUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String content,  String occasion,  String? audioUrl)?  $default,) {final _that = this;
switch (_that) {
case _Ziyara() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.occasion,_that.audioUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Ziyara implements Ziyara {
  const _Ziyara({required this.id, required this.title, required this.content, required this.occasion, this.audioUrl});
  

@override final  int id;
@override final  String title;
@override final  String content;
@override final  String occasion;
@override final  String? audioUrl;

/// Create a copy of Ziyara
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ZiyaraCopyWith<_Ziyara> get copyWith => __$ZiyaraCopyWithImpl<_Ziyara>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ziyara&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.occasion, occasion) || other.occasion == occasion)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,content,occasion,audioUrl);

@override
String toString() {
  return 'Ziyara(id: $id, title: $title, content: $content, occasion: $occasion, audioUrl: $audioUrl)';
}


}

/// @nodoc
abstract mixin class _$ZiyaraCopyWith<$Res> implements $ZiyaraCopyWith<$Res> {
  factory _$ZiyaraCopyWith(_Ziyara value, $Res Function(_Ziyara) _then) = __$ZiyaraCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String content, String occasion, String? audioUrl
});




}
/// @nodoc
class __$ZiyaraCopyWithImpl<$Res>
    implements _$ZiyaraCopyWith<$Res> {
  __$ZiyaraCopyWithImpl(this._self, this._then);

  final _Ziyara _self;
  final $Res Function(_Ziyara) _then;

/// Create a copy of Ziyara
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? content = null,Object? occasion = null,Object? audioUrl = freezed,}) {
  return _then(_Ziyara(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,occasion: null == occasion ? _self.occasion : occasion // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
