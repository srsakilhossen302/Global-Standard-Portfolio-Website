require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');

const { Portfolio, Project, Reference, Message, Admin } = require('./models');

const app = express();
const PORT = process.env.PORT || 5000;
const JWT_SECRET = process.env.JWT_SECRET || 'sakil_portfolio_jwt_secret_key_123';
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/portfolio';
const DB_FILE = path.join(__dirname, 'data.json');

app.use(cors());
app.use(express.json({ limit: '50mb' })); // Support base64 image strings
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Connect to MongoDB
mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB database');
    runAutoMigration();
  })
  .catch(err => {
    console.error('MongoDB connection error:', err);
  });

// Automatic migration logic: Reads data.json and seeds MongoDB if empty
async function runAutoMigration() {
  try {
    const portfolioCount = await Portfolio.countDocuments();
    if (portfolioCount > 0) {
      console.log('Database already initialized. Skipping auto-migration.');
      return;
    }

    if (!fs.existsSync(DB_FILE)) {
      console.log('No local data.json file found. Initializing empty portfolio structure.');
      await Portfolio.create({
        profile: {},
        skills: [],
        experience: [],
        education: [],
        aiWorkflow: []
      });
      await Admin.create({
        passwordHash: bcrypt.hashSync('admin123', 10) // default password
      });
      return;
    }

    console.log('Empty database detected. Migrating local data.json to MongoDB...');
    const rawData = fs.readFileSync(DB_FILE, 'utf8');
    const data = JSON.parse(rawData);

    // 1. Seed Portfolio Configuration
    await Portfolio.create({
      profile: data.profile || {},
      skills: data.skills || [],
      experience: data.experience || [],
      education: data.education || [],
      aiWorkflow: data.aiWorkflow || []
    });

    // 2. Seed Projects
    if (Array.isArray(data.projects) && data.projects.length > 0) {
      await Project.insertMany(data.projects);
      console.log(`Migrated ${data.projects.length} projects.`);
    }

    // 3. Seed References
    if (Array.isArray(data.references) && data.references.length > 0) {
      await Reference.insertMany(data.references);
      console.log(`Migrated ${data.references.length} references.`);
    }

    // 4. Seed Messages
    if (Array.isArray(data.messages) && data.messages.length > 0) {
      await Message.insertMany(data.messages);
      console.log(`Migrated ${data.messages.length} messages.`);
    }

    // 5. Seed Admin Credentials
    const adminData = data.admin || {};
    const passHash = adminData.passwordHash || bcrypt.hashSync('admin123', 10);
    await Admin.create({ passwordHash: passHash });

    console.log('Migration completed successfully!');
  } catch (error) {
    console.error('Error migrating database:', error);
  }
}

// Middleware: Authenticate Admin JWT
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
}

// --- PUBLIC ROUTES ---

