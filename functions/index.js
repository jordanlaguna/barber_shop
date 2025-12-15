const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationToBarbers = functions.https.onCall(
    async (data, context) => {
      const {title, message} = data;

      if (!title || !message) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Title and message are required",
        );
      }

      try {
        const snapshot = await admin
            .firestore()
            .collection("user")
            .where("role", "==", "barber")
            .get();

        if (snapshot.empty) {
          return {success: true, sent: 0};
        }

        const tokens = snapshot.docs
            .map((doc) => doc.data().fcmToken)
            .filter((token) => token);

        const notifications = tokens.map((token) => ({
          token,
          notification: {
            title,
            body: message,
          },
        }));

        const responses = await Promise.all(
            notifications.map((payload) => admin.messaging().send(payload)),
        );

        return {
          success: true,
          sent: responses.length,
        };
      } catch (error) {
        console.error("Error sending notifications", error);
        throw new functions.https.HttpsError(
            "internal",
            "Failed to send notifications",
        );
      }
    },
);
