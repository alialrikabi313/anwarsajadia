// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hierarchical_book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HierarchicalChapter {

 int get id; String get title; String get slug; List<HierarchicalSubject> get subjects;
/// Create a copy of HierarchicalChapter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HierarchicalChapterCopyWith<HierarchicalChapter> get copyWith => _$HierarchicalChapterCopyWithImpl<HierarchicalChapter>(this as HierarchicalChapter, _$identity);

  /// Serializes this HierarchicalChapter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HierarchicalChapter&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&const DeepCollectionEquality().equals(other.subjects, subjects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,const DeepCollectionEquality().hash(subjects));

@override
String toString() {
  return 'HierarchicalChapter(id: $id, title: $title, slug: $slug, subjects: $subjects)';
}


}

/// @nodoc
abstract mixin class $HierarchicalChapterCopyWith<$Res>  {
  factory $HierarchicalChapterCopyWith(HierarchicalChapter value, $Res Function(HierarchicalChapter) _then) = _$HierarchicalChapterCopyWithImpl;
@useResult
$Res call({
 int id, String title, String slug, List<HierarchicalSubject> subjects
});




}
/// @nodoc
class _$HierarchicalChapterCopyWithImpl<$Res>
    implements $HierarchicalChapterCopyWith<$Res> {
  _$HierarchicalChapterCopyWithImpl(this._self, this._then);

  final HierarchicalChapter _self;
  final $Res Function(HierarchicalChapter) _then;

/// Create a copy of HierarchicalChapter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? subjects = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,subjects: null == subjects ? _self.subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<HierarchicalSubject>,
  ));
}

}


/// Adds pattern-matching-related methods to [HierarchicalChapter].
extension HierarchicalChapterPatterns on HierarchicalChapter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HierarchicalChapter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HierarchicalChapter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HierarchicalChapter value)  $default,){
final _that = this;
switch (_that) {
case _HierarchicalChapter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HierarchicalChapter value)?  $default,){
final _that = this;
switch (_that) {
case _HierarchicalChapter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String slug,  List<HierarchicalSubject> subjects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HierarchicalChapter() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.subjects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String slug,  List<HierarchicalSubject> subjects)  $default,) {final _that = this;
switch (_that) {
case _HierarchicalChapter():
return $default(_that.id,_that.title,_that.slug,_that.subjects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String slug,  List<HierarchicalSubject> subjects)?  $default,) {final _that = this;
switch (_that) {
case _HierarchicalChapter() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.subjects);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HierarchicalChapter implements HierarchicalChapter {
  const _HierarchicalChapter({required this.id, required this.title, required this.slug, final  List<HierarchicalSubject> subjects = const []}): _subjects = subjects;
  factory _HierarchicalChapter.fromJson(Map<String, dynamic> json) => _$HierarchicalChapterFromJson(json);

@override final  int id;
@override final  String title;
@override final  String slug;
 final  List<HierarchicalSubject> _subjects;
@override@JsonKey() List<HierarchicalSubject> get subjects {
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjects);
}


/// Create a copy of HierarchicalChapter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HierarchicalChapterCopyWith<_HierarchicalChapter> get copyWith => __$HierarchicalChapterCopyWithImpl<_HierarchicalChapter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HierarchicalChapterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HierarchicalChapter&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&const DeepCollectionEquality().equals(other._subjects, _subjects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,const DeepCollectionEquality().hash(_subjects));

@override
String toString() {
  return 'HierarchicalChapter(id: $id, title: $title, slug: $slug, subjects: $subjects)';
}


}

/// @nodoc
abstract mixin class _$HierarchicalChapterCopyWith<$Res> implements $HierarchicalChapterCopyWith<$Res> {
  factory _$HierarchicalChapterCopyWith(_HierarchicalChapter value, $Res Function(_HierarchicalChapter) _then) = __$HierarchicalChapterCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String slug, List<HierarchicalSubject> subjects
});




}
/// @nodoc
class __$HierarchicalChapterCopyWithImpl<$Res>
    implements _$HierarchicalChapterCopyWith<$Res> {
  __$HierarchicalChapterCopyWithImpl(this._self, this._then);

  final _HierarchicalChapter _self;
  final $Res Function(_HierarchicalChapter) _then;

/// Create a copy of HierarchicalChapter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? subjects = null,}) {
  return _then(_HierarchicalChapter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<HierarchicalSubject>,
  ));
}


}


/// @nodoc
mixin _$HierarchicalSubject {

 String get id; String get title; String get slug; List<Phrase> get phrases;
/// Create a copy of HierarchicalSubject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HierarchicalSubjectCopyWith<HierarchicalSubject> get copyWith => _$HierarchicalSubjectCopyWithImpl<HierarchicalSubject>(this as HierarchicalSubject, _$identity);

  /// Serializes this HierarchicalSubject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HierarchicalSubject&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&const DeepCollectionEquality().equals(other.phrases, phrases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,const DeepCollectionEquality().hash(phrases));

@override
String toString() {
  return 'HierarchicalSubject(id: $id, title: $title, slug: $slug, phrases: $phrases)';
}


}

