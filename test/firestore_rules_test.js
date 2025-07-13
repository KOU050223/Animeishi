const { assertFails, assertSucceeds, initializeTestEnvironment } = require('@firebase/rules-unit-testing');

describe('Firestore Security Rules', () => {
  let testEnv;

  beforeAll(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: 'animeishi-test',
      firestore: {
        rules: require('fs').readFileSync('../firestore.rules', 'utf8'),
      },
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  // 未認証ユーザーのテスト
  describe('未認証ユーザー', () => {
    test('titlesコレクションにアクセスできない', async () => {
      const unauthedDb = testEnv.unauthenticatedContext().firestore();
      
      await assertFails(
        unauthedDb.collection('titles').doc('test').get()
      );
    });

    test('usersコレクションにアクセスできない', async () => {
      const unauthedDb = testEnv.unauthenticatedContext().firestore();
      
      await assertFails(
        unauthedDb.collection('users').doc('testUser').get()
      );
    });
  });

  // 認証済みユーザーのテスト
  describe('認証済みユーザー', () => {
    const userId = 'testUser123';
    const otherUserId = 'otherUser456';

    test('titlesコレクションを読み取りできる', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: userId }).firestore();
      
      await assertSucceeds(
        authedDb.collection('titles').doc('anime1').get()
      );
    });

    test('titlesコレクションに書き込みできない', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: userId }).firestore();
      
      await assertFails(
        authedDb.collection('titles').doc('anime1').set({ title: 'Test Anime' })
      );
    });

    test('自分のユーザードキュメントにアクセスできる', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: userId }).firestore();
      
      await assertSucceeds(
        authedDb.collection('users').doc(userId).get()
      );
      
      await assertSucceeds(
        authedDb.collection('users').doc(userId).set({ userName: 'Test User' })
      );
    });

    test('他人のユーザードキュメントにアクセスできない', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: userId }).firestore();
      
      await assertFails(
        authedDb.collection('users').doc(otherUserId).get()
      );
      
      await assertFails(
        authedDb.collection('users').doc(otherUserId).set({ userName: 'Hacker' })
      );
    });

    test('自分のサブコレクションにアクセスできる', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: userId }).firestore();
      
      // selectedAnimeサブコレクション
      await assertSucceeds(
        authedDb.collection('users').doc(userId).collection('selectedAnime').doc('anime1').get()
      );
      
      await assertSucceeds(
        authedDb.collection('users').doc(userId).collection('selectedAnime').doc('anime1').set({ 
          addedAt: new Date() 
        })
      );

      // meishiesサブコレクション
      await assertSucceeds(
        authedDb.collection('users').doc(userId).collection('meishies').doc('friend1').get()
      );
    });

    test('他人のサブコレクションにアクセスできない', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: userId }).firestore();
      
      await assertFails(
        authedDb.collection('users').doc(otherUserId).collection('selectedAnime').doc('anime1').get()
      );
      
      await assertFails(
        authedDb.collection('users').doc(otherUserId).collection('meishies').doc('friend1').set({ 
          data: 'malicious' 
        })
      );
    });
  });

  // パフォーマンステスト
  describe('パフォーマンステスト', () => {
    test('大量のドキュメント読み取り制限', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: 'testUser' }).firestore();
      
      // 通常のクエリは成功
      await assertSucceeds(
        authedDb.collection('titles').limit(50).get()
      );
      
      // 過度に大きなクエリは制限されるべき（実装に依存）
    });
  });

  // エラーケースのテスト
  describe('不正アクセステスト', () => {
    test('存在しないユーザーIDでのアクセス', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: 'invalidUser' }).firestore();
      
      // 自分のIDであっても、不正な形式の場合は制限
      await assertFails(
        authedDb.collection('users').doc('../../admin').get()
      );
    });

    test('SQLインジェクション的なクエリ', async () => {
      const authedDb = testEnv.authenticatedContext({ uid: 'testUser' }).firestore();
      
      await assertFails(
        authedDb.collection('users').doc("'; DROP TABLE users; --").get()
      );
    });
  });
});