import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/admin_controller.dart';
import '../controllers/portfolio_controller.dart';
import '../models/portfolio_models.dart';
import '../models/project_model.dart';
import '../theme/portfolio_theme.dart';
import '../widgets/portfolio_image.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final adminController = Get.find<AdminController>();
  final portfolioController = Get.find<PortfolioController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Redirect if not logged in
      if (!adminController.isLoggedIn.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed('/admin');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final isDark = portfolioController.isDarkMode.value;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? PortfolioTheme.surfaceDark : Colors.white,
          elevation: 1,
          title: Row(
            children: [
              Text(
                "Sakil Hossen",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : PortfolioTheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PortfolioTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Dashboard",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: PortfolioTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? Colors.yellowAccent : PortfolioTheme.secondary,
              ),
              onPressed: portfolioController.toggleTheme,
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text("Logout"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              onPressed: () {
                adminController.logout();
                Get.offNamed('/');
              },
            ),
            const SizedBox(width: 16),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: PortfolioTheme.primary,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
            indicatorColor: PortfolioTheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.mail_outline_rounded), text: "Inbox Messages"),
              Tab(icon: Icon(Icons.person_outline_rounded), text: "Edit Profile"),
              Tab(icon: Icon(Icons.folder_copy_outlined), text: "Manage Projects"),
              Tab(icon: Icon(Icons.star_outline_rounded), text: "Manage Reviews"),
            ],
          ),
        ),
        body: Container(
          color: isDark ? PortfolioTheme.bgDark : PortfolioTheme.bgLight,
          child: TabBarView(
            controller: _tabController,
            children: [
              _InboxTab(isDark: isDark),
              _ProfileTab(isDark: isDark),
              _ProjectsTab(isDark: isDark),
              _ReviewsTab(isDark: isDark),
            ],
          ),
        ),
      );
    });
  }
}

