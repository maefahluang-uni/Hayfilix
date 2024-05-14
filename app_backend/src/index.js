require('dotenv').config();

const express = require('express');
const axios = require('axios');
const cors = require('cors');
const helmet = require('helmet');
const functions = require('firebase-functions');
const multer = require('multer');
const lodash = require('lodash');
const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet());

const firebaseConfig = require('../firebase-config.json');
const SHARE_EARN_LIMIT = 10; // 10 USD
const PORT = 3000; // process.env.PORT || 3000;
const MSG = function (message, option) {
  let object = {
    timestamp: Date.now(),
    message: message,
    ...option
  };
  return object;
};
app.get('/version', async (req, res) => {
  res.send({ version: 1 })
})

//////////////////////////////
// Firebase (Realtime Database) Init
//////////////////////////////
const admin = require('firebase-admin');
const serviceAccount = require('../firebase-service-account.json');
const { async } = require('@firebase/util');
const { error, profile, Console } = require('console');
const { throws } = require('assert');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://mini-e9d02-default-rtdb.firebaseio.com",
});
const db = admin.database();

//////////////////////////////
// Firebase (Storage) Init, (Store File, Image, ...)
//////////////////////////////
const { Storage } = require('@google-cloud/storage');
const storage = new Storage({
  projectId: firebaseConfig.appId,
  keyFilename: 'firebase-service-account.json',
});
const storageBucket = storage.bucket("gs://mini-e9d02.appspot.com");
const upload = multer({ storage: multer.memoryStorage() });
function getImageExtensionFromBase64(base64String) {
  // Remove the data URL prefix (e.g., 'data:image/png;base64,')
  const base64WithoutPrefix = base64String.replace(/^data:image\/[a-zA-Z]+;base64,/, '');
  // Decode the base64 string into a Uint8Array
  const binaryString = atob(base64WithoutPrefix);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
  }
  // Determine the file extension based on the file's magic number (initial bytes)
  let extension = null;
  if (bytes[0] === 0xFF && bytes[1] === 0xD8) {
      extension = 'jpg'; // JPEG image
  } else if (bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4E && bytes[3] === 0x47) {
      extension = 'png'; // PNG image
  } else if (bytes[0] === 0x47 && bytes[1] === 0x49 && bytes[2] === 0x46 && bytes[3] === 0x38) {
      extension = 'gif'; // GIF image
  } else if (bytes[0] === 0x52 && bytes[1] === 0x49 && bytes[2] === 0x46 && bytes[3] === 0x46 &&
             bytes[8] === 0x57 && bytes[9] === 0x45 && bytes[10] === 0x42 && bytes[11] === 0x50) {
      extension = 'webp'; // WEBP image
  } else if (bytes[0] === 0x00 && bytes[1] === 0x00 && bytes[2] === 0x01 && bytes[3] === 0x00) {
      extension = 'ico'; // ICO image
  }
  return extension;
}

