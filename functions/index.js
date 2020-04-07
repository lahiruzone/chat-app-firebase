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
                //check readStatus has userId key
                if (readStatus.hasOwnProperty(userId) && userId !== messageData.senderId) {
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
                body += `: ${messageData.text}`;
            } else {
                body += ' sent an image';
            }

            const payload = {
                notification: { title: chatData['name'], body: body }
            }

            const options = {
                priority: 'high',
                timeToLive: 60 * 60 * 24,

            }

            for (const userId in memberInfo) {
                if (userId !== senderId) {
                    const token = memberInfo[userId].token;
                    if (token !== '') {
                        admin.messaging().sendToDevice(token, payload, options);
                    }
                }
            }

        }
    });

exports.onUpdateUser = functions.firestore
    .document('/users/{userId}')
    .onUpdate(async (
        snapshot, context
    ) => {
        const userId = context.params.userId;
        const userData = snapshot.after.data();
        const newToken = userData.token;

        //loop through every chat user in and update token
        return admin
            .firestore()
            .collection('chats')
            .where('memberIds', 'array-contains', userId)
            .orderBy('recentTimeStamp', 'desc')
            .get().then(snapshots =>{
                return snapshots.forEach(chatDoc=>{
                    const chatData = chatDoc.data();
                    const memberInfo = chatData.memberInfo;
                    memberInfo[userId].token = newToken;
                    console
                    chatDoc.ref.update({memberInfo: memberInfo});
                });
            }); 
    });
