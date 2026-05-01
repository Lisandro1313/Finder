const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions, logger } = require('firebase-functions/v2');
const admin = require('firebase-admin');
const { google } = require('googleapis');

admin.initializeApp();
setGlobalOptions({ maxInstances: 10, region: 'us-central1' });

const db = admin.firestore();

const PRODUCT_IDS = {
  PLUS: 'finder_plus_monthly',
  BOOST: 'finder_boost_pack',
  SUPERLIKE: 'finder_superlike_pack',
};

function isSubscriptionProduct(productId) {
  return productId === PRODUCT_IDS.PLUS;
}

async function verifyPlayPurchase({ productId, purchaseToken }) {
  const packageName = process.env.ANDROID_PACKAGE_NAME;
  if (!packageName) {
    return { ok: false, reason: 'missing_ANDROID_PACKAGE_NAME' };
  }

  if (!purchaseToken) {
    return { ok: false, reason: 'missing_purchase_token' };
  }

  const auth = new google.auth.GoogleAuth({
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });
  const authClient = await auth.getClient();
  const androidpublisher = google.androidpublisher({ version: 'v3', auth: authClient });

  try {
    if (isSubscriptionProduct(productId)) {
      const res = await androidpublisher.purchases.subscriptionsv2.get({
        packageName,
        token: purchaseToken,
      });
      const state = res.data.subscriptionState;
      const ok = state === 'SUBSCRIPTION_STATE_ACTIVE' || state === 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD';
      return { ok, reason: ok ? undefined : `subscription_state_${state}` };
    }

    const res = await androidpublisher.purchases.products.get({
      packageName,
      productId,
      token: purchaseToken,
    });

    const purchaseState = res.data.purchaseState;
    const ok = purchaseState === 0;
    return { ok, reason: ok ? undefined : `product_purchase_state_${purchaseState}` };
  } catch (error) {
    logger.error('Play purchase verification error', { productId, message: error.message });
    return { ok: false, reason: 'verification_exception' };
  }
}

async function applyEntitlement({ userId, productId, eventRef }) {
  const userRef = db.collection('users').doc(userId);

  await db.runTransaction(async (tx) => {
    const userSnap = await tx.get(userRef);
    const data = userSnap.data() || {};

    let plusActive = data.plusActive === true;
    let boostCount = Number(data.boostCount || 0);
    let superLikeCount = Number(data.superLikeCount || 0);

    if (productId === PRODUCT_IDS.PLUS) plusActive = true;
    if (productId === PRODUCT_IDS.BOOST) boostCount += 5;
    if (productId === PRODUCT_IDS.SUPERLIKE) superLikeCount += 10;

    tx.set(
      userRef,
      {
        plusActive,
        boostCount,
        superLikeCount,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    tx.set(
      eventRef,
      {
        status: 'applied',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });
}

async function fetchPushTokens(userIds) {
  const refs = userIds.map((id) => db.collection('profiles').doc(id).get());
  const snaps = await Promise.all(refs);

  return snaps
    .map((snap) => snap.data()?.pushToken)
    .filter((token) => typeof token === 'string' && token.length > 0);
}

exports.onPurchaseEventCreated = onDocumentCreated('purchase_events/{eventId}', async (event) => {
  const snap = event.data;
  if (!snap) return;

  const payload = snap.data() || {};
  const userId = payload.userId;
  const productId = payload.productId;
  const purchaseToken = payload.verificationData;

  if (!userId || !productId) {
    await snap.ref.set(
      {
        status: 'rejected',
        reason: 'missing_user_or_product',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return;
  }

  const trustClientPurchases = process.env.TRUST_CLIENT_PURCHASES === 'true';
  if (trustClientPurchases) {
    await applyEntitlement({ userId, productId, eventRef: snap.ref });
    return;
  }

  const verification = await verifyPlayPurchase({ productId, purchaseToken });
  if (!verification.ok) {
    await snap.ref.set(
      {
        status: 'rejected',
        reason: verification.reason || 'verification_failed',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return;
  }

  await applyEntitlement({ userId, productId, eventRef: snap.ref });
});

exports.onMatchCreatedPush = onDocumentCreated('matches/{matchId}', async (event) => {
  const snap = event.data;
  if (!snap) return;

  const data = snap.data() || {};
  const users = Array.isArray(data.users) ? data.users : [];
  if (users.length < 2) return;

  const tokens = await fetchPushTokens(users);
  if (tokens.length === 0) return;

  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {
      title: 'Nuevo match en Finder',
      body: 'Se hizo match. Abre Finder y rompe el hielo.',
    },
    data: {
      type: 'match_created',
      matchId: snap.id,
    },
  });
});

exports.onMessageCreatedPush = onDocumentCreated('chats/{matchId}/messages/{messageId}', async (event) => {
  const snap = event.data;
  if (!snap) return;

  const { matchId } = event.params;
  const message = snap.data() || {};
  const senderId = message.senderId;
  const text = String(message.text || 'Nuevo mensaje');

  if (!senderId) return;

  const matchSnap = await db.collection('matches').doc(matchId).get();
  if (!matchSnap.exists) return;

  const users = (matchSnap.data()?.users || []).filter((id) => id !== senderId);
  if (!Array.isArray(users) || users.length === 0) return;

  const tokens = await fetchPushTokens(users);
  if (tokens.length === 0) return;

  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {
      title: 'Nuevo mensaje en Finder',
      body: text,
    },
    data: {
      type: 'message_created',
      matchId,
    },
  });
});
