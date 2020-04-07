const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.addChatMessage = functions.firestore
    .document('/chats/{chatId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const chatId = context.params.chatId;
        const messageData = snapshot.data();
        const chatRef = admin.firestore().collection('chats').doc(chatId);
        const chatDoc = await chatRef.get();
        const chatData = chatDoc.data();
        if (chatDoc.exists) {
            //readStuts is Map(userId , bool)
            const readStatus = chatData.readStatus;
            for (let userId in readStatus) {
                if (userId !== messageData.senderId) {
                    readStatus[userId] = false;
                }
            }

            chatRef.update({
                recentMessage: messageData.text,
                recentSender: messageData.senderId,
                recentTimeStamp: messageData.timestamp,
                readStatus: readStatus,
            });

            // Push Notifications
            const memberInfo = chatData.memberInfo;
            const senderId = chatData.recentSender;

            let body = memberInfo[senderId].name;
            if (messageData.text !== null) {
                body += ' : ${messageData.text}';
            } else {
                body += ' sent an image';
            }

            const payload = {
                notification: { title: chatData['name'], body: body }
            }

            const options = {
                priority: 'high',
                timeToLive: 60*60*24,

            }

            for (const userId in memberInfo) {
                if (userId !== senderId) {
                    const token = memberInfo[userId].toke;
                    if (token !== '') {
                        console.log('SentAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaaCCCCCCCCCCCCCCCCCc');

                        admin.messaging().sendToDevice(token, payload, options);
                    }
                }
            }

        }
    });