/// @nodoc
abstract mixin class $HierarchicalSubjectCopyWith<$Res>  {
  factory $HierarchicalSubjectCopyWith(HierarchicalSubject value, $Res Function(HierarchicalSubject) _then) = _$HierarchicalSubjectCopyWithImpl;
@useResult
$Res call({
 String id, String title, String slug, List<Phrase> phrases
});




}
/// @nodoc
class _$HierarchicalSubjectCopyWithImpl<$Res>
    implements $HierarchicalSubjectCopyWith<$Res> {
  _$HierarchicalSubjectCopyWithImpl(this._self, this._then);

  final HierarchicalSubject _self;
  final $Res Function(HierarchicalSubject) _then;

/// Create a copy of HierarchicalSubject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? phrases = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,phrases: null == phrases ? _self.phrases : phrases // ignore: cast_nullable_to_non_nullable
as List<Phrase>,
  ));
}

}


/// Adds pattern-matching-related methods to [HierarchicalSubject].
extension HierarchicalSubjectPatterns on HierarchicalSubject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HierarchicalSubject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HierarchicalSubject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HierarchicalSubject value)  $default,){
final _that = this;
switch (_that) {
case _HierarchicalSubject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HierarchicalSubject value)?  $default,){
final _that = this;
switch (_that) {
case _HierarchicalSubject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  List<Phrase> phrases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HierarchicalSubject() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.phrases);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  List<Phrase> phrases)  $default,) {final _that = this;
switch (_that) {
case _HierarchicalSubject():
return $default(_that.id,_that.title,_that.slug,_that.phrases);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String slug,  List<Phrase> phrases)?  $default,) {final _that = this;
switch (_that) {
case _HierarchicalSubject() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.phrases);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HierarchicalSubject implements HierarchicalSubject {
  const _HierarchicalSubject({required this.id, required this.title, required this.slug, final  List<Phrase> phrases = const []}): _phrases = phrases;
  factory _HierarchicalSubject.fromJson(Map<String, dynamic> json) => _$HierarchicalSubjectFromJson(json);

@override final  String id;
@override final  String title;
@override final  String slug;
 final  List<Phrase> _phrases;
@override@JsonKey() List<Phrase> get phrases {
  if (_phrases is EqualUnmodifiableListView) return _phrases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_phrases);
}


/// Create a copy of HierarchicalSubject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HierarchicalSubjectCopyWith<_HierarchicalSubject> get copyWith => __$HierarchicalSubjectCopyWithImpl<_HierarchicalSubject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HierarchicalSubjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HierarchicalSubject&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&const DeepCollectionEquality().equals(other._phrases, _phrases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,const DeepCollectionEquality().hash(_phrases));

@override
String toString() {
  return 'HierarchicalSubject(id: $id, title: $title, slug: $slug, phrases: $phrases)';
}


}

/// @nodoc
abstract mixin class _$HierarchicalSubjectCopyWith<$Res> implements $HierarchicalSubjectCopyWith<$Res> {
  factory _$HierarchicalSubjectCopyWith(_HierarchicalSubject value, $Res Function(_HierarchicalSubject) _then) = __$HierarchicalSubjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String slug, List<Phrase> phrases
});




}
/// @nodoc
class __$HierarchicalSubjectCopyWithImpl<$Res>
    implements _$HierarchicalSubjectCopyWith<$Res> {
  __$HierarchicalSubjectCopyWithImpl(this._self, this._then);

  final _HierarchicalSubject _self;
  final $Res Function(_HierarchicalSubject) _then;

/// Create a copy of HierarchicalSubject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? phrases = null,}) {
  return _then(_HierarchicalSubject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,phrases: null == phrases ? _self._phrases : phrases // ignore: cast_nullable_to_non_nullable
as List<Phrase>,
  ));
}


}


/// @nodoc
mixin _$Phrase {

 String get id; String get content; List<Explanation> get explanations;
/// Create a copy of Phrase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhraseCopyWith<Phrase> get copyWith => _$PhraseCopyWithImpl<Phrase>(this as Phrase, _$identity);

  /// Serializes this Phrase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Phrase&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.explanations, explanations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,const DeepCollectionEquality().hash(explanations));

@override
String toString() {
  return 'Phrase(id: $id, content: $content, explanations: $explanations)';
}


}

/// @nodoc
abstract mixin class $PhraseCopyWith<$Res>  {
  factory $PhraseCopyWith(Phrase value, $Res Function(Phrase) _then) = _$PhraseCopyWithImpl;
@useResult
$Res call({
 String id, String content, List<Explanation> explanations
});




}
/// @nodoc
class _$PhraseCopyWithImpl<$Res>
    implements $PhraseCopyWith<$Res> {
  _$PhraseCopyWithImpl(this._self, this._then);

  final Phrase _self;
  final $Res Function(Phrase) _then;

/// Create a copy of Phrase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? explanations = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,explanations: null == explanations ? _self.explanations : explanations // ignore: cast_nullable_to_non_nullable
as List<Explanation>,
  ));
}

}


