require('dotenv').config();
const mongoose = require('mongoose');
const { Reference } = require('./models');

const MONGODB_URI = process.env.MONGODB_URI;

async function check() {
  await mongoose.connect(MONGODB_URI);
  const references = await Reference.find();
  console.log('References count:', references.length);
  references.forEach(ref => {
    console.log(`- ID: ${ref.id}, Name: ${ref.clientName}`);
    console.log(`  clientImage length: ${ref.clientImage ? ref.clientImage.length : 0}`);
    console.log(`  reviewImage length: ${ref.reviewImage ? ref.reviewImage.length : 0}`);
    if (ref.reviewImage) {
      console.log(`  reviewImage prefix: ${ref.reviewImage.substring(0, 100)}`);
    }
  });
  await mongoose.disconnect();
}

check();
