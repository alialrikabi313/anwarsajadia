// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoItem {

 int get id; String get title; String get imageUrl; int get categoryId; DateTime get publishedAt;
/// Create a copy of PhotoItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoItemCopyWith<PhotoItem> get copyWith => _$PhotoItemCopyWithImpl<PhotoItem>(this as PhotoItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,imageUrl,categoryId,publishedAt);

@override
String toString() {
  return 'PhotoItem(id: $id, title: $title, imageUrl: $imageUrl, categoryId: $categoryId, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $PhotoItemCopyWith<$Res>  {
  factory $PhotoItemCopyWith(PhotoItem value, $Res Function(PhotoItem) _then) = _$PhotoItemCopyWithImpl;
@useResult
$Res call({
 int id, String title, String imageUrl, int categoryId, DateTime publishedAt
});




}
/// @nodoc
class _$PhotoItemCopyWithImpl<$Res>
    implements $PhotoItemCopyWith<$Res> {
  _$PhotoItemCopyWithImpl(this._self, this._then);

  final PhotoItem _self;
  final $Res Function(PhotoItem) _then;

/// Create a copy of PhotoItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? imageUrl = null,Object? categoryId = null,Object? publishedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoItem].
extension PhotoItemPatterns on PhotoItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoItem value)  $default,){
final _that = this;
switch (_that) {
case _PhotoItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoItem value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String imageUrl,  int categoryId,  DateTime publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoItem() when $default != null:
return $default(_that.id,_that.title,_that.imageUrl,_that.categoryId,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String imageUrl,  int categoryId,  DateTime publishedAt)  $default,) {final _that = this;
switch (_that) {
case _PhotoItem():
return $default(_that.id,_that.title,_that.imageUrl,_that.categoryId,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String imageUrl,  int categoryId,  DateTime publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _PhotoItem() when $default != null:
return $default(_that.id,_that.title,_that.imageUrl,_that.categoryId,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoItem implements PhotoItem {
  const _PhotoItem({required this.id, required this.title, required this.imageUrl, required this.categoryId, required this.publishedAt});
  

@override final  int id;
@override final  String title;
@override final  String imageUrl;
@override final  int categoryId;
@override final  DateTime publishedAt;

/// Create a copy of PhotoItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoItemCopyWith<_PhotoItem> get copyWith => __$PhotoItemCopyWithImpl<_PhotoItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,imageUrl,categoryId,publishedAt);

@override
String toString() {
  return 'PhotoItem(id: $id, title: $title, imageUrl: $imageUrl, categoryId: $categoryId, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$PhotoItemCopyWith<$Res> implements $PhotoItemCopyWith<$Res> {
  factory _$PhotoItemCopyWith(_PhotoItem value, $Res Function(_PhotoItem) _then) = __$PhotoItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String imageUrl, int categoryId, DateTime publishedAt
});




}
/// @nodoc
class __$PhotoItemCopyWithImpl<$Res>
    implements _$PhotoItemCopyWith<$Res> {
  __$PhotoItemCopyWithImpl(this._self, this._then);

  final _PhotoItem _self;
  final $Res Function(_PhotoItem) _then;

/// Create a copy of PhotoItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? imageUrl = null,Object? categoryId = null,Object? publishedAt = null,}) {
  return _then(_PhotoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
