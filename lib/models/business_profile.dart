class Contact {
  final String phone;
  final String email;
  final String website;

  Contact({required this.phone, required this.email, required this.website});

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        website: json['website'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'email': email,
        'website': website,
      };
}

class Promotion {
  final String headline;
  final String details;
  final String cta;
  final String validity;

  Promotion({
    required this.headline,
    required this.details,
    required this.cta,
    required this.validity,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        headline: json['headline'] ?? '',
        details: json['details'] ?? '',
        cta: json['cta'] ?? '',
        validity: json['validity'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'headline': headline,
        'details': details,
        'cta': cta,
        'validity': validity,
      };
}

class BusinessProfile {
  final String id;
  final String userId;
  final String businessName;
  final String tagline;
  final Contact contact;
  final List<String> socials;
  final Promotion promotion;
  final String logoUrl;

  BusinessProfile( {
    required this.id,
    required this.businessName,
    required this.tagline,
    required this.contact,
    required this.socials,
    required this.promotion,
    this.logoUrl = '',
    this.userId = '',
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
        id: json['_id'] ?? '',
        businessName: json['business_name'] ?? '',
        tagline: json['tagline'] ?? '',
        contact: Contact.fromJson(json['contact'] ?? {}),
        socials: (json['socials'] as List?)?.map((e) => e.toString()).toList() ?? [],
        promotion: Promotion.fromJson(json['promotion'] ?? {}),
        logoUrl: json['logo_url'] ?? '',
        userId: json['user_id'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'business_name': businessName,
        'tagline': tagline,
        'contact': contact.toJson(),
        'socials': socials,
        'promotion': promotion.toJson(),
        'logo_url': logoUrl,
        'user_id': userId,
      };
}

