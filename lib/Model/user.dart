class User {
  final int id;
  final String name;
  final String email;
  final String tel;
  final String role;
  final String status;
  final bool isVerified;
  final String verificationStatus;
  final String? cityResidence;
  final double? latitude;
  final double? longitude;
  final String? sex;
  final String? birthdate;
  final String? photo;
  final String? serviceOffered;
  final double? monthlyPrice;
  final String? identityCard;
  final int? reliabilityScore;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.tel,
    required this.role,
    required this.status,
    required this.isVerified,
    required this.verificationStatus,
    this.cityResidence,
    this.latitude,
    this.longitude,
    this.sex,
    this.birthdate,
    this.photo,
    this.serviceOffered,
    this.monthlyPrice,
    this.identityCard,
    this.reliabilityScore,
  });

  /// Vérifie si le profil est complet (utilisé par le Provider et HomeView)
  bool get isProfileComplete {
    if (role == 'admin' || role == 'super-admin') return true;

    // Helper pour vérifier si une String est réellement remplie
    bool isSet(String? val) => val != null && val.isNotEmpty && val != "null" && val != "false";

    bool hasPhoto = isSet(photo);
    bool hasGPS = latitude != null && longitude != null;

    // Logique Client : Photo + GPS + Ville + Sexe
    if (role.toLowerCase() == 'client') {
      return hasPhoto && hasGPS && isSet(cityResidence) && isSet(sex);
    }

    // Logique Prestataire : On peut ajouter identityCard ici si c'est obligatoire pour eux
    return hasPhoto && hasGPS;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      tel: json['tel'] ?? '',
      role: json['role'] ?? 'client',
      status: json['status'] ?? 'active',
      isVerified: json['is_verified'] == true || json['is_verified'] == 1 || json['is_verified'] == "1",
      verificationStatus: json['verification_status'] ?? 'pending',
      cityResidence: json['city_residence'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      sex: json['sex'],
      birthdate: json['birthdate'],
      photo: json['photo'],
      serviceOffered: json['service_offered'],
      monthlyPrice: json['monthly_price'] != null ? double.tryParse(json['monthly_price'].toString()) : null,
      identityCard: json['identity_card'],
      reliabilityScore: json['reliability_score'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'tel': tel,
        'role': role,
        'status': status,
        'is_verified': isVerified,
        'verification_status': verificationStatus,
        'city_residence': cityResidence,
        'latitude': latitude,
        'longitude': longitude,
        'sex': sex,
        'birthdate': birthdate,
        'photo': photo,
        'service_offered': serviceOffered,
        'monthly_price': monthlyPrice,
        'identity_card': identityCard,
        'reliability_score': reliabilityScore,
      };
}