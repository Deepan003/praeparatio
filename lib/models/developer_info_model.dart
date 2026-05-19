class DeveloperInfoModel {
  final bool isEnabled;
  final bool isMaintenance;
  final String name;
  final String? avatarUrl;
  final bool showAvatar;
  final List<DeveloperLink> links;

  DeveloperInfoModel({
    required this.isEnabled,
    this.isMaintenance = false,
    required this.name,
    this.avatarUrl,
    required this.showAvatar,
    required this.links,
  });

  factory DeveloperInfoModel.fromJson(Map<String, dynamic> json) {
    return DeveloperInfoModel(
      isEnabled: json['is_enabled'] ?? false,
      isMaintenance: json['is_maintenance'] ?? false,
      name: json['name'] ?? 'Deepan Pramanick',
      avatarUrl: json['avatar_url'],
      showAvatar: json['show_avatar'] ?? true,
      links: (json['links'] as List?)?.map((e) => DeveloperLink.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'is_enabled': isEnabled,
        'is_maintenance': isMaintenance,
        'name': name,
        'avatar_url': avatarUrl,
        'show_avatar': showAvatar,
        'links': links.map((e) => e.toJson()).toList(),
      };

  DeveloperInfoModel copyWith({
    bool? isEnabled,
    bool? isMaintenance,
    String? name,
    String? avatarUrl,
    bool? showAvatar,
    List<DeveloperLink>? links,
  }) {
    return DeveloperInfoModel(
      isEnabled: isEnabled ?? this.isEnabled,
      isMaintenance: isMaintenance ?? this.isMaintenance,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      showAvatar: showAvatar ?? this.showAvatar,
      links: links ?? this.links,
    );
  }
}

class DeveloperLink {
  final String platform;
  final String url;

  DeveloperLink({required this.platform, required this.url});

  factory DeveloperLink.fromJson(Map<String, dynamic> json) {
    return DeveloperLink(
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'url': url,
      };
}
