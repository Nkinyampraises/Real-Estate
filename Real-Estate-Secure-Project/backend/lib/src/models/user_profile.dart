import '../core/strings.dart';
import '../core/types.dart';
import 'entity.dart';

enum UserRole {
  buyer,
  seller,
  landlord,
  tenant,
  lawyer,
  surveyor,
  agent,
  admin,
  superAdmin,
}

extension UserRoleApi on UserRole {
  String get apiValue => this == UserRole.superAdmin ? 'super_admin' : name;
}

class UserProfile extends Entity implements JsonEncodable {
  const UserProfile({
    required super.id,
    required this.uuid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.isActive = true,
    this.isVerified = false,
    this.createdAt,
  });

  final String uuid;
  final String email;
  final String firstName;
  final String lastName;
  final List<UserRole> roles;
  final bool isActive;
  final bool isVerified;
  final DateTime? createdAt;

  UserProfile copyWith({
    String? email,
    String? firstName,
    String? lastName,
    List<UserRole>? roles,
    bool? isActive,
    bool? isVerified,
  }) {
    return UserProfile(
      id: id,
      uuid: uuid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'full_name': firstName | lastName,
        'roles': roles.map((role) => role.apiValue).toList(),
        'is_active': isActive,
        'is_verified': isVerified,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}

class LawyerProfile extends UserProfile {
  const LawyerProfile({
    required super.id,
    required super.uuid,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.roles,
    required this.barNumber,
    required this.specializations,
    this.averageRating = 0,
  });

  final String barNumber;
  final List<String> specializations;
  final double averageRating;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'bar_number': barNumber,
        'specializations': specializations,
        'average_rating': averageRating,
      };
}
