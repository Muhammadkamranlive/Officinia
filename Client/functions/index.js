const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onRequest }         = require("firebase-functions/v2/https");
const admin                 = require("firebase-admin");
const express               = require("express");
const cors                  = require("cors");

const serviceAccount = require("./noreply-officina-firebase-adminsdk-fbsvc-1c6de1f187.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db  = admin.firestore();
const app = express();
app.use(cors());
app.use(express.json());

/* ------------------------------------------------------------------ */
/* 1. AUTO SEND NOTIFICATIONS                                           */
/* ------------------------------------------------------------------ */

exports.autoSendNotifications = onDocumentCreated(
  "Notifications/{notificationId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return null;

    const notification = snap.data();
    if (!notification || notification.isSent) return null;

    const notificationId = event.params.notificationId;
    const userId         = notification.userId;

    try {
      const tokensSnap = await db
        .collection("userTokens")
        .where("userId", "==", userId)
        .get();

      if (tokensSnap.empty) return null;

      const tokens = tokensSnap.docs.map((d) => d.data().token);

      const message = {
        tokens,
        notification: {
          title: notification.title,
          body:  notification.description,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            sound:     "default",
          },
        },
        data: {
          type:           notification.type       || "",
          targetId:       notification.targetId   || "",
          targetType:     notification.targetType || "",
          route:          notification.route      || "",
          notificationId,
        },
      };

      const response = await admin.messaging().sendEachForMulticast(message);

      await Promise.all(
        response.responses.map(async (res, index) => {
          if (!res.success) {
            const badSnap = await db
              .collection("userTokens")
              .where("token", "==", tokens[index])
              .get();
            badSnap.forEach((d) => d.ref.delete());
          }
        })
      );

      await snap.ref.update({
        isSent:    true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (err) {
      console.error("❌ Auto-send failed:", err);
    }

    return null;
  }
);

/* ------------------------------------------------------------------ */
/* 2. CHARGILY WEBHOOK                                                  */
/* Register in Chargily Dashboard → Developers → Webhooks:             */
/*   https://chargilywebhook-qt4xhfxywa-uc.a.run.app/chargily-webhook  */
/* ------------------------------------------------------------------ */

app.post("/chargily-webhook", async (req, res) => {
  console.log("🔔 Chargily webhook received:", req.body);

  try {
    const payload        = req.body;
    const checkoutId     = payload?.data?.id;
    const checkoutType   = payload?.type;
    const amount         = payload?.data?.amount;
    const paymentMethod  = payload?.data?.payment_method || "unknown";
    const checkoutStatus = payload?.data?.status;

    if (!checkoutId) {
      console.log("❌ Missing checkoutId");
      return res.status(400).send("Invalid payload");
    }

    if (checkoutType !== "checkout.paid" && checkoutStatus !== "paid") {
      console.log("⛔ Payment not completed:", checkoutStatus);
      return res.status(200).send("Ignored");
    }

    const snapshot = await db
      .collection("payments")
      .where("checkoutId", "==", checkoutId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      console.log("❌ Payment document not found:", checkoutId);
      return res.status(404).send("Payment not found");
    }

    const paymentDoc   = snapshot.docs[0];
    const paymentRef   = paymentDoc.ref;
    const existingData = paymentDoc.data();

    if (existingData.status === "paid") {
      console.log("⚠️ Already processed:", checkoutId);
      return res.status(200).send("Already processed");
    }

    const now       = admin.firestore.Timestamp.now();
    const expiresAt = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
    );

    await db.runTransaction(async (transaction) => {
      transaction.update(paymentRef, {
        status:        "paid",
        paidAt:        now,
        expiresAt,
        paymentMethod,
        amount,
        updatedAt:     now,
        rawWebhook:    payload,
      });
    });

    // Update recruiter license status
    const userId      = existingData.recruiterId;
    const licenseSnap = await db
      .collection("Recruiters")
      .where("userId", "==", userId)
      .limit(1)
      .get();

    if (!licenseSnap.empty) {
      const licenseRef = licenseSnap.docs[0].ref;
      await db.runTransaction(async (transaction) => {
        transaction.update(licenseRef, {
          licenseStatus:    "Active",
          licenseExpiresAt: expiresAt,
          updatedAt:        now,
        });
      });
    }

    console.log(`✅ Payment updated & license activated: ${checkoutId}`);
    return res.status(200).send("OK");

  } catch (error) {
    console.error("❌ Webhook Error:", error);
    return res.status(500).send("Server Error");
  }
});

exports.chargilyWebhook = onRequest(app);