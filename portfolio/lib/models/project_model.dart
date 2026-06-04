class Project {
  final String id;
  final String title;
  final String description;
  final String image;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final String? githubUrl;
  final List<String> tags;
  final List<String> features;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.playStoreUrl,
    this.appStoreUrl,
    this.githubUrl,
    required this.tags,
    required this.features,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      playStoreUrl: json['playStoreUrl'] == '' ? null : json['playStoreUrl'],
      appStoreUrl: json['appStoreUrl'] == '' ? null : json['appStoreUrl'],
      githubUrl: json['githubUrl'] == '' ? null : json['githubUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'playStoreUrl': playStoreUrl ?? '',
      'appStoreUrl': appStoreUrl ?? '',
      'githubUrl': githubUrl ?? '',
      'tags': tags,
      'features': features,
    };
  }
}
