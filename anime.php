

<!DOCTYPE html>
<html lang="uz" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Barcha Anime | VoiPlay.uz</title>
    <meta name="description" content="O&#039;zbek tilidagi barcha anime serial va filmlar. Turli janrlardagi eng yaxshi animelarni tomosha qiling.">
    <meta name="keywords" content="anime, o&#039;zbek tilida anime, anime ro&#039;yxati, barcha anime, VoiPlay">
    
    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://voiplay.uz/anime.php">
    <meta property="og:title" content="Barcha Anime | VoiPlay.uz">
    <meta property="og:description" content="O&#039;zbek tilidagi barcha anime serial va filmlar. Turli janrlardagi eng yaxshi animelarni tomosha qiling.">
    <meta property="og:image" content="https://voiplay.uz/assets/images/social-banner.jpg">
    
    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image">
    <meta property="twitter:url" content="https://voiplay.uz/anime.php">
    <meta property="twitter:title" content="Barcha Anime | VoiPlay.uz">
    <meta property="twitter:description" content="O&#039;zbek tilidagi barcha anime serial va filmlar. Turli janrlardagi eng yaxshi animelarni tomosha qiling.">
    <meta property="twitter:image" content="https://voiplay.uz/assets/images/social-banner.jpg">
    
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="/assets/images/favicon.png">
    
    <!-- Styles -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'voiplay-primary': '#E50914',
                        'voiplay-primary-dark': '#B00710',
                        'voiplay-secondary': '#221F1F',
                        'voiplay-accent': '#F5F5F1',
                    },
                    fontFamily: {
                        'sans': ['Poppins', 'sans-serif'],
                    },
                }
            }
        }
    </script>
    <style>
        .filter-button.active {
            background-color: #E50914;
            color: white;
        }
        .anime-card:hover .anime-title {
            color: #E50914;
        }
    </style>
</head>
<body class="bg-voiplay-secondary text-white font-sans">
    
