// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudioItem {

 int get id; String get title; String get description; String get audioUrl; Duration get duration; int get categoryId; String? get thumbnailUrl; DateTime get publishedAt;
/// Create a copy of AudioItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioItemCopyWith<AudioItem> get copyWith => _$AudioItemCopyWithImpl<AudioItem>(this as AudioItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,audioUrl,duration,categoryId,thumbnailUrl,publishedAt);

@override
String toString() {
  return 'AudioItem(id: $id, title: $title, description: $description, audioUrl: $audioUrl, duration: $duration, categoryId: $categoryId, thumbnailUrl: $thumbnailUrl, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $AudioItemCopyWith<$Res>  {
  factory $AudioItemCopyWith(AudioItem value, $Res Function(AudioItem) _then) = _$AudioItemCopyWithImpl;
@useResult
$Res call({
 int id, String title, String description, String audioUrl, Duration duration, int categoryId, String? thumbnailUrl, DateTime publishedAt
});




}
/// @nodoc
class _$AudioItemCopyWithImpl<$Res>
    implements $AudioItemCopyWith<$Res> {
  _$AudioItemCopyWithImpl(this._self, this._then);

  final AudioItem _self;
  final $Res Function(AudioItem) _then;

/// Create a copy of AudioItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? audioUrl = null,Object? duration = null,Object? categoryId = null,Object? thumbnailUrl = freezed,Object? publishedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AudioItem].
extension AudioItemPatterns on AudioItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudioItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudioItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudioItem value)  $default,){
final _that = this;
switch (_that) {
case _AudioItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudioItem value)?  $default,){
final _that = this;
switch (_that) {
case _AudioItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String description,  String audioUrl,  Duration duration,  int categoryId,  String? thumbnailUrl,  DateTime publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudioItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.audioUrl,_that.duration,_that.categoryId,_that.thumbnailUrl,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String description,  String audioUrl,  Duration duration,  int categoryId,  String? thumbnailUrl,  DateTime publishedAt)  $default,) {final _that = this;
switch (_that) {
case _AudioItem():
return $default(_that.id,_that.title,_that.description,_that.audioUrl,_that.duration,_that.categoryId,_that.thumbnailUrl,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String description,  String audioUrl,  Duration duration,  int categoryId,  String? thumbnailUrl,  DateTime publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _AudioItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.audioUrl,_that.duration,_that.categoryId,_that.thumbnailUrl,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AudioItem implements AudioItem {
  const _AudioItem({required this.id, required this.title, required this.description, required this.audioUrl, required this.duration, required this.categoryId, this.thumbnailUrl, required this.publishedAt});
  

@override final  int id;
@override final  String title;
@override final  String description;
@override final  String audioUrl;
@override final  Duration duration;
@override final  int categoryId;
@override final  String? thumbnailUrl;
@override final  DateTime publishedAt;

/// Create a copy of AudioItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudioItemCopyWith<_AudioItem> get copyWith => __$AudioItemCopyWithImpl<_AudioItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudioItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,audioUrl,duration,categoryId,thumbnailUrl,publishedAt);

@override
String toString() {
  return 'AudioItem(id: $id, title: $title, description: $description, audioUrl: $audioUrl, duration: $duration, categoryId: $categoryId, thumbnailUrl: $thumbnailUrl, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$AudioItemCopyWith<$Res> implements $AudioItemCopyWith<$Res> {
  factory _$AudioItemCopyWith(_AudioItem value, $Res Function(_AudioItem) _then) = __$AudioItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String description, String audioUrl, Duration duration, int categoryId, String? thumbnailUrl, DateTime publishedAt
});




}
/// @nodoc
class __$AudioItemCopyWithImpl<$Res>
    implements _$AudioItemCopyWith<$Res> {
  __$AudioItemCopyWithImpl(this._self, this._then);

  final _AudioItem _self;
  final $Res Function(_AudioItem) _then;

/// Create a copy of AudioItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? audioUrl = null,Object? duration = null,Object? categoryId = null,Object? thumbnailUrl = freezed,Object? publishedAt = null,}) {
  return _then(_AudioItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
