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
                if (treradStstus.hasOwnProperty(userId) && userId !== messageData.senderId) {
                    console.log('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaaCCCCCCCCCCCCCCCCCc');
                    readStatus[userId] = false;
                }
                chatRef.update({
                    recentMessage: messageData.text,
                    recentSender: messageData.senderId,
                    recentTimeStamp: messageData.timestamp,
                    readStatus: readStatus,
                });
            }

        }
    });