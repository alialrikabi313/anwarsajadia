// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maqam.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Maqam {

 int get id; String get name; String get description; String get location; double? get latitude; double? get longitude; List<String>? get imageUrls;
/// Create a copy of Maqam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaqamCopyWith<Maqam> get copyWith => _$MaqamCopyWithImpl<Maqam>(this as Maqam, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Maqam&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,location,latitude,longitude,const DeepCollectionEquality().hash(imageUrls));

@override
String toString() {
  return 'Maqam(id: $id, name: $name, description: $description, location: $location, latitude: $latitude, longitude: $longitude, imageUrls: $imageUrls)';
}


}

/// @nodoc
abstract mixin class $MaqamCopyWith<$Res>  {
  factory $MaqamCopyWith(Maqam value, $Res Function(Maqam) _then) = _$MaqamCopyWithImpl;
@useResult
$Res call({
 int id, String name, String description, String location, double? latitude, double? longitude, List<String>? imageUrls
});




}
/// @nodoc
class _$MaqamCopyWithImpl<$Res>
    implements $MaqamCopyWith<$Res> {
  _$MaqamCopyWithImpl(this._self, this._then);

  final Maqam _self;
  final $Res Function(Maqam) _then;

/// Create a copy of Maqam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? location = null,Object? latitude = freezed,Object? longitude = freezed,Object? imageUrls = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,imageUrls: freezed == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Maqam].
extension MaqamPatterns on Maqam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Maqam value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Maqam() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Maqam value)  $default,){
final _that = this;
switch (_that) {
case _Maqam():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Maqam value)?  $default,){
final _that = this;
switch (_that) {
case _Maqam() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String description,  String location,  double? latitude,  double? longitude,  List<String>? imageUrls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Maqam() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.location,_that.latitude,_that.longitude,_that.imageUrls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String description,  String location,  double? latitude,  double? longitude,  List<String>? imageUrls)  $default,) {final _that = this;
switch (_that) {
case _Maqam():
return $default(_that.id,_that.name,_that.description,_that.location,_that.latitude,_that.longitude,_that.imageUrls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String description,  String location,  double? latitude,  double? longitude,  List<String>? imageUrls)?  $default,) {final _that = this;
switch (_that) {
case _Maqam() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.location,_that.latitude,_that.longitude,_that.imageUrls);case _:
  return null;

}
}

}

/// @nodoc


class _Maqam implements Maqam {
  const _Maqam({required this.id, required this.name, required this.description, required this.location, this.latitude, this.longitude, final  List<String>? imageUrls}): _imageUrls = imageUrls;
  

@override final  int id;
@override final  String name;
@override final  String description;
@override final  String location;
@override final  double? latitude;
@override final  double? longitude;
 final  List<String>? _imageUrls;
@override List<String>? get imageUrls {
  final value = _imageUrls;
  if (value == null) return null;
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Maqam
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaqamCopyWith<_Maqam> get copyWith => __$MaqamCopyWithImpl<_Maqam>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Maqam&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,location,latitude,longitude,const DeepCollectionEquality().hash(_imageUrls));

@override
String toString() {
  return 'Maqam(id: $id, name: $name, description: $description, location: $location, latitude: $latitude, longitude: $longitude, imageUrls: $imageUrls)';
}


}

/// @nodoc
abstract mixin class _$MaqamCopyWith<$Res> implements $MaqamCopyWith<$Res> {
  factory _$MaqamCopyWith(_Maqam value, $Res Function(_Maqam) _then) = __$MaqamCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String description, String location, double? latitude, double? longitude, List<String>? imageUrls
});




}
/// @nodoc
class __$MaqamCopyWithImpl<$Res>
    implements _$MaqamCopyWith<$Res> {
  __$MaqamCopyWithImpl(this._self, this._then);

  final _Maqam _self;
  final $Res Function(_Maqam) _then;

/// Create a copy of Maqam
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? location = null,Object? latitude = freezed,Object? longitude = freezed,Object? imageUrls = freezed,}) {
  return _then(_Maqam(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,imageUrls: freezed == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