//////////////////////////////
// Auth Init
//////////////////////////////
const requestProfile = async (email, password) => {
  try {
    const response = await axios.post(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${firebaseConfig.apiKey}`,
      {
        email: email,
        password: password,
        returnSecureToken: true,
      }
    );
    let user = response.data;
    let user_data = await User_STORE.child(user.localId).get();
    let profile = {
      ...user, // from firestore Authentication
      "data": {
        ...user_data.val(), // from firestore Realtime Database
      }
    };
    return profile
  } catch (e) {}
  return undefined
}
function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}




//////////////////////////////
// User system
//////////////////////////////
// /* Use in flutter
//   // login
//   // logout
//   // forgot-email
// */
const User_STORE = db.ref('user_store');
app.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;
    const response = await axios.post(
      `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${firebaseConfig.apiKey}`,
      {
        email: email,
        password: password,
        returnSecureToken: true
      }
    );
    // Create user data in Realtime Database
    const localId = response.data.localId;
    await User_STORE.child(localId).set({
      display_name: email,
      // profile_image: "",
    })
    ////////////////////////////////////////////
    res.status(201).send(MSG('Profile created successfully.', { localId: localId }));
  } catch (e) {
    try {
      let error = e.response.data.error;
      res.status(error.code).send(MSG(error.message));
    } catch (err) {
      res.status(400).send(MSG(err.toString()));
    }
  }
});
app.post('/profile', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await requestProfile(email, password);
    let userData = await User_STORE.child(user.localId).get();
    let profile = {
      ...user, // from firestore Authentication
      "data": {
        ...userData.val(), // from firestore Realtime Database
      }
    };
    res.status(200).send(profile);
  } catch (e) {
    res.status(400).send(MSG(e.toString()));
  }
});
app.get('/get-fav', async (req, res) => {
  try {
    const { 
      email, password,
    } = req.query;
    const user = await requestProfile(email, password);
    res.status(200).send((await User_STORE.child(user.localId).child("my_fav").get()).toJSON());
  } catch (e) {
    res.status(400).send(MSG(e.toString()));
  }
});
app.post('/set-fav', async (req, res) => {
  try {
    const { 
      email, password,
      tmdbid, tmdbtype, tmdbname, tmdbrating
    } = req.body;
    const user = await requestProfile(email, password);
    await User_STORE.child(user.localId).child("my_fav").child(tmdbid).update({
      tmdbtype,
      tmdbname,
      tmdbrating,
    });
    res.sendStatus(200);
  } catch (e) {
    res.status(400).send(MSG(e.toString()));
  }
});
app.delete('/delete-fav', async (req, res) => {
  try {
    const { 
      email, password,
      tmdbid, tmdbtype, tmdbname, tmdbrating
    } = req.body;
    const user = await requestProfile(email, password);
    await User_STORE.child(user.localId).child("my_fav").child(tmdbid).remove();
    res.sendStatus(200);
  } catch (e) {
    res.status(400).send(MSG(e.toString()));
  }
});
// app.post('/edit-profile-image', async (req, res) => {
//   try {
//     const { email, password, image } = req.body;
//     const user = await requestProfile(email, password);
//     let IMAGE_URL = null;
//     try {
//       const imageBuffer = Buffer.from(image, 'base64');
//       const fileExtension = getImageExtensionFromBase64(image);
//       if (fileExtension) {
//         // img
//         if (image) {
//           const fileName = `${user.localId}-${Date.now()}.${fileExtension}`;
//           const file = storageBucket.file(fileName);
//           await file.save(imageBuffer);
//           let image_signed_url = await file.getSignedUrl({
//             action: 'read',
//             expires: '01-01-2030', // Set expiration date as needed
//           }).then(urls => urls[0]);
//           IMAGE_URL = image_signed_url;
//         }
//       } else {
//         throw new Error('Unable to determine file type.');
//       }
//     } catch(e) {
//       res.status(400).send(MSG(e.toString()));
//     }
//     await User_STORE.child(user.localId).update({
//       profile_image: IMAGE_URL
//     });
//     res.status(200).send(MSG('Profile image set successfully.'));
//   } catch (e) {
//     res.status(500).send(MSG(e.toString()));
//   }
// });


//////////////////////////////
// Advertise system
//////////////////////////////
const AdvertiseExpireValidator = function(snapshot) {
  snapshot.forEach(function(childSnapshot) {
    var key = childSnapshot.key;
    var data = childSnapshot.val();
    if (typeof(data.ad_expired) == "number") {
      if (Date.now() >= data.ad_expired) {
        Advertise_STORE.child(key).remove();
      }
    } else {
      Advertise_STORE.child(key).remove();
    }
  });
};
const Advertise_STORE = db.ref('advertise_store');
app.get('/get-ad', async (req, res) => {
  try {
    let { amount } = req.query;
    amount = clamp(Number(amount), 1, 20);
    await Advertise_STORE.once('value', AdvertiseExpireValidator);
    let List = (await Advertise_STORE.get()).val();
    List = lodash.shuffle(List).slice(0, amount);
    res.send(List);
  } catch (e) {
    res.status(400).send(MSG(e.toString()));
  }
});
app.post('/post-ad', upload.fields([{name: 'ad_image', maxCount: 1}]), async (req, res) => {
  try {
    let { api_key } = req.query;
    let { ad_link, ad_tag, ad_duration } = req.body;
    if (api_key === process.env.POST_AD_KEY) {
      if (!req.files || !req.files['ad_image']) {
        return res.status(400).send(MSG('No image uploaded.'));
      } 
      const file = req.files['ad_image'][0]; // Assuming only one file is uploaded
      const fileName = Date.now() + '-' + file.originalname;
      const blob = storageBucket.file(fileName);
      await blob.save(file.buffer);
      let image_signed_url = await blob.getSignedUrl({
        action: 'read',
        expires: '01-01-2030',
      }).then(urls => urls[0]);
      await Advertise_STORE.push({
          ad_image: image_signed_url,
          ad_link: ad_link,
          ad_tag: ad_tag,
          ad_expired: Date.now() + (ad_duration * 1000),
        });
      res.status(201).send(MSG('New advertise badge added.'));
    } else {
      res.status(401).send(MSG('Query, api-key is invalid form.'));
    }
  } catch(e) {
    res.status(400).send(MSG(e.toString()));
  }
});

///////////////////////////////////////////////////////////////////////////////////////////////////////

setInterval(async () => {
  await Advertise_STORE.once('value', AdvertiseExpireValidator); 
}, 15 * 1000);

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

//exports.scheduledFunction = functions.pubsub.schedule('every 1 minutes').onRun(AdvertiseExpireValidator);

exports.api = functions.https.onRequest(app)

// npm start (localtest)
// npm run deploy (firebase)

// *If port was already use*
// Taskkill /IM node.exe /F
// npm run deploy (firebase)