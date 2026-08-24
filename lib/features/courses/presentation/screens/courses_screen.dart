import 'package:flutter/material.dart';
import 'package:rahpeyman/core/services/auth_service.dart';
import 'package:rahpeyman/features/auth/screens/phone_auth_screen.dart';
import 'package:rahpeyman/features/courses/models/course_models.dart';
import 'package:rahpeyman/features/courses/services/course_api.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _api = CourseApi();
  late Future<bool> _authFuture;
  late Future<List<CourseSummary>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = AuthService.isLoggedIn();
    _coursesFuture = _api.getCourses();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _authFuture = AuthService.isLoggedIn();
      _coursesFuture = _api.getCourses();
    });
  }

  Future<void> _openLogin() async {
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
    );
    if (loggedIn == true && mounted) {
      _reload();
    }
  }

  Future<void> _startPayment() async {
    try {
      final paymentUrl = await _api.createSubscriptionPayment();
      final launched = await launchUrl(
        Uri.parse(paymentUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showMessage('باز کردن درگاه پرداخت ممکن نشد.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('دوره‌ها'),
          actions: [
            IconButton(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تلاش دوباره',
            ),
          ],
        ),
        body: FutureBuilder<bool>(
          future: _authFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data != true) {
              return _LoginRequiredState(onLogin: _openLogin);
            }

            return FutureBuilder<List<CourseSummary>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }

            final courses = snapshot.data ?? const <CourseSummary>[];
            if (courses.isEmpty) {
              return const Center(child: Text('هنوز دوره‌ای منتشر نشده است.'));
            }

                return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _startPayment,
                      icon: const Icon(Icons.payment_rounded),
                      label: const Text('پرداخت حق اشتراک'),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    'پس از پرداخت موفق، ویدئوهای کامل دوره‌ها برای شما فعال می‌شوند.',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _CourseCard(
                        course: course,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CourseVideosScreen(course: course),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CourseVideosScreen extends StatefulWidget {
  const CourseVideosScreen({required this.course, super.key});

  final CourseSummary course;

  @override
  State<CourseVideosScreen> createState() => _CourseVideosScreenState();
}

class _CourseVideosScreenState extends State<CourseVideosScreen> {
  final _api = CourseApi();
  late Future<List<CourseVideo>> _videosFuture;
  int? _openingVideoId;

  @override
  void initState() {
    super.initState();
    _videosFuture = _api.getVideos(widget.course.id);
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.course.title)),
        body: FutureBuilder<List<CourseVideo>>(
          future: _videosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final videos = snapshot.data ?? const <CourseVideo>[];
            if (videos.isEmpty) {
              return const Center(
                child: Text('هنوز ویدئویی برای این دوره منتشر نشده است.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final video = videos[index];
                return ListTile(
                  leading: Icon(
                    video.locked
                        ? Icons.lock_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    color: video.locked
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(video.title),
                  subtitle: Text(
                    video.locked
                        ? 'فقط برای اعضای دارای اشتراک فعال'
                        : video.isPreview
                            ? 'پیش‌نمایش رایگان'
                            : 'قابل مشاهده با اشتراک فعال',
                  ),
                  onTap: video.locked
                      ? () => _showSubscriptionMessage(context)
                      : () => _openVideo(video),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openVideo(CourseVideo video) async {
    if (_openingVideoId != null) return;

    setState(() => _openingVideoId = video.id);
    try {
      final streamUrl = await _api.getVideoStream(video.id);
      final launched = await launchUrl(
        Uri.parse(streamUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showVideoMessage('باز کردن ویدئو ممکن نشد.');
      }
    } catch (error) {
      if (mounted) {
        _showVideoMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _openingVideoId = null);
    }
  }

  void _showVideoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSubscriptionMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('برای مشاهده این ویدئو اشتراک فعال تهیه کنید.'),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final CourseSummary course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(
            course.hasAccess
                ? Icons.video_library_rounded
                : Icons.lock_outline_rounded,
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            course.hasAccess
                ? 'اشتراک فعال است؛ ویدئوها قابل مشاهده‌اند'
                : 'برای مشاهده ویدئوهای کامل، اشتراک تهیه کنید',
          ),
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _LoginRequiredState extends StatelessWidget {
  const _LoginRequiredState({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 56),
            const SizedBox(height: 12),
            const Text(
              'برای مشاهده دوره‌ها ابتدا وارد حساب کاربری شوید.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login_rounded),
              label: const Text('ورود / ثبت‌نام'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تلاش دوباره'),
            ),
          ],
        ),
      ),
    );
  }
}