// =======================
// 1. INBOX MESSAGES TAB
// =======================
class _InboxTab extends StatelessWidget {
  final bool isDark;
  const _InboxTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Obx(() {
      final messages = adminController.inboxMessages;
      final loading = adminController.isLoadingInbox.value;

      if (loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline_rounded, size: 48, color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(height: 16),
              Text(
                "Your inbox is empty",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Refresh Inbox"),
                onPressed: adminController.fetchInbox,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: adminController.fetchInbox,
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? PortfolioTheme.surfaceDark.withOpacity(0.5) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? PortfolioTheme.borderDark : PortfolioTheme.borderLight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: PortfolioTheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.person_rounded, color: PortfolioTheme.primary),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      msg.name,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      msg.timestamp.substring(0, 10),
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      msg.email,
                      style: GoogleFonts.inter(color: PortfolioTheme.accent, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      msg.message,
                      style: GoogleFonts.inter(height: 1.4),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () => _confirmDeleteMessage(context, msg.id),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _confirmDeleteMessage(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Are you sure you want to delete this contact message permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Get.find<AdminController>().deleteInboxMessage(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

// =======================
// 2. EDIT PROFILE DETAILS TAB
// =======================
class _ProfileTab extends StatefulWidget {
  final bool isDark;
  const _ProfileTab({required this.isDark});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _cvUrlCtrl;
  late TextEditingController _expYearsCtrl;
  late TextEditingController _completedProjCtrl;
  late TextEditingController _clientsCtrl;
  late TextEditingController _philosophyCtrl;
  late TextEditingController _goalsCtrl;

  @override
  void initState() {
    super.initState();
    final profile = Get.find<PortfolioController>().profile.value;
    
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _titleCtrl = TextEditingController(text: profile?.title ?? '');
    _taglineCtrl = TextEditingController(text: profile?.tagline ?? '');
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
    _cvUrlCtrl = TextEditingController(text: profile?.cvUrl ?? '');
    _expYearsCtrl = TextEditingController(text: profile?.experienceYears ?? '');
    _completedProjCtrl = TextEditingController(text: profile?.completedProjects ?? '');
    _clientsCtrl = TextEditingController(text: profile?.happyClients ?? '');
    _philosophyCtrl = TextEditingController(text: profile?.developmentPhilosophy ?? '');
    _goalsCtrl = TextEditingController(text: profile?.careerGoals ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _bioCtrl.dispose();
    _cvUrlCtrl.dispose();
    _expYearsCtrl.dispose();
    _completedProjCtrl.dispose();
    _clientsCtrl.dispose();
    _philosophyCtrl.dispose();
    _goalsCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final updatedProfile = Profile(
      name: _nameCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      cvUrl: _cvUrlCtrl.text.trim(),
      experienceYears: _expYearsCtrl.text.trim(),
      completedProjects: _completedProjCtrl.text.trim(),
      happyClients: _clientsCtrl.text.trim(),
      developmentPhilosophy: _philosophyCtrl.text.trim(),
      careerGoals: _goalsCtrl.text.trim(),
    );

    final success = await Get.find<AdminController>().updateProfile(updatedProfile);
    if (success) {
      Get.snackbar('Success', 'Profile details updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Error', 'Failed to save changes', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Public Brand & Identity",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: "Profession Title", prefixIcon: Icon(Icons.badge)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taglineCtrl,
              decoration: const InputDecoration(labelText: "Hero Status / Tagline", prefixIcon: Icon(Icons.announcement)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Biography Text", prefixIcon: Icon(Icons.history_edu)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cvUrlCtrl,
              decoration: const InputDecoration(labelText: "CV Download Link / URL", prefixIcon: Icon(Icons.download)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            
            Text(
              "Key Portfolio Stats",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expYearsCtrl,
                    decoration: const InputDecoration(labelText: "Experience (e.g. 3+)", prefixIcon: Icon(Icons.timeline)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _completedProjCtrl,
                    decoration: const InputDecoration(labelText: "Completed Projects (e.g. 20+)", prefixIcon: Icon(Icons.done_all)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _clientsCtrl,
                    decoration: const InputDecoration(labelText: "Happy Clients (e.g. 10+)", prefixIcon: Icon(Icons.people_outline)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text(
              "Philosophies & Objectives",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _philosophyCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Development Philosophy", prefixIcon: Icon(Icons.explore)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _goalsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Career Goals", prefixIcon: Icon(Icons.flag)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 40),

            Obx(() {
              final saving = Get.find<AdminController>().isSaving.value;
              return SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PortfolioTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: saving ? null : _saveProfile,
                  icon: const Icon(Icons.save_rounded),
                  label: saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : const Text("Save Details"),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =======================
// 3. PROJECTS CRUD TAB
// =======================
class _ProjectsTab extends StatelessWidget {
  final bool isDark;
  const _ProjectsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();

    return Obx(() {
      final projects = controller.projects;

      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Manage Project Gallery",
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: PortfolioTheme.primary, foregroundColor: Colors.white),
                  onPressed: () => _openProjectForm(context, null),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text("Add New Project"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final proj = projects[index];
                  return Card(
                    color: isDark ? PortfolioTheme.surfaceDark.withOpacity(0.5) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: PortfolioImage(imageSource: proj.image),
                        ),
                      ),
                      title: Text(proj.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      subtitle: Text(proj.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                            onPressed: () => _openProjectForm(context, proj),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => _confirmDeleteProject(context, proj.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  void _confirmDeleteProject(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Project"),
        content: const Text("Are you sure you want to delete this project?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Get.find<AdminController>().deleteProject(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _openProjectForm(BuildContext context, Project? project) {
    final isEdit = project != null;
    
    final titleCtrl = TextEditingController(text: project?.title ?? '');
    final descCtrl = TextEditingController(text: project?.description ?? '');
    final imgCtrl = TextEditingController(text: project?.image ?? '');
    final playCtrl = TextEditingController(text: project?.playStoreUrl ?? '');
    final appCtrl = TextEditingController(text: project?.appStoreUrl ?? '');
    final gitCtrl = TextEditingController(text: project?.githubUrl ?? '');
    final tagsCtrl = TextEditingController(text: project?.tags.join(', ') ?? '');
    final featuresCtrl = TextEditingController(text: project?.features.join('\n') ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Project" : "Add Project"),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Project Title")),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "About / Description")),
                const SizedBox(height: 12),
                TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: "Image Path (e.g. assets/images/quran_international.png or URL)")),
                const SizedBox(height: 12),
                TextField(controller: playCtrl, decoration: const InputDecoration(labelText: "Google Play Store Link")),
                const SizedBox(height: 12),
                TextField(controller: appCtrl, decoration: const InputDecoration(labelText: "Apple App Store Link")),
                const SizedBox(height: 12),
                TextField(controller: gitCtrl, decoration: const InputDecoration(labelText: "GitHub Link")),
                const SizedBox(height: 12),
                TextField(controller: tagsCtrl, decoration: const InputDecoration(labelText: "Tags (comma-separated, e.g. Flutter, Dart, SQLite)")),
                const SizedBox(height: 12),
                TextField(controller: featuresCtrl, maxLines: 4, decoration: const InputDecoration(labelText: "Key Features (one per line)")),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newProj = Project(
                id: isEdit ? project.id : 'proj-${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                image: imgCtrl.text.trim(),
                playStoreUrl: playCtrl.text.trim(),
                appStoreUrl: appCtrl.text.trim(),
                githubUrl: gitCtrl.text.trim(),
                tags: tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
                features: featuresCtrl.text.split('\n').map((f) => f.trim()).where((f) => f.isNotEmpty).toList(),
              );

              final admin = Get.find<AdminController>();
              bool success = false;
              if (isEdit) {
                success = await admin.updateProject(newProj);
              } else {
                success = await admin.addProject(newProj);
              }

              if (success) {
                Navigator.pop(context);
                Get.snackbar('Success', 'Project updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

// =======================
// 4. CLIENT REVIEWS CRUD TAB
// =======================
class _ReviewsTab extends StatelessWidget {
  final bool isDark;
  const _ReviewsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();

    return Obx(() {
      final reviews = controller.references;

      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Manage Client Testimonials",
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: PortfolioTheme.primary, foregroundColor: Colors.white),
                  onPressed: () => _openReviewForm(context, null),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text("Add New Review"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final ref = reviews[index];
                  return Card(
                    color: isDark ? PortfolioTheme.surfaceDark.withOpacity(0.5) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(ref.clientImage.startsWith('http') ? ref.clientImage : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
                        child: ref.clientImage.startsWith('http') ? null : const Icon(Icons.person),
                      ),
                      title: Text(ref.clientName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      subtitle: Text("${ref.clientCompany} - Rating: ${ref.clientRating}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                            onPressed: () => _openReviewForm(context, ref),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => _confirmDeleteReview(context, ref.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  void _confirmDeleteReview(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to delete this recommendation permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Get.find<AdminController>().deleteReference(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _openReviewForm(BuildContext context, ClientReference? ref) {
    final isEdit = ref != null;
    
    final nameCtrl = TextEditingController(text: ref?.clientName ?? '');
    final compCtrl = TextEditingController(text: ref?.clientCompany ?? '');
    final commentCtrl = TextEditingController(text: ref?.clientComment ?? '');
    final ratingCtrl = TextEditingController(text: ref?.clientRating.toString() ?? '5.0');
    final imgCtrl = TextEditingController(text: ref?.clientImage ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Client Review" : "Add Client Review"),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Client Name")),
                const SizedBox(height: 12),
                TextField(controller: compCtrl, decoration: const InputDecoration(labelText: "Company / Role")),
                const SizedBox(height: 12),
                TextField(controller: commentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: "Review Comment")),
                const SizedBox(height: 12),
                TextField(controller: ratingCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Rating (e.g. 5.0)")),
                const SizedBox(height: 12),
                TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: "Client Photo (Unsplash link, network URL, or Base64)")),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newRef = ClientReference(
                id: isEdit ? ref.id : 'ref-${DateTime.now().millisecondsSinceEpoch}',
                clientName: nameCtrl.text.trim(),
                clientCompany: compCtrl.text.trim(),
                clientComment: commentCtrl.text.trim(),
                clientRating: double.tryParse(ratingCtrl.text) ?? 5.0,
                clientImage: imgCtrl.text.trim(),
              );

              final admin = Get.find<AdminController>();
              bool success = false;
              if (isEdit) {
                success = await admin.updateReference(newRef);
              } else {
                success = await admin.addReference(newRef);
              }

              if (success) {
                Navigator.pop(context);
                Get.snackbar('Success', 'Recommendation saved', backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
