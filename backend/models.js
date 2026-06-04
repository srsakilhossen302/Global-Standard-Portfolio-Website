const mongoose = require('mongoose');

// Portfolio Schema (stores profile details and lists of skills, experience, education, etc.)
const PortfolioSchema = new mongoose.Schema({
  profile: {
    name: { type: String, default: '' },
    title: { type: String, default: '' },
    tagline: { type: String, default: '' },
    bio: { type: String, default: '' },
    cvUrl: { type: String, default: '' },
    experienceYears: { type: String, default: '' },
    completedProjects: { type: String, default: '' },
    happyClients: { type: String, default: '' },
    developmentPhilosophy: { type: String, default: '' },
    careerGoals: { type: String, default: '' },
    phone: { type: String, default: '' },
    profileImage: { type: String, default: '' }, // Base64 image
    email: { type: String, default: '' },
    location: { type: String, default: '' },
    githubUrl: { type: String, default: '' },
    linkedinUrl: { type: String, default: '' }
  },
  skills: { type: Array, default: [] },
  experience: { type: Array, default: [] },
  education: { type: Array, default: [] },
  aiWorkflow: { type: Array, default: [] }
}, { timestamps: true });

// Project Schema
const ProjectSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  title: { type: String, default: 'New Project' },
  description: { type: String, default: '' },
  image: { type: String, default: '' },
  playStoreUrl: { type: String, default: '' },
  appStoreUrl: { type: String, default: '' },
  githubUrl: { type: String, default: '' },
  tags: { type: [String], default: [] },
  features: { type: [String], default: [] }
}, { timestamps: true });

// Reference Schema
const ReferenceSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  clientName: { type: String, default: 'Anonymous' },
  clientCompany: { type: String, default: '' },
  clientComment: { type: String, default: '' },
  clientRating: { type: Number, default: 5.0 },
  clientImage: { type: String, default: '' },
  reviewImage: { type: String, default: '' }
}, { timestamps: true });

// Message Schema (Contact Inbox Messages)
const MessageSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  email: { type: String, required: true },
  message: { type: String, required: true },
  timestamp: { type: String, default: () => new Date().toISOString() }
}, { timestamps: true });

// Admin Schema (stores only the password hash)
const AdminSchema = new mongoose.Schema({
  passwordHash: { type: String, required: true }
}, { timestamps: true });

module.exports = {
  Portfolio: mongoose.model('Portfolio', PortfolioSchema),
  Project: mongoose.model('Project', ProjectSchema),
  Reference: mongoose.model('Reference', ReferenceSchema),
  Message: mongoose.model('Message', MessageSchema),
  Admin: mongoose.model('Admin', AdminSchema)
};
