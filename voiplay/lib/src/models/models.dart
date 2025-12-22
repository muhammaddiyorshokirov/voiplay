class Anime {
  final String id;
  final String title;
  final String slug;
  final String? image;
  final String? coverImage;
  final String? description;
  final String? studio;
  final String? language;
  final int releaseYear;
  final String? duration;
  final String? status;
  final double rating;
  final bool isPremium;
  final String? premiumUnlockAt;
  final int views;
  final List<String> genres;

  Anime({
    required this.id,
    required this.title,
    required this.slug,
    this.image,
    this.coverImage,
    this.description,
    this.studio,
    this.language,
    required this.releaseYear,
    this.duration,
    this.status,
    required this.rating,
    required this.isPremium,
    this.premiumUnlockAt,
    required this.views,
    required this.genres,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      coverImage: json['cover_image'],
      description: json['description'],
      studio: json['studio'],
      language: json['language'],
      releaseYear: json['release_year'] ?? 0,
      duration: json['duration'],
      status: json['status'],
      rating: (json['rating'] ?? 0).toDouble(),
      isPremium: json['is_premium'] ?? false,
      premiumUnlockAt: json['premium_unlock_at'],
      views: json['views'] ?? 0,
      genres: List<String>.from(json['genres'] ?? []),
    );
  }
}

class Episode {
  final String id;
  final String animeId;
  final String? animeTitle;
  final String title;
  final int? episodeNumber;
  final String? description;
  final String videoUrl;
  final String? thumbnail;
  final int? duration;
  final bool isPremium;
  final String? premiumUnlockAt;
  final int views;
  final int likes;
  final int dislikes;
  final int commentsCount;
  final String? tags;
  final String? releaseDate;
  final String language;
  final String episodeType;
  final bool isOfficial;
  final bool isActive;
  final String contentMakerId;
  final String? downloadUrl;

  Episode({
    required this.id,
    required this.animeId,
    this.animeTitle,
    required this.title,
    this.episodeNumber,
    this.description,
    required this.videoUrl,
    this.thumbnail,
    this.duration,
    required this.isPremium,
    this.premiumUnlockAt,
    required this.views,
    required this.likes,
    required this.dislikes,
    required this.commentsCount,
    this.tags,
    this.releaseDate,
    required this.language,
    required this.episodeType,
    required this.isOfficial,
    required this.isActive,
    required this.contentMakerId,
    this.downloadUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? '',
      animeId: json['anime_id'] ?? '',
      animeTitle: json['anime_title'],
      title: json['title'] ?? '',
      episodeNumber: json['episode_number'],
      description: json['description'],
      videoUrl: json['video_url'] ?? '',
      thumbnail: json['thumbnail'],
      duration: json['duration'],
      isPremium: json['is_premium'] ?? false,
      premiumUnlockAt: json['premium_unlock_at'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      tags: json['tags'],
      releaseDate: json['release_date'],
      language: json['language'] ?? 'uz',
      episodeType: json['episode_type'] ?? 'standard',
      isOfficial: json['is_official'] ?? false,
      isActive: json['is_active'] ?? true,
      contentMakerId: json['content_maker_id'] ?? '',
      downloadUrl: json['download_url'],
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  final String role;
  final bool premiumStatus;
  final String? premiumExpiresAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
    required this.role,
    required this.premiumStatus,
    this.premiumExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
      role: json['role'] ?? 'user',
      premiumStatus: json['premium_status'] ?? false,
      premiumExpiresAt: json['premium_expires_at'],
    );
  }
}

class News {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String? image;
  final String authorId;
  final String? authorName;
  final int views;
  final int likes;
  final int dislikes;
  final int commentsCount;
  final bool isPublished;
  final String? publishedAt;

  News({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.image,
    required this.authorId,
    this.authorName,
    required this.views,
    required this.likes,
    required this.dislikes,
    required this.commentsCount,
    required this.isPublished,
    this.publishedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      image: json['image'],
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isPublished: json['is_published'] ?? false,
      publishedAt: json['published_at'],
    );
  }
}
