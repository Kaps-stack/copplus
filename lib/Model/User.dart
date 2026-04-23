class User {
  final int id;
  final String name;
  final String email;
  final String tel;
  final String sex;
  final String birthdate;
  final String country;
  final String province;
  final String cityResidence;
  final String common;
  final String neighborhood;
  final String street;
  final String streetNumber;
  final String occupation;
  final String role; // client ou prestataire

  // Champs spécifiques Prestataire (synchronisés avec Laravel)
  final String? serviceOffered;
  final String? educationLevel;
  final String? studyDomain;
  final String? languages;
  final String? provinceOrigin;
  final double? salaryMin;
  final double? salaryMax;
  final String? identityCard; // Chemin du fichier
  
  // Autres
  final String? googleId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.tel,
    required this.sex,
    required this.birthdate,
    required this.country,
    required this.province,
    required this.cityResidence,
    required this.common,
    required this.neighborhood,
    required this.street,
    required this.streetNumber,
    required this.occupation,
    required this.role,
    this.serviceOffered,
    this.educationLevel,
    this.studyDomain,
    this.languages,
    this.provinceOrigin,
    this.salaryMin,
    this.salaryMax,
    this.identityCard,
    this.googleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      tel: json['tel'] ?? '',
      sex: json['sex'] ?? '',
      birthdate: json['birthdate'] ?? '',
      country: json['country'] ?? '',
      province: json['province'] ?? '',
      cityResidence: json['city_residence'] ?? '',
      common: json['common'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      street: json['street'] ?? '',
      streetNumber: json['streetnumber'] ?? '', // Match Laravel streetnumber
      occupation: json['occupation'] ?? '',
      role: json['role'] ?? 'client',
      
      // Mapping des nouveaux champs prestataire
      serviceOffered: json['service_offered'],
      educationLevel: json['education_level'],
      studyDomain: json['study_domain'],
      languages: json['languages'],
      provinceOrigin: json['province_origin'],
      salaryMin: json['salary_min'] != null ? double.tryParse(json['salary_min'].toString()) : null,
      salaryMax: json['salary_max'] != null ? double.tryParse(json['salary_max'].toString()) : null,
      identityCard: json['identity_card'],
      googleId: json['google_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'tel': tel,
      'sex': sex,
      'birthdate': birthdate,
      'country': country,
      'province': province,
      'city_residence': cityResidence,
      'common': common,
      'neighborhood': neighborhood,
      'street': street,
      'streetnumber': streetNumber,
      'occupation': occupation,
      'role': role,
      'service_offered': serviceOffered,
      'education_level': educationLevel,
      'study_domain': studyDomain,
      'languages': languages,
      'province_origin': provinceOrigin,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'identity_card': identityCard,
      'google_id': googleId,
    };
  }
}