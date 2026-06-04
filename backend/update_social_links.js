require('dotenv').config();
const mongoose = require('mongoose');
const { Portfolio } = require('./models');

const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.error('Error: MONGODB_URI is not defined in .env');
  process.exit(1);
}

async function updateDB() {
  try {
    console.log('Connecting to MongoDB Atlas...');
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB database successfully.');

    // Find the first portfolio document
    const portfolio = await Portfolio.findOne();
    if (!portfolio) {
      console.log('No portfolio document found in the database.');
    } else {
      console.log('Found portfolio document. Current profile data:', portfolio.profile);

      // Set default values for new fields
      if (!portfolio.profile.githubUrl) {
        portfolio.profile.githubUrl = 'https://github.com/sakil';
      }
      if (!portfolio.profile.linkedinUrl) {
        portfolio.profile.linkedinUrl = 'https://linkedin.com';
      }

      // Mark modified if using mixed types, or save directly
      portfolio.markModified('profile');
      await portfolio.save();
      console.log('Successfully updated portfolio profile with githubUrl and linkedinUrl.');
      console.log('Updated profile data:', portfolio.profile);
    }
  } catch (err) {
    console.error('Database migration/update failed:', err);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB.');
    process.exit(0);
  }
}

updateDB();
