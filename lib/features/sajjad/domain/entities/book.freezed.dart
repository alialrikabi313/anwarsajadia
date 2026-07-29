// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Book {

 int get id; String get title; String get description; BookType get bookType; int get chapterCount; String? get coverImagePath;
/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookCopyWith<Book> get copyWith => _$BookCopyWithImpl<Book>(this as Book, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.bookType, bookType) || other.bookType == bookType)&&(identical(other.chapterCount, chapterCount) || other.chapterCount == chapterCount)&&(identical(other.coverImagePath, coverImagePath) || other.coverImagePath == coverImagePath));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,bookType,chapterCount,coverImagePath);

@override
String toString() {
  return 'Book(id: $id, title: $title, description: $description, bookType: $bookType, chapterCount: $chapterCount, coverImagePath: $coverImagePath)';
}


}

/// @nodoc
abstract mixin class $BookCopyWith<$Res>  {
  factory $BookCopyWith(Book value, $Res Function(Book) _then) = _$BookCopyWithImpl;
@useResult
$Res call({
 int id, String title, String description, BookType bookType, int chapterCount, String? coverImagePath
});




}
/// @nodoc
class _$BookCopyWithImpl<$Res>
    implements $BookCopyWith<$Res> {
  _$BookCopyWithImpl(this._self, this._then);

  final Book _self;
  final $Res Function(Book) _then;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? bookType = null,Object? chapterCount = null,Object? coverImagePath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,bookType: null == bookType ? _self.bookType : bookType // ignore: cast_nullable_to_non_nullable
as BookType,chapterCount: null == chapterCount ? _self.chapterCount : chapterCount // ignore: cast_nullable_to_non_nullable
as int,coverImagePath: freezed == coverImagePath ? _self.coverImagePath : coverImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Book].
extension BookPatterns on Book {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Book value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Book() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Book value)  $default,){
final _that = this;
switch (_that) {
case _Book():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Book value)?  $default,){
final _that = this;
switch (_that) {
case _Book() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String description,  BookType bookType,  int chapterCount,  String? coverImagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.bookType,_that.chapterCount,_that.coverImagePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String description,  BookType bookType,  int chapterCount,  String? coverImagePath)  $default,) {final _that = this;
switch (_that) {
case _Book():
return $default(_that.id,_that.title,_that.description,_that.bookType,_that.chapterCount,_that.coverImagePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String description,  BookType bookType,  int chapterCount,  String? coverImagePath)?  $default,) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.bookType,_that.chapterCount,_that.coverImagePath);case _:
  return null;

}
}

}

/// @nodoc


class _Book implements Book {
  const _Book({required this.id, required this.title, required this.description, required this.bookType, required this.chapterCount, this.coverImagePath});
  

@override final  int id;
@override final  String title;
@override final  String description;
@override final  BookType bookType;
@override final  int chapterCount;
@override final  String? coverImagePath;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookCopyWith<_Book> get copyWith => __$BookCopyWithImpl<_Book>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.bookType, bookType) || other.bookType == bookType)&&(identical(other.chapterCount, chapterCount) || other.chapterCount == chapterCount)&&(identical(other.coverImagePath, coverImagePath) || other.coverImagePath == coverImagePath));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,bookType,chapterCount,coverImagePath);

@override
String toString() {
  return 'Book(id: $id, title: $title, description: $description, bookType: $bookType, chapterCount: $chapterCount, coverImagePath: $coverImagePath)';
}


}

/// @nodoc
abstract mixin class _$BookCopyWith<$Res> implements $BookCopyWith<$Res> {
  factory _$BookCopyWith(_Book value, $Res Function(_Book) _then) = __$BookCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String description, BookType bookType, int chapterCount, String? coverImagePath
});




}
/// @nodoc
class __$BookCopyWithImpl<$Res>
    implements _$BookCopyWith<$Res> {
  __$BookCopyWithImpl(this._self, this._then);

  final _Book _self;
  final $Res Function(_Book) _then;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? bookType = null,Object? chapterCount = null,Object? coverImagePath = freezed,}) {
  return _then(_Book(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,bookType: null == bookType ? _self.bookType : bookType // ignore: cast_nullable_to_non_nullable
as BookType,chapterCount: null == chapterCount ? _self.chapterCount : chapterCount // ignore: cast_nullable_to_non_nullable
as int,coverImagePath: freezed == coverImagePath ? _self.coverImagePath : coverImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