<nav class="navbar fixed w-full z-50 transition-all duration-300 bg-gray-900 bg-opacity-90">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
            <!-- Logo -->
            <div class="flex items-center flex-shrink-0">
                <a href="/" class="flex items-center">
                    <img src="https://cdn-images-1.medium.com/max/1200/1*ty4NvNrGg4ReETxqU2N3Og.png" alt="VoiPlay.uz" class="h-8 w-auto">
                    <span class="ml-2 text-xl font-bold text-white hidden sm:inline">VoiPlay</span>
                </a>
            </div>

            <!-- Desktop Menu -->
            <div class="hidden md:flex items-center space-x-6">
                <a href="/" class="nav-link text-gray-300 hover:text-white">
                    Bosh Sahifa
                </a>
                <a href="/anime.php" class="nav-link text-voiplay-primary font-semibold">
                    Anime
                </a>
                <a href="/trending.php" class="nav-link text-gray-300 hover:text-white">
                    Trendda
                </a>
                <a href="/episode.php" class="nav-link text-gray-300 hover:text-white">
                    Yangi Qismlar
                </a>
                <a href="/news.php" class="nav-link text-gray-300 hover:text-white">
                    Yangiliklar
                </a>
            </div>

            <!-- Search and User -->
            <div class="flex items-center space-x-4">
                <button id="searchToggle" class="text-gray-300 hover:text-white focus:outline-none">
                    <i class="fas fa-search"></i>
                </button>
                
                                    <div class="relative group">
                        <button class="flex items-center space-x-2 focus:outline-none">
                            <img src="avatars/admin.jpg" 
                                 alt="Profile" 
                                 class="w-8 h-8 rounded-full object-cover border-2 border-transparent group-hover:border-voiplay-primary">
                            <span class="text-white hidden lg:inline">admin</span>
                        </button>
                        <div class="absolute right-0 mt-2 w-48 bg-gray-800 rounded-md shadow-lg py-1 z-50 hidden group-hover:block">
                            <a href="/profile.php" class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700">Profil</a>
                            <a href="/watchlist.php" class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700">Kuzatuv ro'yxati</a>
                            <a href="/settings.php" class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700">Sozlamalar</a>
                            <div class="border-t border-gray-700"></div>
                            <a href="/logout.php" class="block px-4 py-2 text-sm text-red-400 hover:bg-gray-700">Chiqish</a>
                        </div>
                    </div>
                            </div>

            <!-- Mobile Menu Button -->
            <div class="flex md:hidden">
                <button id="mobileMenuButton" class="text-gray-300 hover:text-white focus:outline-none">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                    </svg>
                </button>
            </div>
        </div>
    </div>

    <!-- Mobile Menu -->
    <div id="mobileMenu" class="hidden md:hidden bg-gray-900">
        <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3">
            <a href="/" class="mobile-nav-link text-gray-300 hover:bg-gray-700 hover:text-white block px-3 py-2 rounded-md text-base font-medium">
                Bosh Sahifa
            </a>
            <a href="/anime.php" class="mobile-nav-link bg-gray-800 text-white block px-3 py-2 rounded-md text-base font-medium">
                Anime
            </a>
            <a href="/trending.php" class="mobile-nav-link text-gray-300 hover:bg-gray-700 hover:text-white block px-3 py-2 rounded-md text-base font-medium">
                Trendda
            </a>
            <a href="/episode.php" class="mobile-nav-link text-gray-300 hover:bg-gray-700 hover:text-white block px-3 py-2 rounded-md text-base font-medium">
                Yangi Qismlar
            </a>
            <a href="/news.php" class="mobile-nav-link text-gray-300 hover:bg-gray-700 hover:text-white block px-3 py-2 rounded-md text-base font-medium">
                Yangiliklar
            </a>
        </div>
    </div>

    <!-- Search Bar -->
    <div id="searchBar" class="hidden absolute top-16 left-0 right-0 bg-gray-900 py-3 px-4 shadow-lg">
        <div class="container mx-auto">
            <form action="/search.php" method="GET" class="relative">
                <input type="text" name="q" placeholder="Anime, serial yoki kinolar qidirish..." 
                       class="w-full bg-gray-800 text-white px-4 py-3 rounded-lg pl-12 focus:outline-none focus:ring-2 focus:ring-voiplay-primary">
                <button type="submit" class="absolute left-3 top-3 text-gray-400 hover:text-white">
                    <i class="fas fa-search"></i>
                </button>
            </form>
        </div>
    </div>
</nav>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Mobile menu toggle
        const mobileMenuButton = document.getElementById('mobileMenuButton');
        const mobileMenu = document.getElementById('mobileMenu');
        
        mobileMenuButton.addEventListener('click', function() {
            mobileMenu.classList.toggle('hidden');
        });

        // Search toggle
        const searchToggle = document.getElementById('searchToggle');
        const searchBar = document.getElementById('searchBar');
        
        searchToggle.addEventListener('click', function() {
            searchBar.classList.toggle('hidden');
            if (!searchBar.classList.contains('hidden')) {
                searchBar.querySelector('input').focus();
            }
        });

        // Close search when clicking outside
        document.addEventListener('click', function(e) {
            if (!searchBar.contains(e.target) && e.target !== searchToggle) {
                searchBar.classList.add('hidden');
            }
        });
    });
