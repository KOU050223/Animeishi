// アプリケーションのメインロジック
class AnimeViewer {
  constructor() {
    this.currentUserId = null;
    this.init();
  }

  async init() {
    // URLからユーザーIDを取得
    this.shortId = this.getUserIdFromUrl();
    
    if (shortId) {
        this.currentUserId = await this.getUserIdFromShortId(shortId);
    }

    if (this.currentUserId) {
      await this.loadUserProfile();
      await this.loadUserAnimeList();
    } else {
      this.showError('ユーザーIDが見つかりません');
    }
  }

  getUserIdFromUrl() {
    const path = window.location.pathname;
    const match = path.match(/\/user\/([^\/]+)/);
    return match ? match[1] : null;
  }

  async getUserIdFromShortId(shortId) {
    try {
      // Firestoreで短縮IDに一致するユーザーを検索
      const usersSnapshot = await db.collection('users').get();
      
      for (const doc of usersSnapshot.docs) {
        const uid = doc.id;
        if (uid.startsWith(shortId)) {
          return uid;
        }
      }
      return null;
    } catch (error) {
      console.error('ユーザーID取得エラー:', error);
      return null;
    }
  }

  async loadUserProfile() {
    try {
      const userDoc = await db.collection('users').doc(this.currentUserId).get();
      
      if (userDoc.exists) {
        const userData = userDoc.data();
        this.displayUserProfile(userData);
      } else {
        this.showError('ユーザーが見つかりません');
      }
    } catch (error) {
      console.error('プロフィール読み込みエラー:', error);
      this.showError('プロフィールの読み込みに失敗しました');
    }
  }

  async loadUserAnimeList() {
    try {
      const animeSnapshot = await db
        .collection('users')
        .doc(this.currentUserId)
        .collection('selectedAnime')
        .orderBy('firstyear', 'desc')
        .orderBy('firstmonth', 'desc')
        .get();

      const animeList = [];
      animeSnapshot.forEach(doc => {
        animeList.push({ id: doc.id, ...doc.data() });
      });

      this.displayAnimeList(animeList);
    } catch (error) {
      console.error('アニメリスト読み込みエラー:', error);
      this.showError('アニメリストの読み込みに失敗しました');
    }
  }

  displayUserProfile(userData) {
    const profileSection = document.getElementById('user-profile');
    if (profileSection) {
      profileSection.innerHTML = `
        <div class="profile-card">
          <div class="profile-avatar">
            <img src="${userData.profileImageUrl || '/assets/images/default-avatar.png'}" 
                 alt="プロフィール画像" 
                 onerror="this.src='/assets/images/default-avatar.png'">
          </div>
          <div class="profile-info">
            <h2>${userData.username || '名前未設定'}</h2>
            <p class="user-email">${userData.email || ''}</p>
            <div class="user-stats">
              <span class="stat-item">
                <strong>${userData.selectedGenres ? userData.selectedGenres.length : 0}</strong> ジャンル
              </span>
            </div>
          </div>
        </div>
      `;
    }
  }

  displayAnimeList(animeList) {
    const animeSection = document.getElementById('anime-list');
    if (animeSection) {
      if (animeList.length === 0) {
        animeSection.innerHTML = `
          <div class="empty-state">
            <div class="empty-icon">📺</div>
            <h3>まだ視聴済みアニメがありません</h3>
            <p>アニメを視聴して記録してみましょう！</p>
          </div>
        `;
        return;
      }

      const animeCards = animeList.map(anime => this.createAnimeCard(anime)).join('');
      animeSection.innerHTML = `
        <div class="anime-grid">
          ${animeCards}
        </div>
      `;
    }
  }

  createAnimeCard(anime) {
    const year = anime.firstyear || '不明';
    const month = anime.firstmonth || '';
    const airDate = month ? `${year}年${month}月` : `${year}年`;
    
    return `
      <div class="anime-card">
        <div class="anime-image">
          <img src="${anime.imageUrl || '/assets/images/default-anime.png'}" 
               alt="${anime.title}" 
               onerror="this.src='/assets/images/default-anime.png'">
        </div>
        <div class="anime-info">
          <h3 class="anime-title">${anime.title || 'タイトル不明'}</h3>
          <p class="anime-date">${airDate}</p>
          ${anime.comment ? `<p class="anime-comment">${anime.comment}</p>` : ''}
        </div>
      </div>
    `;
  }

  showError(message) {
    const mainContent = document.querySelector('.main-content');
    if (mainContent) {
      mainContent.innerHTML = `
        <div class="error-page">
          <div class="error-content">
            <div class="error-icon">⚠️</div>
            <h2>エラーが発生しました</h2>
            <p>${message}</p>
            <button onclick="window.location.href='/'">ホームに戻る</button>
          </div>
        </div>
      `;
    }
  }
}

// ページ読み込み完了時にアプリケーションを初期化
document.addEventListener('DOMContentLoaded', () => {
  new AnimeViewer();
});
