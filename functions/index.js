const admin = require("firebase-admin");
const functions = require("firebase-functions");

admin.initializeApp();

const messaging = admin.messaging();

exports.notifySubscribers = functions.https.onCall(async (data, _) => {
    try {
        console.log(data.targetDevices);
        await messaging.sendToDevice(data.targetDevices, {
            notification: {
                title: data.messageTitle,
                body: data.messageBody,
            },
            data: {
                caller: "Demo",
                link: "https://decoder.app.100ms.live/preview/xno-jwn-phi" //Demo link for testing purpose
            }
        });

        return true;
    } catch (ex) {
        console.log(ex);
        return false;
    }
});