</script>
    <main class="min-h-screen">
        <!-- Hero Section -->
        <div class="relative bg-gradient-to-r from-black to-transparent h-64">
            <div class="absolute inset-0 bg-black opacity-60 z-10"></div>
            <div class="absolute inset-0 z-0">
                <img src="https://cdn.pfps.gg/banners/5480-dark-aesthetic-anime.png" alt="Anime Banner" class="w-full h-full object-cover">
            </div>
            
            <div class="container mx-auto px-4 sm:px-6 lg:px-8 h-full flex items-center relative z-20">
                <div class="max-w-2xl">
                    <h1 class="text-3xl sm:text-4xl md:text-5xl font-bold mb-4">Barcha Anime</h1>
                    <p class="text-lg text-gray-300">O'zbek tilidagi barcha anime serial va filmlar</p>
                </div>
            </div>
        </div>

        <!-- Anime List Section -->
        <section class="py-12 bg-voiplay-secondary">
            <div class="container mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex flex-col lg:flex-row gap-8">
                    <!-- Filters Sidebar -->
                    <div class="lg:w-1/4">
                        <div class="bg-gray-800 rounded-lg shadow-lg p-6 sticky top-4">
                            <h3 class="text-xl font-bold mb-6 border-b border-gray-700 pb-2">Filtrlar</h3>
                            
                            <!-- Search Form -->
                            <form method="GET" action="/search.php" class="mb-6">
                                <div class="relative">
                                    <input type="text" name="q" placeholder="Anime qidirish..." 
                                           class="w-full bg-gray-700 text-white px-4 py-2 rounded-lg pl-10 focus:outline-none focus:ring-2 focus:ring-voiplay-primary">
                                    <button type="submit" class="absolute left-3 top-2.5 text-gray-400 hover:text-white">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </form>
                            
                            <!-- Genre Filter -->
                            <div class="mb-6">
                                <h4 class="font-semibold mb-3">Janrlar</h4>
                                <div class="flex flex-wrap gap-2">
                                    <a href="/anime.php" 
                                       class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors active">
                                        Hammasi
                                    </a>
                                                                            <a href="/anime.php?genre=Action" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Action                                            <span class="text-gray-400 ml-1">(9)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Fantasy" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Fantasy                                            <span class="text-gray-400 ml-1">(3)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Adventure" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Adventure                                            <span class="text-gray-400 ml-1">(2)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Comedy" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Comedy                                            <span class="text-gray-400 ml-1">(2)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Drama" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Drama                                            <span class="text-gray-400 ml-1">(2)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Horror" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Horror                                            <span class="text-gray-400 ml-1">(2)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Supernatural" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Supernatural                                            <span class="text-gray-400 ml-1">(2)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Historical" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Historical                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Mystery" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Mystery                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Psychological" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Psychological                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=School" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            School                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Shounen" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Shounen                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Slice+of+Life" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Slice of Life                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?genre=Super+Power" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            Super Power                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                    </div>
                            </div>
                            
                            <!-- Year Filter -->
                            <div class="mb-6">
                                <h4 class="font-semibold mb-3">Chiqgan yili</h4>
                                <div class="flex flex-wrap gap-2">
                                    <a href="/anime.php" 
                                       class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors active">
                                        Hammasi
                                    </a>
                                                                            <a href="/anime.php?year=2022" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            2022                                            <span class="text-gray-400 ml-1">(2)</span>
                                        </a>
                                                                            <a href="/anime.php?year=2020" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            2020                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?year=2019" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            2019                                            <span class="text-gray-400 ml-1">(2)</span>
                                        </a>
                                                                            <a href="/anime.php?year=2016" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            2016                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?year=2013" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            2013                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?year=2007" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            2007                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?year=2006" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            2006                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                            <a href="/anime.php?year=1999" 
                                           class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                            1999                                            <span class="text-gray-400 ml-1">(1)</span>
                                        </a>
                                                                    </div>
                            </div>
                            
                            <!-- Status Filter -->
                            <div class="mb-6">
                                <h4 class="font-semibold mb-3">Status</h4>
                                <div class="flex flex-wrap gap-2">
                                    <a href="/anime.php" 
                                       class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors active">
                                        Hammasi
                                    </a>
                                    <a href="/anime.php?status=ongoing" 
                                       class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                        Davom etayotgan
                                    </a>
                                    <a href="/anime.php?status=completed" 
                                       class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                        Tugallangan
                                    </a>
                                    <a href="/anime.php?status=upcoming" 
                                       class="filter-button px-3 py-1 bg-gray-700 rounded-full text-sm hover:bg-gray-600 transition-colors ">
                                        Tez orada
                                    </a>
                                </div>
                            </div>
                            
                            <!-- Sort Options -->
                            <div>
                                <h4 class="font-semibold mb-3">Saralash</h4>
                                <select id="sort-select" class="w-full bg-gray-700 text-white px-3 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-voiplay-primary">
                                    <option value="popular" selected>Mashhurlik bo'yicha</option>
                                    <option value="newest" >Yangi qo'shilganlar</option>
                                    <option value="oldest" >Eski qo'shilganlar</option>
                                    <option value="rating" >Reyting bo'yicha</option>
                                    <option value="views" >Ko'rishlar soni</option>
                                    <option value="title" >Nomi bo'yicha (A-Z)</option>
                                    <option value="year" >Yil bo'yicha</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Anime Grid -->
                    <div class="lg:w-3/4">
                        <!-- Filter Tags -->
                        <div class="flex flex-wrap items-center gap-3 mb-6">
                            <span class="text-gray-400">Filtrlar:</span>
                                                        
                                                        
                                                        
                                                    </div>
                        
                        <!-- Sort and Results Info -->
                        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6">
                            <div class="text-gray-400 mb-3 sm:mb-0">
                                10 ta anime topildi
                            </div>
                            <div class="flex items-center space-x-2">
                                <span class="text-gray-400">Ko'rsatish:</span>
                                <select id="per-page-select" class="bg-gray-800 text-white px-2 py-1 rounded focus:outline-none">
                                    <option value="12">12</option>
                                    <option value="24" selected>24</option>
                                    <option value="48">48</option>
                                    <option value="96">96</option>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Anime Grid -->
                                                    <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 sm:gap-6">
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0005" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BMTNjNGU4NTUtYmVjMy00YjRiLTkxMWUtNzZkMDNiYjZhNmViXkEyXkFqcGc@._V1_.jpg" 
                                                     alt="One Piece" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    0 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            8.6                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                One Piece                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">1999</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0010" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BYTgyZDhmMTEtZDFhNi00MTc4LTg3NjUtYWJlNGE5Mzk2NzMxXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg" 
                                                     alt="Death Note" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    0 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            9.0                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                Death Note                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2006</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0001" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BNTk3MDA1ZjAtNTRhYS00YzNiLTgwOGEtYWRmYTQ3NjA0NTAwXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg" 
                                                     alt="Naruto: Shippuden" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    3 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            2.0                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                Naruto: Shippuden                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2007</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0002" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BZjliODY5MzQtMmViZC00MTZmLWFhMWMtMjMwM2I3OGY1MTRiXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg" 
                                                     alt="Attack on Titan" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    3 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                    <div class="absolute top-2 left-2 bg-amber-500 text-black text-xs font-bold px-2 py-1 rounded flex items-center">
                                                        <i class="fas fa-crown mr-1"></i> Premium
                                                    </div>
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            9.0                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                Attack on Titan                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2013</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0007" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://printler.com/media/photo/141583.jpg" 
                                                     alt="Chainsaw Man" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    0 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                    <div class="absolute top-2 left-2 bg-amber-500 text-black text-xs font-bold px-2 py-1 rounded flex items-center">
                                                        <i class="fas fa-crown mr-1"></i> Premium
                                                    </div>
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            9.1                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                Chainsaw Man                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2022</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0003" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BMGVhZTY1YTctOWJlYS00MjcxLTlkNDgtYTUxZTM5MzMzZjI2XkEyXkFqcGc@._V1_.jpg" 
                                                     alt="Demon Slayer" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    3 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            8.9                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                Demon Slayer                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2019</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0008" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BZDkwNjc0NWEtNzJlOC00N2YwLTk4MjktZGFlZDE2Y2QzOWI0XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg" 
                                                     alt="Spy x Family" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    0 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            8.9                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                Spy x Family                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2022</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0004" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BNmI1MmYxNWQtY2E5NC00ZTlmLWIzZGEtNzM1YmE3NDA5NzhjXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg" 
                                                     alt="Jujutsu Kaisen" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    0 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                    <div class="absolute top-2 left-2 bg-amber-500 text-black text-xs font-bold px-2 py-1 rounded flex items-center">
                                                        <i class="fas fa-crown mr-1"></i> Premium
                                                    </div>
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            8.8                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                Jujutsu Kaisen                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2020</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0006" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BY2QzODA5OTQtYWJlNi00ZjIzLThhNTItMDMwODhlYzYzMjA2XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg" 
                                                     alt="My Hero Academia" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    0 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            5.0                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                My Hero Academia                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2016</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                                    <div class="anime-card group">
                                        <a href="/anime-details.php?id=anime-0009" class="block">
                                            <div class="aspect-[2/3] rounded-lg overflow-hidden shadow-lg group-hover:shadow-xl transition-shadow mb-2 relative">
                                                <img src="https://m.media-amazon.com/images/M/MV5BNDA3MGNmZTEtMzFiMy00ZmViLThhNmQtMjQ4ZDc5MDEyN2U1XkEyXkFqcGc@._V1_.jpg" 
                                                     alt="Vinland Saga" 
                                                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                                                
                                                <!-- Episode count badge -->
                                                <div class="absolute top-2 right-2 bg-black bg-opacity-70 text-white text-xs px-2 py-1 rounded">
                                                    0 qism
                                                </div>
                                                
                                                <!-- Premium badge -->
                                                                                                    <div class="absolute top-2 left-2 bg-amber-500 text-black text-xs font-bold px-2 py-1 rounded flex items-center">
                                                        <i class="fas fa-crown mr-1"></i> Premium
                                                    </div>
                                                                                                
                                                <!-- Overlay -->
                                                <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                                                    <div class="flex items-center">
                                                        <span class="text-amber-400 text-xs font-semibold mr-1">
                                                            8.8                                                        </span>
                                                        <i class="fas fa-star text-amber-400 text-xs"></i>
                                                    </div>
                                                </div>
                                            </div>
                                            <h3 class="anime-title font-medium text-sm sm:text-base line-clamp-2 group-hover:text-voiplay-primary transition-colors">
                                                Vinland Saga                                            </h3>
                                            <div class="flex items-center justify-between mt-1">
                                                <span class="text-gray-400 text-xs">2019</span>
                                                <span class="text-gray-400 text-xs">
                                                    <i class="fas fa-eye mr-1"></i> 0.0k
                                                </span>
                                            </div>
                                        </a>
                                    </div>
                                                            </div>
                            
                            <!-- Pagination -->
                                                                        </div>
                </div>
            </div>
        </section>
    </main>

    <footer class="bg-gray-900 text-gray-400 pt-16 pb-8">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <!-- About Section -->
            <div class="lg:col-span-2">
                <div class="flex items-center mb-4">
                    <img src="/assets/images/logo.png" alt="VoiPlay.uz" class="h-8 w-auto">
                    <span class="ml-2 text-xl font-bold text-white">VoiPlay</span>
                </div>
                <p class="text-sm mb-4">
                    VoiPlay - O'zbek tilidagi eng yirik anime va seriallar platformasi. Bizda eng yangi va mashhur kontentlarni HD sifatda tomosha qiling.
                </p>
                <div class="flex space-x-4">
                    <a href="#" class="text-gray-400 hover:text-white transition-colors">
                        <i class="fab fa-telegram fa-lg"></i>
                    </a>
                    <a href="#" class="text-gray-400 hover:text-white transition-colors">
                        <i class="fab fa-instagram fa-lg"></i>
                    </a>
                    <a href="#" class="text-gray-400 hover:text-white transition-colors">
                        <i class="fab fa-youtube fa-lg"></i>
                    </a>
                    <a href="#" class="text-gray-400 hover:text-white transition-colors">
                        <i class="fab fa-facebook fa-lg"></i>
                    </a>
                </div>
            </div>

            <!-- Quick Links -->
            <div>
                <h3 class="text-lg font-semibold text-white mb-4">Tez Havolalar</h3>
                <ul class="space-y-2">
                    <li><a href="/" class="hover:text-voiplay-primary transition-colors">Bosh Sahifa</a></li>
                    <li><a href="/anime.php" class="hover:text-voiplay-primary transition-colors">Anime</a></li>
                    <li><a href="/trending.php" class="hover:text-voiplay-primary transition-colors">Trendda</a></li>
                    <li><a href="/genres.php" class="hover:text-voiplay-primary transition-colors">Janrlar</a></li>
                    <li><a href="/news.php" class="hover:text-voiplay-primary transition-colors">Yangiliklar</a></li>
                </ul>
            </div>

            <!-- Help & Legal -->
            <div>
                <h3 class="text-lg font-semibold text-white mb-4">Yordam</h3>
                <ul class="space-y-2">
                    <li><a href="/help.php" class="hover:text-voiplay-primary transition-colors">Yordam Markazi</a></li>
                    <li><a href="/contact.php" class="hover:text-voiplay-primary transition-colors">Bog'lanish</a></li>
                    <li><a href="/pricing.php" class="hover:text-voiplay-primary transition-colors">Tariflar</a></li>
                    <li><a href="/privacy.php" class="hover:text-voiplay-primary transition-colors">Maxfiylik Siyosati</a></li>
                    <li><a href="/terms.php" class="hover:text-voiplay-primary transition-colors">Foydalanish Shartlari</a></li>
                </ul>
            </div>

            <!-- Newsletter -->
            <div class="md:col-span-2 lg:col-span-1">
                <h3 class="text-lg font-semibold text-white mb-4">Yangiliklardan Xabardor Bo'ling</h3>
                <form class="space-y-3">
                    <input type="email" placeholder="Email manzilingiz" 
                           class="w-full px-4 py-2 bg-gray-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-voiplay-primary">
                    <button type="submit" class="bg-voiplay-primary hover:bg-voiplay-primary-dark text-white px-4 py-2 rounded-lg w-full transition-colors">
                        Obuna Bo'lish
                    </button>
                </form>
            </div>
        </div>

        <div class="border-t border-gray-800 mt-12 pt-8 flex flex-col md:flex-row justify-between items-center">
            <div class="text-sm mb-4 md:mb-0">
                &copy; 2025 VoiPlay.uz. Barcha huquqlar himoyalangan.
            </div>
            <div class="flex space-x-6">
                <a href="#" class="text-sm hover:text-voiplay-primary transition-colors">Cookie Settings</a>
                <a href="#" class="text-sm hover:text-voiplay-primary transition-colors">Privacy Policy</a>
                <a href="#" class="text-sm hover:text-voiplay-primary transition-colors">Terms of Service</a>
            </div>
        </div>
    </div>
</footer>
    <script>
        // Helper function to modify query parameters
        function updateQueryParam(param, value) {
            const url = new URL(window.location.href);
            url.searchParams.set(param, value);
            
            // Reset to page 1 when changing filters
            if (param !== 'page') {
                url.searchParams.set('page', '1');
            }
            
            window.location.href = url.toString();
        }
        
        // Sort select change handler
        document.getElementById('sort-select').addEventListener('change', function() {
            updateQueryParam('sort', this.value);
        });
        
        // Items per page select change handler
        document.getElementById('per-page-select').addEventListener('change', function() {
            updateQueryParam('limit', this.value);
        });
    </script>
</body>
</html>

