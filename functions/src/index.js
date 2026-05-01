const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions, logger } = require('firebase-functions/v2');
const admin = require('firebase-admin');

admin.initializeApp();
setGlobalOptions({ maxInstances: 10, region: 'us-central1' });

const db = admin.firestore();

const PRODUCT_IDS = {
  PLUS: 'finder_plus_monthly',
  BOOST: 'finder_boost_pack',
  SUPERLIKE: 'finder_superlike_pack',
};

exports.onPurchaseEventCreated = onDocumentCreated('purchase_events/{eventId}', async (event) => {
  const snap = event.data;
  if (!snap) return;

  const payload = snap.data() || {};
  const userId = payload.userId;
  const productId = payload.productId;

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
  if (!trustClientPurchases) {
    await snap.ref.set(
      {
        status: 'pending_verification',
        reason: 'server_verification_not_configured',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    logger.warn('Purchase queued without verification config', { userId, productId });
    return;
  }

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
      snap.ref,
      {
        status: 'applied',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });
});
