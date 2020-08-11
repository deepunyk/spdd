const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.myFunction = functions.firestore
  .document('notification/{message}')
  .onCreate((snapshot, context) => {
    return admin.messaging().sendToTopic(snapshot.data().to, {
      notification: {
        title: snapshot.data().title,
        body: snapshot.data().body,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    });
  });