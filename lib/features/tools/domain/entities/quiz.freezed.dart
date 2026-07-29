// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Quiz {

 int get id; String get title; QuizType get quizType; List<Question> get questions; DateTime get availableFrom; DateTime get availableUntil;
/// Create a copy of Quiz
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizCopyWith<Quiz> get copyWith => _$QuizCopyWithImpl<Quiz>(this as Quiz, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Quiz&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.quizType, quizType) || other.quizType == quizType)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,quizType,const DeepCollectionEquality().hash(questions),availableFrom,availableUntil);

@override
String toString() {
  return 'Quiz(id: $id, title: $title, quizType: $quizType, questions: $questions, availableFrom: $availableFrom, availableUntil: $availableUntil)';
}


}

/// @nodoc
abstract mixin class $QuizCopyWith<$Res>  {
  factory $QuizCopyWith(Quiz value, $Res Function(Quiz) _then) = _$QuizCopyWithImpl;
@useResult
$Res call({
 int id, String title, QuizType quizType, List<Question> questions, DateTime availableFrom, DateTime availableUntil
});




}
/// @nodoc
class _$QuizCopyWithImpl<$Res>
    implements $QuizCopyWith<$Res> {
  _$QuizCopyWithImpl(this._self, this._then);

  final Quiz _self;
  final $Res Function(Quiz) _then;

/// Create a copy of Quiz
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? quizType = null,Object? questions = null,Object? availableFrom = null,Object? availableUntil = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,quizType: null == quizType ? _self.quizType : quizType // ignore: cast_nullable_to_non_nullable
as QuizType,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,availableFrom: null == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as DateTime,availableUntil: null == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Quiz].
extension QuizPatterns on Quiz {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Quiz value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Quiz() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Quiz value)  $default,){
final _that = this;
switch (_that) {
case _Quiz():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Quiz value)?  $default,){
final _that = this;
switch (_that) {
case _Quiz() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  QuizType quizType,  List<Question> questions,  DateTime availableFrom,  DateTime availableUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Quiz() when $default != null:
return $default(_that.id,_that.title,_that.quizType,_that.questions,_that.availableFrom,_that.availableUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  QuizType quizType,  List<Question> questions,  DateTime availableFrom,  DateTime availableUntil)  $default,) {final _that = this;
switch (_that) {
case _Quiz():
return $default(_that.id,_that.title,_that.quizType,_that.questions,_that.availableFrom,_that.availableUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  QuizType quizType,  List<Question> questions,  DateTime availableFrom,  DateTime availableUntil)?  $default,) {final _that = this;
switch (_that) {
case _Quiz() when $default != null:
return $default(_that.id,_that.title,_that.quizType,_that.questions,_that.availableFrom,_that.availableUntil);case _:
  return null;

}
}

}

/// @nodoc


class _Quiz implements Quiz {
  const _Quiz({required this.id, required this.title, required this.quizType, required final  List<Question> questions, required this.availableFrom, required this.availableUntil}): _questions = questions;
  

@override final  int id;
@override final  String title;
@override final  QuizType quizType;
 final  List<Question> _questions;
@override List<Question> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override final  DateTime availableFrom;
@override final  DateTime availableUntil;

/// Create a copy of Quiz
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizCopyWith<_Quiz> get copyWith => __$QuizCopyWithImpl<_Quiz>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Quiz&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.quizType, quizType) || other.quizType == quizType)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,quizType,const DeepCollectionEquality().hash(_questions),availableFrom,availableUntil);

@override
String toString() {
  return 'Quiz(id: $id, title: $title, quizType: $quizType, questions: $questions, availableFrom: $availableFrom, availableUntil: $availableUntil)';
}


}

/// @nodoc
abstract mixin class _$QuizCopyWith<$Res> implements $QuizCopyWith<$Res> {
  factory _$QuizCopyWith(_Quiz value, $Res Function(_Quiz) _then) = __$QuizCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, QuizType quizType, List<Question> questions, DateTime availableFrom, DateTime availableUntil
});




}
/// @nodoc
class __$QuizCopyWithImpl<$Res>
    implements _$QuizCopyWith<$Res> {
  __$QuizCopyWithImpl(this._self, this._then);

  final _Quiz _self;
  final $Res Function(_Quiz) _then;

/// Create a copy of Quiz
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? quizType = null,Object? questions = null,Object? availableFrom = null,Object? availableUntil = null,}) {
  return _then(_Quiz(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,quizType: null == quizType ? _self.quizType : quizType // ignore: cast_nullable_to_non_nullable
as QuizType,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,availableFrom: null == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as DateTime,availableUntil: null == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