/// Adds pattern-matching-related methods to [Phrase].
extension PhrasePatterns on Phrase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Phrase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Phrase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Phrase value)  $default,){
final _that = this;
switch (_that) {
case _Phrase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Phrase value)?  $default,){
final _that = this;
switch (_that) {
case _Phrase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  List<Explanation> explanations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Phrase() when $default != null:
return $default(_that.id,_that.content,_that.explanations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  List<Explanation> explanations)  $default,) {final _that = this;
switch (_that) {
case _Phrase():
return $default(_that.id,_that.content,_that.explanations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  List<Explanation> explanations)?  $default,) {final _that = this;
switch (_that) {
case _Phrase() when $default != null:
return $default(_that.id,_that.content,_that.explanations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Phrase implements Phrase {
  const _Phrase({required this.id, required this.content, final  List<Explanation> explanations = const []}): _explanations = explanations;
  factory _Phrase.fromJson(Map<String, dynamic> json) => _$PhraseFromJson(json);

@override final  String id;
@override final  String content;
 final  List<Explanation> _explanations;
@override@JsonKey() List<Explanation> get explanations {
  if (_explanations is EqualUnmodifiableListView) return _explanations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_explanations);
}


/// Create a copy of Phrase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhraseCopyWith<_Phrase> get copyWith => __$PhraseCopyWithImpl<_Phrase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhraseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Phrase&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._explanations, _explanations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,const DeepCollectionEquality().hash(_explanations));

@override
String toString() {
  return 'Phrase(id: $id, content: $content, explanations: $explanations)';
}


}

/// @nodoc
abstract mixin class _$PhraseCopyWith<$Res> implements $PhraseCopyWith<$Res> {
  factory _$PhraseCopyWith(_Phrase value, $Res Function(_Phrase) _then) = __$PhraseCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, List<Explanation> explanations
});




}
/// @nodoc
class __$PhraseCopyWithImpl<$Res>
    implements _$PhraseCopyWith<$Res> {
  __$PhraseCopyWithImpl(this._self, this._then);

  final _Phrase _self;
  final $Res Function(_Phrase) _then;

/// Create a copy of Phrase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? explanations = null,}) {
  return _then(_Phrase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,explanations: null == explanations ? _self._explanations : explanations // ignore: cast_nullable_to_non_nullable
as List<Explanation>,
  ));
}


}


/// @nodoc
mixin _$Explanation {

 String get author; String get content;
/// Create a copy of Explanation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplanationCopyWith<Explanation> get copyWith => _$ExplanationCopyWithImpl<Explanation>(this as Explanation, _$identity);

  /// Serializes this Explanation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Explanation&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,author,content);

@override
String toString() {
  return 'Explanation(author: $author, content: $content)';
}


}

/// @nodoc
abstract mixin class $ExplanationCopyWith<$Res>  {
  factory $ExplanationCopyWith(Explanation value, $Res Function(Explanation) _then) = _$ExplanationCopyWithImpl;
@useResult
$Res call({
 String author, String content
});




}
/// @nodoc
class _$ExplanationCopyWithImpl<$Res>
    implements $ExplanationCopyWith<$Res> {
  _$ExplanationCopyWithImpl(this._self, this._then);

  final Explanation _self;
  final $Res Function(Explanation) _then;

/// Create a copy of Explanation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? author = null,Object? content = null,}) {
  return _then(_self.copyWith(
author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Explanation].
extension ExplanationPatterns on Explanation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Explanation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Explanation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Explanation value)  $default,){
final _that = this;
switch (_that) {
case _Explanation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Explanation value)?  $default,){
final _that = this;
switch (_that) {
case _Explanation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String author,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Explanation() when $default != null:
return $default(_that.author,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String author,  String content)  $default,) {final _that = this;
switch (_that) {
case _Explanation():
return $default(_that.author,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String author,  String content)?  $default,) {final _that = this;
switch (_that) {
case _Explanation() when $default != null:
return $default(_that.author,_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Explanation implements Explanation {
  const _Explanation({this.author = '', this.content = ''});
  factory _Explanation.fromJson(Map<String, dynamic> json) => _$ExplanationFromJson(json);

@override@JsonKey() final  String author;
@override@JsonKey() final  String content;

/// Create a copy of Explanation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExplanationCopyWith<_Explanation> get copyWith => __$ExplanationCopyWithImpl<_Explanation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExplanationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Explanation&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,author,content);

@override
String toString() {
  return 'Explanation(author: $author, content: $content)';
}


}

/// @nodoc
abstract mixin class _$ExplanationCopyWith<$Res> implements $ExplanationCopyWith<$Res> {
  factory _$ExplanationCopyWith(_Explanation value, $Res Function(_Explanation) _then) = __$ExplanationCopyWithImpl;
@override @useResult
$Res call({
 String author, String content
});




}
/// @nodoc
class __$ExplanationCopyWithImpl<$Res>
    implements _$ExplanationCopyWith<$Res> {
  __$ExplanationCopyWithImpl(this._self, this._then);

  final _Explanation _self;
  final $Res Function(_Explanation) _then;

/// Create a copy of Explanation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? author = null,Object? content = null,}) {
  return _then(_Explanation(
author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
