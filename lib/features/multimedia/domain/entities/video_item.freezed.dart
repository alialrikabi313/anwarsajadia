// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoItem {

 int get id; String get title; String get description; String get videoUrl; String get thumbnailUrl; Duration get duration; int get categoryId; DateTime get publishedAt;
/// Create a copy of VideoItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoItemCopyWith<VideoItem> get copyWith => _$VideoItemCopyWithImpl<VideoItem>(this as VideoItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,videoUrl,thumbnailUrl,duration,categoryId,publishedAt);

@override
String toString() {
  return 'VideoItem(id: $id, title: $title, description: $description, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, duration: $duration, categoryId: $categoryId, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $VideoItemCopyWith<$Res>  {
  factory $VideoItemCopyWith(VideoItem value, $Res Function(VideoItem) _then) = _$VideoItemCopyWithImpl;
@useResult
$Res call({
 int id, String title, String description, String videoUrl, String thumbnailUrl, Duration duration, int categoryId, DateTime publishedAt
});




}
/// @nodoc
class _$VideoItemCopyWithImpl<$Res>
    implements $VideoItemCopyWith<$Res> {
  _$VideoItemCopyWithImpl(this._self, this._then);

  final VideoItem _self;
  final $Res Function(VideoItem) _then;

/// Create a copy of VideoItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? videoUrl = null,Object? thumbnailUrl = null,Object? duration = null,Object? categoryId = null,Object? publishedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoItem].
extension VideoItemPatterns on VideoItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoItem value)  $default,){
final _that = this;
switch (_that) {
case _VideoItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoItem value)?  $default,){
final _that = this;
switch (_that) {
case _VideoItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String description,  String videoUrl,  String thumbnailUrl,  Duration duration,  int categoryId,  DateTime publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.videoUrl,_that.thumbnailUrl,_that.duration,_that.categoryId,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String description,  String videoUrl,  String thumbnailUrl,  Duration duration,  int categoryId,  DateTime publishedAt)  $default,) {final _that = this;
switch (_that) {
case _VideoItem():
return $default(_that.id,_that.title,_that.description,_that.videoUrl,_that.thumbnailUrl,_that.duration,_that.categoryId,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String description,  String videoUrl,  String thumbnailUrl,  Duration duration,  int categoryId,  DateTime publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _VideoItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.videoUrl,_that.thumbnailUrl,_that.duration,_that.categoryId,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc


class _VideoItem implements VideoItem {
  const _VideoItem({required this.id, required this.title, required this.description, required this.videoUrl, required this.thumbnailUrl, required this.duration, required this.categoryId, required this.publishedAt});
  

@override final  int id;
@override final  String title;
@override final  String description;
@override final  String videoUrl;
@override final  String thumbnailUrl;
@override final  Duration duration;
@override final  int categoryId;
@override final  DateTime publishedAt;

/// Create a copy of VideoItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoItemCopyWith<_VideoItem> get copyWith => __$VideoItemCopyWithImpl<_VideoItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,videoUrl,thumbnailUrl,duration,categoryId,publishedAt);

@override
String toString() {
  return 'VideoItem(id: $id, title: $title, description: $description, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, duration: $duration, categoryId: $categoryId, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$VideoItemCopyWith<$Res> implements $VideoItemCopyWith<$Res> {
  factory _$VideoItemCopyWith(_VideoItem value, $Res Function(_VideoItem) _then) = __$VideoItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String description, String videoUrl, String thumbnailUrl, Duration duration, int categoryId, DateTime publishedAt
});




}
/// @nodoc
class __$VideoItemCopyWithImpl<$Res>
    implements _$VideoItemCopyWith<$Res> {
  __$VideoItemCopyWithImpl(this._self, this._then);

  final _VideoItem _self;
  final $Res Function(_VideoItem) _then;

/// Create a copy of VideoItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? videoUrl = null,Object? thumbnailUrl = null,Object? duration = null,Object? categoryId = null,Object? publishedAt = null,}) {
  return _then(_VideoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