// 1. Fetch entire public portfolio details
app.get('/api/portfolio', async (req, res) => {
  try {
    const portfolioDoc = await Portfolio.findOne() || { profile: {}, skills: [], experience: [], education: [], aiWorkflow: [] };
    const projects = await Project.find().sort({ createdAt: 1 });
    const references = await Reference.find().sort({ createdAt: 1 });

    const publicData = {
      profile: portfolioDoc.profile || {},
      projects: projects || [],
      skills: portfolioDoc.skills || [],
      experience: portfolioDoc.experience || [],
      education: portfolioDoc.education || [],
      aiWorkflow: portfolioDoc.aiWorkflow || [],
      references: references || []
    };
    res.json(publicData);
  } catch (error) {
    console.error('Error fetching portfolio:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 2. Submit Contact Message
app.post('/api/contact', async (req, res) => {
  try {
    const { name, email, message } = req.body;
    if (!name || !email || !message) {
      return res.status(400).json({ error: 'Name, email, and message are required' });
    }

    const newMessage = new Message({
      id: 'msg-' + Date.now(),
      name,
      email,
      message,
      timestamp: new Date().toISOString()
    });

    await newMessage.save();
    res.status(201).json({ success: true, message: 'Message sent successfully' });
  } catch (error) {
    console.error('Error saving message:', error);
    res.status(500).json({ error: 'Failed to save message' });
  }
});

// 3. Admin Authentication Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { password } = req.body;
    if (!password) {
      return res.status(400).json({ error: 'Password is required' });
    }

    let admin = await Admin.findOne();
    if (!admin) {
      // Fallback: Create default admin if not found
      const defaultHash = bcrypt.hashSync('admin123', 10);
      admin = await Admin.create({ passwordHash: defaultHash });
    }

    const isMatch = bcrypt.compareSync(password, admin.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Incorrect password' });
    }

    // Password matched, generate JWT token
    const token = jwt.sign({ role: 'admin' }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, success: true });
  } catch (error) {
    console.error('Error logging in:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// --- ADMIN PROTECTED ROUTES ---

// 4. Update Profile Info
app.put('/api/portfolio/profile', authenticateToken, async (req, res) => {
  try {
    let portfolioDoc = await Portfolio.findOne();
    if (!portfolioDoc) {
      portfolioDoc = new Portfolio();
    }
    portfolioDoc.profile = { ...portfolioDoc.profile, ...req.body };
    await portfolioDoc.save();

    res.json({ success: true, message: 'Profile updated successfully', profile: portfolioDoc.profile });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// 5. Add Project
app.post('/api/projects', authenticateToken, async (req, res) => {
  try {
    const newProject = new Project({
      id: 'proj-' + Date.now(),
      title: req.body.title || 'New Project',
      description: req.body.description || '',
      image: req.body.image || '',
      playStoreUrl: req.body.playStoreUrl || '',
      appStoreUrl: req.body.appStoreUrl || '',
      githubUrl: req.body.githubUrl || '',
      tags: Array.isArray(req.body.tags) ? req.body.tags : [],
      features: Array.isArray(req.body.features) ? req.body.features : []
    });

    await newProject.save();
    res.status(201).json({ success: true, project: newProject });
  } catch (error) {
    console.error('Error adding project:', error);
    res.status(500).json({ error: 'Failed to add project' });
  }
});

// 6. Update Project
app.put('/api/projects/:id', authenticateToken, async (req, res) => {
  try {
    const projectId = req.params.id;
    const project = await Project.findOne({ id: projectId });
    
    if (!project) {
      return res.status(404).json({ error: 'Project not found' });
    }

    project.title = req.body.title !== undefined ? req.body.title : project.title;
    project.description = req.body.description !== undefined ? req.body.description : project.description;
    project.image = req.body.image !== undefined ? req.body.image : project.image;
    project.playStoreUrl = req.body.playStoreUrl !== undefined ? req.body.playStoreUrl : project.playStoreUrl;
    project.appStoreUrl = req.body.appStoreUrl !== undefined ? req.body.appStoreUrl : project.appStoreUrl;
    project.githubUrl = req.body.githubUrl !== undefined ? req.body.githubUrl : project.githubUrl;
    project.tags = Array.isArray(req.body.tags) ? req.body.tags : project.tags;
    project.features = Array.isArray(req.body.features) ? req.body.features : project.features;

    await project.save();
    res.json({ success: true, project });
  } catch (error) {
    console.error('Error updating project:', error);
    res.status(500).json({ error: 'Failed to update project' });
  }
});

// 7. Delete Project
app.delete('/api/projects/:id', authenticateToken, async (req, res) => {
  try {
    const projectId = req.params.id;
    const result = await Project.deleteOne({ id: projectId });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Project not found' });
    }

    res.json({ success: true, message: 'Project deleted successfully' });
  } catch (error) {
    console.error('Error deleting project:', error);
    res.status(500).json({ error: 'Failed to delete project' });
  }
});

// 8. Add Reference/Review
app.post('/api/references', authenticateToken, async (req, res) => {
  try {
    const newRef = new Reference({
      id: 'ref-' + Date.now(),
      clientName: req.body.clientName || 'Anonymous',
      clientCompany: req.body.clientCompany || '',
      clientComment: req.body.clientComment || '',
      clientRating: parseFloat(req.body.clientRating) || 5.0,
      clientImage: req.body.clientImage || '',
      reviewImage: req.body.reviewImage || ''
    });

    await newRef.save();
    res.status(201).json({ success: true, reference: newRef });
  } catch (error) {
    console.error('Error adding reference:', error);
    res.status(500).json({ error: 'Failed to add reference' });
  }
});

// 9. Update Reference/Review
app.put('/api/references/:id', authenticateToken, async (req, res) => {
  try {
    const refId = req.params.id;
    const ref = await Reference.findOne({ id: refId });
    
    if (!ref) {
      return res.status(404).json({ error: 'Reference not found' });
    }

    ref.clientName = req.body.clientName !== undefined ? req.body.clientName : ref.clientName;
    ref.clientCompany = req.body.clientCompany !== undefined ? req.body.clientCompany : ref.clientCompany;
    ref.clientComment = req.body.clientComment !== undefined ? req.body.clientComment : ref.clientComment;
    ref.clientRating = req.body.clientRating !== undefined ? parseFloat(req.body.clientRating) : ref.clientRating;
    ref.clientImage = req.body.clientImage !== undefined ? req.body.clientImage : ref.clientImage;
    ref.reviewImage = req.body.reviewImage !== undefined ? req.body.reviewImage : ref.reviewImage;

    await ref.save();
    res.json({ success: true, reference: ref });
  } catch (error) {
    console.error('Error updating reference:', error);
    res.status(500).json({ error: 'Failed to update reference' });
  }
});

// 10. Delete Reference/Review
app.delete('/api/references/:id', authenticateToken, async (req, res) => {
  try {
    const refId = req.params.id;
    const result = await Reference.deleteOne({ id: refId });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Reference not found' });
    }

    res.json({ success: true, message: 'Reference deleted successfully' });
  } catch (error) {
    console.error('Error deleting reference:', error);
    res.status(500).json({ error: 'Failed to delete reference' });
  }
});

// 11. Update Skills List
app.put('/api/skills', authenticateToken, async (req, res) => {
  try {
    if (!Array.isArray(req.body.skills)) {
      return res.status(400).json({ error: 'Invalid skills payload' });
    }

    let portfolioDoc = await Portfolio.findOne();
    if (!portfolioDoc) {
      portfolioDoc = new Portfolio();
    }
    portfolioDoc.skills = req.body.skills;
    await portfolioDoc.save();

    res.json({ success: true, skills: portfolioDoc.skills });
  } catch (error) {
    console.error('Error updating skills:', error);
    res.status(500).json({ error: 'Failed to update skills' });
  }
});

// 12. Update Experiences List
app.put('/api/experience', authenticateToken, async (req, res) => {
  try {
    if (!Array.isArray(req.body.experience)) {
      return res.status(400).json({ error: 'Invalid experience payload' });
    }

    let portfolioDoc = await Portfolio.findOne();
    if (!portfolioDoc) {
      portfolioDoc = new Portfolio();
    }
    portfolioDoc.experience = req.body.experience;
    await portfolioDoc.save();

    res.json({ success: true, experience: portfolioDoc.experience });
  } catch (error) {
    console.error('Error updating experience:', error);
    res.status(500).json({ error: 'Failed to update experience' });
  }
});

// 12a. Update Education List
app.put('/api/education', authenticateToken, async (req, res) => {
  try {
    if (!Array.isArray(req.body.education)) {
      return res.status(400).json({ error: 'Invalid education payload' });
    }

    let portfolioDoc = await Portfolio.findOne();
    if (!portfolioDoc) {
      portfolioDoc = new Portfolio();
    }
    portfolioDoc.education = req.body.education;
    await portfolioDoc.save();

    res.json({ success: true, education: portfolioDoc.education });
  } catch (error) {
    console.error('Error updating education:', error);
    res.status(500).json({ error: 'Failed to update education' });
  }
});

// 12b. Update AI Workflow List
app.put('/api/ai', authenticateToken, async (req, res) => {
  try {
    if (!Array.isArray(req.body.aiWorkflow)) {
      return res.status(400).json({ error: 'Invalid AI workflow payload' });
    }

    let portfolioDoc = await Portfolio.findOne();
    if (!portfolioDoc) {
      portfolioDoc = new Portfolio();
    }
    portfolioDoc.aiWorkflow = req.body.aiWorkflow;
    await portfolioDoc.save();

    res.json({ success: true, aiWorkflow: portfolioDoc.aiWorkflow });
  } catch (error) {
    console.error('Error updating AI workflow:', error);
    res.status(500).json({ error: 'Failed to update AI workflow' });
  }
});

// 13. Get all Inbox Messages (Admin Only)
app.get('/api/contact', authenticateToken, async (req, res) => {
  try {
    const messages = await Message.find().sort({ createdAt: -1 });
    res.json(messages);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// 14. Delete single Inbox Message
app.delete('/api/contact/:id', authenticateToken, async (req, res) => {
  try {
    const messageId = req.params.id;
    const result = await Message.deleteOne({ id: messageId });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Message not found' });
    }

    res.json({ success: true, message: 'Message deleted successfully' });
  } catch (error) {
    console.error('Error deleting message:', error);
    res.status(500).json({ error: 'Failed to delete message' });
  }
});

// Start Express Server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
