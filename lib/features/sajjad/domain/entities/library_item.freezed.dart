// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LibraryItem {

 int get id; String get title; String get author; String get description; String get content; String? get coverImagePath; DateTime get addedAt;
/// Create a copy of LibraryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryItemCopyWith<LibraryItem> get copyWith => _$LibraryItemCopyWithImpl<LibraryItem>(this as LibraryItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&(identical(other.coverImagePath, coverImagePath) || other.coverImagePath == coverImagePath)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,author,description,content,coverImagePath,addedAt);

@override
String toString() {
  return 'LibraryItem(id: $id, title: $title, author: $author, description: $description, content: $content, coverImagePath: $coverImagePath, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $LibraryItemCopyWith<$Res>  {
  factory $LibraryItemCopyWith(LibraryItem value, $Res Function(LibraryItem) _then) = _$LibraryItemCopyWithImpl;
@useResult
$Res call({
 int id, String title, String author, String description, String content, String? coverImagePath, DateTime addedAt
});




}
/// @nodoc
class _$LibraryItemCopyWithImpl<$Res>
    implements $LibraryItemCopyWith<$Res> {
  _$LibraryItemCopyWithImpl(this._self, this._then);

  final LibraryItem _self;
  final $Res Function(LibraryItem) _then;

/// Create a copy of LibraryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? author = null,Object? description = null,Object? content = null,Object? coverImagePath = freezed,Object? addedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,coverImagePath: freezed == coverImagePath ? _self.coverImagePath : coverImagePath // ignore: cast_nullable_to_non_nullable
as String?,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LibraryItem].
extension LibraryItemPatterns on LibraryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LibraryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LibraryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LibraryItem value)  $default,){
final _that = this;
switch (_that) {
case _LibraryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LibraryItem value)?  $default,){
final _that = this;
switch (_that) {
case _LibraryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String author,  String description,  String content,  String? coverImagePath,  DateTime addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LibraryItem() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.description,_that.content,_that.coverImagePath,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String author,  String description,  String content,  String? coverImagePath,  DateTime addedAt)  $default,) {final _that = this;
switch (_that) {
case _LibraryItem():
return $default(_that.id,_that.title,_that.author,_that.description,_that.content,_that.coverImagePath,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String author,  String description,  String content,  String? coverImagePath,  DateTime addedAt)?  $default,) {final _that = this;
switch (_that) {
case _LibraryItem() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.description,_that.content,_that.coverImagePath,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LibraryItem implements LibraryItem {
  const _LibraryItem({required this.id, required this.title, required this.author, required this.description, required this.content, this.coverImagePath, required this.addedAt});
  

@override final  int id;
@override final  String title;
@override final  String author;
@override final  String description;
@override final  String content;
@override final  String? coverImagePath;
@override final  DateTime addedAt;

/// Create a copy of LibraryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibraryItemCopyWith<_LibraryItem> get copyWith => __$LibraryItemCopyWithImpl<_LibraryItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LibraryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&(identical(other.coverImagePath, coverImagePath) || other.coverImagePath == coverImagePath)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,author,description,content,coverImagePath,addedAt);

@override
String toString() {
  return 'LibraryItem(id: $id, title: $title, author: $author, description: $description, content: $content, coverImagePath: $coverImagePath, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$LibraryItemCopyWith<$Res> implements $LibraryItemCopyWith<$Res> {
  factory _$LibraryItemCopyWith(_LibraryItem value, $Res Function(_LibraryItem) _then) = __$LibraryItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String author, String description, String content, String? coverImagePath, DateTime addedAt
});




}
/// @nodoc
class __$LibraryItemCopyWithImpl<$Res>
    implements _$LibraryItemCopyWith<$Res> {
  __$LibraryItemCopyWithImpl(this._self, this._then);

  final _LibraryItem _self;
  final $Res Function(_LibraryItem) _then;

/// Create a copy of LibraryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? author = null,Object? description = null,Object? content = null,Object? coverImagePath = freezed,Object? addedAt = null,}) {
  return _then(_LibraryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,coverImagePath: freezed == coverImagePath ? _self.coverImagePath : coverImagePath // ignore: cast_nullable_to_non_nullable
as String?,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
