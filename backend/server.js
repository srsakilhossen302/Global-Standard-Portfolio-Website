const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
const PORT = process.env.PORT || 5000;
const JWT_SECRET = process.env.JWT_SECRET || 'sakil_portfolio_jwt_secret_key_123';
const DB_FILE = path.join(__dirname, 'data.json');

app.use(cors());
app.use(express.json({ limit: '50mb' })); // Support base64 image strings
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Helper functions for reading/writing DB
function readDB() {
  try {
    if (!fs.existsSync(DB_FILE)) {
      // If DB file doesn't exist, return empty skeleton
      return {
        profile: {},
        projects: [],
        skills: [],
        experience: [],
        education: [],
        references: [],
        admin: {
          passwordHash: bcrypt.hashSync('admin123', 10) // default password
        },
        messages: []
      };
    }
    const rawData = fs.readFileSync(DB_FILE, 'utf8');
    return JSON.parse(rawData);
  } catch (error) {
    console.error('Error reading database file:', error);
    return {};
  }
}

function writeDB(data) {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (error) {
    console.error('Error writing database file:', error);
    return false;
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
app.get('/api/portfolio', (req, res) => {
  const db = readDB();
  // Strip administrative credentials and inbox messages for public view
  const publicData = {
    profile: db.profile || {},
    projects: db.projects || [],
    skills: db.skills || [],
    experience: db.experience || [],
    education: db.education || [],
    aiWorkflow: db.aiWorkflow || [],
    references: db.references || []
  };
  res.json(publicData);
});

// 2. Submit Contact Message
app.post('/api/contact', (req, res) => {
  const { name, email, message } = req.body;
  if (!name || !email || !message) {
    return res.status(400).json({ error: 'Name, email, and message are required' });
  }

  const db = readDB();
  const newMessage = {
    id: 'msg-' + Date.now(),
    name,
    email,
    message,
    timestamp: new Date().toISOString()
  };

  db.messages = db.messages || [];
  db.messages.push(newMessage);
  
  if (writeDB(db)) {
    res.status(201).json({ success: true, message: 'Message sent successfully' });
  } else {
    res.status(500).json({ error: 'Failed to save message' });
  }
});

// 3. Admin Authentication Login
app.post('/api/auth/login', (req, res) => {
  const { password } = req.body;
  if (!password) {
    return res.status(400).json({ error: 'Password is required' });
  }

  const db = readDB();
  const admin = db.admin || {};
  const hash = admin.passwordHash || bcrypt.hashSync('admin123', 10);

  const isMatch = bcrypt.compareSync(password, hash);
  if (!isMatch) {
    return res.status(401).json({ error: 'Incorrect password' });
  }

  // Password matched, generate JWT token
  const token = jwt.sign({ role: 'admin' }, JWT_SECRET, { expiresIn: '7d' });
  res.json({ token, success: true });
});

// --- ADMIN PROTECTED ROUTES ---

// 4. Update Profile Info
app.put('/api/portfolio/profile', authenticateToken, (req, res) => {
  const db = readDB();
  db.profile = { ...db.profile, ...req.body };
  
  if (writeDB(db)) {
    res.json({ success: true, message: 'Profile updated successfully', profile: db.profile });
  } else {
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// 5. Add Project
app.post('/api/projects', authenticateToken, (req, res) => {
  const db = readDB();
  const newProject = {
    id: 'proj-' + Date.now(),
    title: req.body.title || 'New Project',
    description: req.body.description || '',
    image: req.body.image || '',
    playStoreUrl: req.body.playStoreUrl || '',
    appStoreUrl: req.body.appStoreUrl || '',
    githubUrl: req.body.githubUrl || '',
    tags: Array.isArray(req.body.tags) ? req.body.tags : [],
    features: Array.isArray(req.body.features) ? req.body.features : []
  };

  db.projects = db.projects || [];
  db.projects.push(newProject);

  if (writeDB(db)) {
    res.status(201).json({ success: true, project: newProject });
  } else {
    res.status(500).json({ error: 'Failed to add project' });
  }
});

// 6. Update Project
app.put('/api/projects/:id', authenticateToken, (req, res) => {
  const db = readDB();
  const projectId = req.params.id;
  
  db.projects = db.projects || [];
  const index = db.projects.findIndex(p => p.id === projectId);
  
  if (index === -1) {
    return res.status(404).json({ error: 'Project not found' });
  }

  db.projects[index] = {
    ...db.projects[index],
    title: req.body.title !== undefined ? req.body.title : db.projects[index].title,
    description: req.body.description !== undefined ? req.body.description : db.projects[index].description,
    image: req.body.image !== undefined ? req.body.image : db.projects[index].image,
    playStoreUrl: req.body.playStoreUrl !== undefined ? req.body.playStoreUrl : db.projects[index].playStoreUrl,
    appStoreUrl: req.body.appStoreUrl !== undefined ? req.body.appStoreUrl : db.projects[index].appStoreUrl,
    githubUrl: req.body.githubUrl !== undefined ? req.body.githubUrl : db.projects[index].githubUrl,
    tags: Array.isArray(req.body.tags) ? req.body.tags : db.projects[index].tags,
    features: Array.isArray(req.body.features) ? req.body.features : db.projects[index].features
  };

  if (writeDB(db)) {
    res.json({ success: true, project: db.projects[index] });
  } else {
    res.status(500).json({ error: 'Failed to update project' });
  }
});

// 7. Delete Project
app.delete('/api/projects/:id', authenticateToken, (req, res) => {
  const db = readDB();
  const projectId = req.params.id;
  
  db.projects = db.projects || [];
  const initialLength = db.projects.length;
  db.projects = db.projects.filter(p => p.id !== projectId);

  if (db.projects.length === initialLength) {
    return res.status(404).json({ error: 'Project not found' });
  }

  if (writeDB(db)) {
    res.json({ success: true, message: 'Project deleted successfully' });
  } else {
    res.status(500).json({ error: 'Failed to delete project' });
  }
});

// 8. Add Reference/Review
app.post('/api/references', authenticateToken, (req, res) => {
  const db = readDB();
  const newRef = {
    id: 'ref-' + Date.now(),
    clientName: req.body.clientName || 'Anonymous',
    clientCompany: req.body.clientCompany || '',
    clientComment: req.body.clientComment || '',
    clientRating: parseFloat(req.body.clientRating) || 5.0,
    clientImage: req.body.clientImage || ''
  };

  db.references = db.references || [];
  db.references.push(newRef);

  if (writeDB(db)) {
    res.status(201).json({ success: true, reference: newRef });
  } else {
    res.status(500).json({ error: 'Failed to add reference' });
  }
});

// 9. Update Reference/Review
app.put('/api/references/:id', authenticateToken, (req, res) => {
  const db = readDB();
  const refId = req.params.id;
  
  db.references = db.references || [];
  const index = db.references.findIndex(r => r.id === refId);
  
  if (index === -1) {
    return res.status(404).json({ error: 'Reference not found' });
  }

  db.references[index] = {
    ...db.references[index],
    clientName: req.body.clientName !== undefined ? req.body.clientName : db.references[index].clientName,
    clientCompany: req.body.clientCompany !== undefined ? req.body.clientCompany : db.references[index].clientCompany,
    clientComment: req.body.clientComment !== undefined ? req.body.clientComment : db.references[index].clientComment,
    clientRating: req.body.clientRating !== undefined ? parseFloat(req.body.clientRating) : db.references[index].clientRating,
    clientImage: req.body.clientImage !== undefined ? req.body.clientImage : db.references[index].clientImage
  };

  if (writeDB(db)) {
    res.json({ success: true, reference: db.references[index] });
  } else {
    res.status(500).json({ error: 'Failed to update reference' });
  }
});

// 10. Delete Reference/Review
app.delete('/api/references/:id', authenticateToken, (req, res) => {
  const db = readDB();
  const refId = req.params.id;
  
  db.references = db.references || [];
  const initialLength = db.references.length;
  db.references = db.references.filter(r => r.id !== refId);

  if (db.references.length === initialLength) {
    return res.status(404).json({ error: 'Reference not found' });
  }

  if (writeDB(db)) {
    res.json({ success: true, message: 'Reference deleted successfully' });
  } else {
    res.status(500).json({ error: 'Failed to delete reference' });
  }
});

// 11. Update Skills List
app.put('/api/skills', authenticateToken, (req, res) => {
  const db = readDB();
  if (Array.isArray(req.body.skills)) {
    db.skills = req.body.skills;
    if (writeDB(db)) {
      return res.json({ success: true, skills: db.skills });
    }
  }
  res.status(400).json({ error: 'Invalid skills payload' });
});

// 12. Update Experiences List
app.put('/api/experience', authenticateToken, (req, res) => {
  const db = readDB();
  if (Array.isArray(req.body.experience)) {
    db.experience = req.body.experience;
    if (writeDB(db)) {
      return res.json({ success: true, experience: db.experience });
    }
  }
  res.status(400).json({ error: 'Invalid experience payload' });
});

// 12a. Update Education List
app.put('/api/education', authenticateToken, (req, res) => {
  const db = readDB();
  if (Array.isArray(req.body.education)) {
    db.education = req.body.education;
    if (writeDB(db)) {
      return res.json({ success: true, education: db.education });
    }
  }
  res.status(400).json({ error: 'Invalid education payload' });
});

// 12b. Update AI Workflow List
app.put('/api/ai', authenticateToken, (req, res) => {
  const db = readDB();
  if (Array.isArray(req.body.aiWorkflow)) {
    db.aiWorkflow = req.body.aiWorkflow;
    if (writeDB(db)) {
      return res.json({ success: true, aiWorkflow: db.aiWorkflow });
    }
  }
  res.status(400).json({ error: 'Invalid AI workflow payload' });
});

// 13. Get all Inbox Messages (Admin Only)
app.get('/api/contact', authenticateToken, (req, res) => {
  const db = readDB();
  res.json(db.messages || []);
});

// 14. Delete single Inbox Message
app.delete('/api/contact/:id', authenticateToken, (req, res) => {
  const db = readDB();
  const messageId = req.params.id;

  db.messages = db.messages || [];
  const initialLength = db.messages.length;
  db.messages = db.messages.filter(m => m.id !== messageId);

  if (db.messages.length === initialLength) {
    return res.status(404).json({ error: 'Message not found' });
  }

  if (writeDB(db)) {
    res.json({ success: true, message: 'Message deleted successfully' });
  } else {
    res.status(500).json({ error: 'Failed to delete message' });
  }
});

// Start Express Server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
