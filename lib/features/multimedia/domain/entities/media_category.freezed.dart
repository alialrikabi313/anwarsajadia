// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaCategory {

 int get id; String get name; String get iconName;
/// Create a copy of MediaCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaCategoryCopyWith<MediaCategory> get copyWith => _$MediaCategoryCopyWithImpl<MediaCategory>(this as MediaCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconName, iconName) || other.iconName == iconName));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,iconName);

@override
String toString() {
  return 'MediaCategory(id: $id, name: $name, iconName: $iconName)';
}


}

/// @nodoc
abstract mixin class $MediaCategoryCopyWith<$Res>  {
  factory $MediaCategoryCopyWith(MediaCategory value, $Res Function(MediaCategory) _then) = _$MediaCategoryCopyWithImpl;
@useResult
$Res call({
 int id, String name, String iconName
});




}
/// @nodoc
class _$MediaCategoryCopyWithImpl<$Res>
    implements $MediaCategoryCopyWith<$Res> {
  _$MediaCategoryCopyWithImpl(this._self, this._then);

  final MediaCategory _self;
  final $Res Function(MediaCategory) _then;

/// Create a copy of MediaCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaCategory].
extension MediaCategoryPatterns on MediaCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaCategory value)  $default,){
final _that = this;
switch (_that) {
case _MediaCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaCategory value)?  $default,){
final _that = this;
switch (_that) {
case _MediaCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String iconName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaCategory() when $default != null:
return $default(_that.id,_that.name,_that.iconName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String iconName)  $default,) {final _that = this;
switch (_that) {
case _MediaCategory():
return $default(_that.id,_that.name,_that.iconName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String iconName)?  $default,) {final _that = this;
switch (_that) {
case _MediaCategory() when $default != null:
return $default(_that.id,_that.name,_that.iconName);case _:
  return null;

}
}

}

/// @nodoc


class _MediaCategory implements MediaCategory {
  const _MediaCategory({required this.id, required this.name, required this.iconName});
  

@override final  int id;
@override final  String name;
@override final  String iconName;

/// Create a copy of MediaCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaCategoryCopyWith<_MediaCategory> get copyWith => __$MediaCategoryCopyWithImpl<_MediaCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconName, iconName) || other.iconName == iconName));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,iconName);

@override
String toString() {
  return 'MediaCategory(id: $id, name: $name, iconName: $iconName)';
}


}

/// @nodoc
abstract mixin class _$MediaCategoryCopyWith<$Res> implements $MediaCategoryCopyWith<$Res> {
  factory _$MediaCategoryCopyWith(_MediaCategory value, $Res Function(_MediaCategory) _then) = __$MediaCategoryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String iconName
});




}
/// @nodoc
class __$MediaCategoryCopyWithImpl<$Res>
    implements _$MediaCategoryCopyWith<$Res> {
  __$MediaCategoryCopyWithImpl(this._self, this._then);

  final _MediaCategory _self;
  final $Res Function(_MediaCategory) _then;

/// Create a copy of MediaCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconName = null,}) {
  return _then(_MediaCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
