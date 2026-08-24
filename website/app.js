(function () {
  'use strict';

  const config = window.RAHPYMAN_CONFIG || {};
  const API_BASE_URL = String(config.apiBaseUrl || '').replace(/\/+$/, '');
  const TOKEN_KEY = 'rahpeyman_web_token';
  const DEVICE_KEY = 'rahpeyman_web_device_id';

  const state = {
    phone: '',
    token: sessionStorage.getItem(TOKEN_KEY),
    user: null,
  };

  const $ = (selector) => document.querySelector(selector);

  function getDeviceId() {
    const existing = localStorage.getItem(DEVICE_KEY);
    if (existing && existing.length >= 32) return existing;

    const generated =
      typeof crypto !== 'undefined' && crypto.randomUUID
        ? crypto.randomUUID().replaceAll('-', '') + crypto.randomUUID().replaceAll('-', '')
        : `${Date.now()}-${Math.random().toString(36).slice(2)}-${Math.random()
            .toString(36)
            .slice(2)}`;
    localStorage.setItem(DEVICE_KEY, generated);
    return generated;
  }

  function escapeHtml(value) {
    return String(value ?? '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }

  function formatPrice(value) {
    return `${new Intl.NumberFormat('fa-IR').format(value || 0)} ریال`;
  }

  function setAuthStatus(message, isError = true) {
    const element = $('#auth-status');
    element.textContent = message || '';
    element.style.color = isError ? 'var(--danger)' : 'var(--success)';
  }

  function setBusy(button, busy, busyText = 'در حال پردازش...') {
    if (!button) return;
    if (busy) {
      button.dataset.originalText = button.textContent;
      button.textContent = busyText;
      button.disabled = true;
    } else {
      button.textContent = button.dataset.originalText || button.textContent;
      button.disabled = false;
    }
  }

  function showToast(message, isError = false) {
    const toast = $('#toast');
    toast.textContent = message;
    toast.style.background = isError ? 'var(--danger)' : 'var(--blue-950)';
    toast.classList.add('visible');
    window.clearTimeout(showToast.timer);
    showToast.timer = window.setTimeout(
      () => toast.classList.remove('visible'),
      3600,
    );
  }

  async function api(path, options = {}) {
    if (!API_BASE_URL) {
      throw new Error('آدرس API در website/config.js تنظیم نشده است.');
    }

    const headers = new Headers(options.headers || {});
    headers.set('Accept', 'application/json');
    if (options.body && !headers.has('Content-Type')) {
      headers.set('Content-Type', 'application/json');
    }
    if (state.token) {
      headers.set('Authorization', `Bearer ${state.token}`);
    }

    const response = await fetch(`${API_BASE_URL}${path}`, {
      ...options,
      headers,
    });
    const raw = await response.text();
    let data = {};
    try {
      data = raw ? JSON.parse(raw) : {};
    } catch (_) {
      data = { message: raw };
    }

    if (response.status === 401) {
      clearSession();
      showAuth();
    }
    if (!response.ok) {
      throw new Error(
        data.detail || data.message || 'ارتباط با سرور ناموفق بود.',
      );
    }
    return data;
  }

  function clearSession() {
    state.token = null;
    state.user = null;
    sessionStorage.removeItem(TOKEN_KEY);
  }

  function showAuth() {
    $('#auth-view').classList.remove('hidden');
    $('#app-view').classList.add('hidden');
    $('#phone-form').classList.remove('hidden');
    $('#otp-form').classList.add('hidden');
    $('#phone').focus();
  }

  async function showApp() {
    $('#auth-view').classList.add('hidden');
    $('#app-view').classList.remove('hidden');
    $('#user-phone').textContent = state.user?.phone || state.phone;
    await loadCourses();
  }

  function normalizePhone(value) {
    let phone = value.replace(/[\s\-()]/g, '');
    if (phone.startsWith('+98')) phone = `0${phone.slice(3)}`;
    if (phone.startsWith('0098')) phone = `0${phone.slice(4)}`;
    return phone;
  }

  function renderAccountStatus() {
    const element = $('#account-status');
    if (!state.user) {
      element.classList.remove('visible');
      return;
    }

    const expiry = state.user.subscription_expires_at;
    if (state.user.subscription_active && expiry) {
      const date = new Intl.DateTimeFormat('fa-IR', {
        dateStyle: 'long',
      }).format(new Date(expiry));
      element.textContent = `اشتراک شما فعال است و تا ${date} اعتبار دارد.`;
      element.classList.add('visible');
    } else {
      element.textContent =
        'اشتراک فعالی ندارید. برای مشاهده ویدئوهای کامل، اشتراک خود را تهیه کنید.';
      element.classList.add('visible');
    }
  }

  async function loadCurrentUser() {
    state.user = await api('/auth/me');
    renderAccountStatus();
  }

  async function loadCourses() {
    const grid = $('#courses-grid');
    grid.innerHTML = '<div class="loading-state">در حال دریافت دوره‌ها...</div>';
    try {
      await loadCurrentUser();
      const courses = await api('/courses/');
      renderCourses(Array.isArray(courses) ? courses : []);
    } catch (error) {
      grid.innerHTML = `<div class="empty-state">${escapeHtml(error.message)}</div>`;
      showToast(error.message, true);
    }
  }

  function renderCourses(courses) {
    const grid = $('#courses-grid');
    if (!courses.length) {
      grid.innerHTML =
        '<div class="empty-state">هنوز دوره‌ای توسط ادمین منتشر نشده است.</div>';
      return;
    }

    grid.innerHTML = courses
      .map((course) => {
        const active = course.has_access;
        return `
          <article class="course-card">
            <div class="course-icon">▣</div>
            <h3>${escapeHtml(course.title)}</h3>
            <p>${escapeHtml(course.description || 'محتوای آموزشی رهپیمان')}</p>
            <div class="course-meta">
              <span class="access-badge ${active ? 'active' : ''}">
                ${active ? 'اشتراک فعال' : 'نیازمند اشتراک'}
              </span>
              <button class="button primary compact" data-course-id="${course.id}">
                مشاهده محتوا
              </button>
            </div>
          </article>`;
      })
      .join('');

    grid.querySelectorAll('[data-course-id]').forEach((button) => {
      button.addEventListener('click', () =>
        openCourse(Number(button.dataset.courseId), button.closest('article')),
      );
    });
  }

  async function openCourse(courseId, card) {
    const title = card?.querySelector('h3')?.textContent || 'دوره';
    $('#course-modal-title').textContent = title;
    $('#videos-list').innerHTML =
      '<div class="loading-state">در حال دریافت ویدئوها...</div>';
    openModal('course-modal');

    try {
      const videos = await api(`/courses/${courseId}/videos`);
      renderVideos(videos || []);
    } catch (error) {
      $('#videos-list').innerHTML =
        `<div class="empty-state">${escapeHtml(error.message)}</div>`;
    }
  }

  function renderVideos(videos) {
    const list = $('#videos-list');
    if (!videos.length) {
      list.innerHTML =
        '<div class="empty-state">پیش‌نمایشی برای این دوره منتشر نشده است. ویدئوهای کامل با اشتراک فعال نمایش داده می‌شوند.</div>';
      return;
    }

    list.innerHTML = videos
      .map(
        (video) => `
        <div class="video-row">
          <div class="video-icon">${video.locked ? '🔒' : '▶'}</div>
          <div class="video-info">
            <strong>${escapeHtml(video.title)}</strong>
            <small>
              ${
                video.is_preview
                  ? 'پیش‌نمایش رایگان'
                  : 'قابل مشاهده با اشتراک فعال'
              }
            </small>
          </div>
          ${
            video.locked
              ? '<span class="video-lock">قفل</span>'
              : `<button class="button ghost compact" data-video-id="${video.id}" data-video-title="${escapeHtml(video.title)}">پخش</button>`
          }
        </div>`,
      )
      .join('');

    list.querySelectorAll('[data-video-id]').forEach((button) => {
      button.addEventListener('click', () =>
        playVideo(Number(button.dataset.videoId), button.dataset.videoTitle),
      );
    });
  }

  async function playVideo(videoId, title) {
    $('#video-modal-title').textContent = title || 'پخش ویدئو';
    $('#video-status').textContent = 'در حال آماده‌سازی ویدئو...';
    const player = $('#video-player');
    player.removeAttribute('src');
    player.load();
    openModal('video-modal');

    try {
      const data = await api(`/courses/videos/${videoId}/stream`);
      player.src = data.stream_url;
      player.load();
      $('#video-status').textContent = '';
    } catch (error) {
      $('#video-status').textContent = error.message;
      showToast(error.message, true);
    }
  }

  async function startPayment() {
    const buttons = [$('#hero-payment')];
    buttons.forEach((button) => setBusy(button, true, 'در حال اتصال به درگاه...'));
    try {
      const data = await api('/payments/subscription', { method: 'POST' });
      if (data.error) throw new Error(data.message || 'پرداخت فعال نیست.');
      const paymentWindow = window.open(
        data.payment_url,
        '_blank',
        'noopener,noreferrer',
      );
      if (!paymentWindow) window.location.assign(data.payment_url);
      showToast('درگاه پرداخت در صفحه جدید باز شد.');
    } catch (error) {
      showToast(error.message, true);
    } finally {
      buttons.forEach((button) => setBusy(button, false));
    }
  }

  function openModal(id) {
    $(`#${id}`).classList.remove('hidden');
    document.body.style.overflow = 'hidden';
  }

  function closeModal(id) {
    $(`#${id}`).classList.add('hidden');
    if (!document.querySelector('.modal:not(.hidden)')) {
      document.body.style.overflow = '';
    }
    if (id === 'video-modal') {
      const player = $('#video-player');
      player.pause();
      player.removeAttribute('src');
      player.load();
    }
  }

  function bindEvents() {
    $('#phone-form').addEventListener('submit', async (event) => {
      event.preventDefault();
      const button = event.submitter;
      const phone = normalizePhone($('#phone').value.trim());
      if (!/^09\d{9}$/.test(phone)) {
        setAuthStatus('شماره موبایل معتبر نیست.');
        return;
      }

      setBusy(button, true, 'در حال ارسال...');
      try {
        await api('/auth/request-otp', {
          method: 'POST',
          body: JSON.stringify({ phone }),
        });
        state.phone = phone;
        $('#phone-form').classList.add('hidden');
        $('#otp-form').classList.remove('hidden');
        setAuthStatus('کد تأیید ارسال شد.', false);
        $('#otp').focus();
      } catch (error) {
        setAuthStatus(error.message);
      } finally {
        setBusy(button, false);
      }
    });

    $('#otp-form').addEventListener('submit', async (event) => {
      event.preventDefault();
      const button = event.submitter;
      const otp = $('#otp').value.trim();
      if (!/^\d{6}$/.test(otp)) {
        setAuthStatus('کد تأیید باید ۶ رقم باشد.');
        return;
      }

      setBusy(button, true, 'در حال ورود...');
      try {
        const data = await api('/auth/verify-otp', {
          method: 'POST',
          body: JSON.stringify({
            phone: state.phone,
            otp,
            device_id: getDeviceId(),
            system_device_id: getDeviceId(),
            platform: 'web',
            attestation_provider: 'web_browser',
          }),
        });
        state.token = data.access_token;
        sessionStorage.setItem(TOKEN_KEY, state.token);
        await showApp();
      } catch (error) {
        setAuthStatus(error.message);
      } finally {
        setBusy(button, false);
      }
    });

    $('#change-phone').addEventListener('click', () => {
      $('#otp').value = '';
      setAuthStatus('');
      showAuth();
    });
    $('#logout-button').addEventListener('click', () => {
      clearSession();
      showAuth();
      showToast('از حساب خارج شدید.');
    });
    $('#refresh-courses').addEventListener('click', loadCourses);
    $('#hero-payment').addEventListener('click', startPayment);

    document.querySelectorAll('[data-close-modal]').forEach((button) => {
      button.addEventListener('click', () =>
        closeModal(button.dataset.closeModal),
      );
    });
    document.querySelectorAll('.modal').forEach((modal) => {
      modal.addEventListener('click', (event) => {
        if (event.target === modal) closeModal(modal.id);
      });
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        document.querySelectorAll('.modal:not(.hidden)').forEach((modal) =>
          closeModal(modal.id),
        );
      }
    });
    window.addEventListener('focus', () => {
      if (state.token) loadCourses();
    });
  }

  async function bootstrap() {
    bindEvents();
    if (!state.token) {
      showAuth();
      return;
    }
    try {
      await showApp();
    } catch (_) {
      clearSession();
      showAuth();
    }
  }

  bootstrap();
})();
