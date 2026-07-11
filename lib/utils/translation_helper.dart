import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

class TranslationHelper {
  static const Map<String, String> languages = {
    'en': 'English',
    'id': 'Indonesia',
    'ar': 'العربية',
    'zh': '中文',
    'ru': 'Русский',
    'ja': '日本語',
    'ko': '한국어',
    'hi': 'हिन्दी',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
  };

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'tab_notes': 'Notes',
      'tab_schedule': 'Schedule',
      'tab_dashboard': 'Dashboard',
      'search_hint': 'Search notes...',
      'section_pinned': 'PINNED',
      'section_all': 'ALL NOTES',
      'card_locked': 'Locked Note',
      'card_locked_hint': 'Touch to open vault...',
      'editor_new': 'New Note',
      'editor_edit': 'Edit Note',
      'editor_title_hint': 'Note Title...',
      'editor_content_hint': 'Write something...',
      'todo_title': 'TASKS CHECKLIST',
      'todo_add': 'Add Task Item',
      'todo_hint': 'Task name...',
      'status_new': 'New draft',
      'status_saved': 'Saved',
      'lock_dialog_title': 'AuraLock Biometrics',
      'lock_dialog_sub': 'Extra Secure Vault Locked',
      'lock_dialog_status': 'Touch the fingerprint sensor',
      'lock_dialog_scan': 'Reading fingerprint...',
      'lock_dialog_match': 'Matching biometrics...',
      'lock_dialog_success': 'Access Granted!',
      'lock_dialog_help': 'Touch fingerprint to start verification',
      'dashboard_title': 'Productivity Analytics',
      'dashboard_sub': 'Notes Statistics & Summary',
      'dashboard_total': 'Total Notes',
      'dashboard_pinned': 'Pinned Notes',
      'dashboard_archived': 'Archived Notes',
      'dashboard_locked': 'Locked Notes',
      'dashboard_trash': 'Trash Bin',
      'dashboard_empty_trash': 'Empty Trash',
      'dashboard_lang': 'Language Settings',
      'dashboard_lang_sub': 'Change application interface language',
      'dashboard_auto_delete': 'Auto Clean Bin',
      'dashboard_auto_delete_sub': 'Permanently deletes notes inside Trash',
      'empty_schedule': 'No reminders scheduled',
      'empty_schedule_sub': 'Your schedule is clear for today.',
      'schedule_title': 'Smart Schedule',
      'schedule_today': 'TODAY REMINDERS',
    },
    'id': {
      'tab_notes': 'Catatan',
      'tab_schedule': 'Jadwal',
      'tab_dashboard': 'Dashboard',
      'search_hint': 'Cari catatan...',
      'section_pinned': 'DISEMATKAN',
      'section_all': 'SEMUA CATATAN',
      'card_locked': 'Catatan Terkunci',
      'card_locked_hint': 'Sentuh untuk membuka brankas...',
      'editor_new': 'Catatan Baru',
      'editor_edit': 'Edit Catatan',
      'editor_title_hint': 'Judul Catatan...',
      'editor_content_hint': 'Tulis sesuatu...',
      'todo_title': 'TUGAS MANDIRI',
      'todo_add': 'Tambah Item Tugas',
      'todo_hint': 'Nama tugas...',
      'status_new': 'Draf baru',
      'status_saved': 'Disimpan',
      'lock_dialog_title': 'AuraLock Keamanan Biometrik',
      'lock_dialog_sub': 'Brankas Terkunci Ekstra Aman',
      'lock_dialog_status': 'Sentuh sensor sidik jari',
      'lock_dialog_scan': 'Membaca sidik jari...',
      'lock_dialog_match': 'Mencocokkan data biometrik...',
      'lock_dialog_success': 'Akses Diterima!',
      'lock_dialog_help': 'Sentuh sidik jari untuk mulai memverifikasi',
      'dashboard_title': 'Analitik Produktivitas',
      'dashboard_sub': 'Statistik & Ringkasan Catatan',
      'dashboard_total': 'Total Catatan',
      'dashboard_pinned': 'Catatan Tersemat',
      'dashboard_archived': 'Catatan Diarsipkan',
      'dashboard_locked': 'Catatan Terkunci',
      'dashboard_trash': 'Tempat Sampah',
      'dashboard_empty_trash': 'Kosongkan Sampah',
      'dashboard_lang': 'Pengaturan Bahasa',
      'dashboard_lang_sub': 'Ubah bahasa tampilan aplikasi',
      'dashboard_auto_delete': 'Pembersihan Otomatis',
      'dashboard_auto_delete_sub': 'Hapus catatan di tempat sampah secara permanen',
      'empty_schedule': 'Tidak ada pengingat',
      'empty_schedule_sub': 'Jadwal Anda bersih untuk hari ini.',
      'schedule_title': 'Jadwal Cerdas',
      'schedule_today': 'PENGINGAT HARI INI',
    },
    'ar': {
      'tab_notes': 'ملاحظات',
      'tab_schedule': 'الجدول',
      'tab_dashboard': 'لوحة التحكم',
      'search_hint': 'بحث في الملاحظات...',
      'section_pinned': 'مثبتة',
      'section_all': 'كل الملاحظات',
      'card_locked': 'ملاحظة مغلقة',
      'card_locked_hint': 'المس لفتح الخزنة...',
      'editor_new': 'ملاحظة جديدة',
      'editor_edit': 'تعديل الملاحظة',
      'editor_title_hint': 'عنوان الملاحظة...',
      'editor_content_hint': 'اكتب شيئًا...',
      'todo_title': 'قائمة المهام',
      'todo_add': 'إضافة مهمة',
      'todo_hint': 'اسم المهمة...',
      'status_new': 'مسودة جديدة',
      'status_saved': 'تم الحفظ',
      'lock_dialog_title': 'الأمان البيومتري AuraLock',
      'lock_dialog_sub': 'الخزنة المؤمنة مغلقة',
      'lock_dialog_status': 'المس مستشعر البصمة',
      'lock_dialog_scan': 'جاري قراءة البصمة...',
      'lock_dialog_match': 'جاري مطابقة البيانات...',
      'lock_dialog_success': 'تم السماح بالوصول!',
      'lock_dialog_help': 'المس البصمة لبدء التحقق',
      'dashboard_title': 'تحليلات الإنتاجية',
      'dashboard_sub': 'إحصائيات الملاحظات وملخصها',
      'dashboard_total': 'إجمالي الملاحظات',
      'dashboard_pinned': 'ملاحظات مثبتة',
      'dashboard_archived': 'الملاحظات المؤرشفة',
      'dashboard_locked': 'ملاحظات مغلقة',
      'dashboard_trash': 'سلة المهملات',
      'dashboard_empty_trash': 'إفراغ السلة',
      'dashboard_lang': 'إعدادات اللغة',
      'dashboard_lang_sub': 'تغيير لغة واجهة التطبيق',
      'dashboard_auto_delete': 'تنظيف تلقائي',
      'dashboard_auto_delete_sub': 'حذف ملاحظات السلة بشكل دائم',
      'empty_schedule': 'لا توجد تذكيرات',
      'empty_schedule_sub': 'جدولك خالٍ اليوم.',
      'schedule_title': 'الجدول الذكي',
      'schedule_today': 'تذكيرات اليوم',
    },
    'zh': {
      'tab_notes': '笔记',
      'tab_schedule': '日程',
      'tab_dashboard': '仪表板',
      'search_hint': '搜索笔记...',
      'section_pinned': '已固定',
      'section_all': '所有笔记',
      'card_locked': '已锁定的笔记',
      'card_locked_hint': '轻触以打开保险箱...',
      'editor_new': '新笔记',
      'editor_edit': '编辑笔记',
      'editor_title_hint': '笔记标题...',
      'editor_content_hint': '写点什么...',
      'todo_title': '任务清单',
      'todo_add': '添加任务项',
      'todo_hint': '任务名称...',
      'status_new': '新草稿',
      'status_saved': '已保存',
      'lock_dialog_title': 'AuraLock 生物识别',
      'lock_dialog_sub': '极高安全性保险箱已锁定',
      'lock_dialog_status': '触摸指纹传感器',
      'lock_dialog_scan': '正在读取指纹...',
      'lock_dialog_match': '正在匹配生物特征...',
      'lock_dialog_success': '允许访问！',
      'lock_dialog_help': '触摸指纹开始验证',
      'dashboard_title': '生产力分析',
      'dashboard_sub': '笔记统计与摘要',
      'dashboard_total': '笔记总数',
      'dashboard_pinned': '固定笔记',
      'dashboard_archived': '归档笔记',
      'dashboard_locked': '加密笔记',
      'dashboard_trash': '废纸篓',
      'dashboard_empty_trash': '清空废纸篓',
      'dashboard_lang': '语言设置',
      'dashboard_lang_sub': '更改应用界面语言',
      'dashboard_auto_delete': '自动清理',
      'dashboard_auto_delete_sub': '永久删除废纸篓中的笔记',
      'empty_schedule': '没有提醒日程',
      'empty_schedule_sub': '您今天的日程很空闲。',
      'schedule_title': '智能日程',
      'schedule_today': '今日提醒',
    },
    'ru': {
      'tab_notes': 'Заметки',
      'tab_schedule': 'План',
      'tab_dashboard': 'Панель',
      'search_hint': 'Поиск заметок...',
      'section_pinned': 'ЗАКРЕПЛЕННЫЕ',
      'section_all': 'ВСЕ ЗАМЕТКИ',
      'card_locked': 'Заблокированная заметка',
      'card_locked_hint': 'Коснитесь, чтобы открыть...',
      'editor_new': 'Новая заметка',
      'editor_edit': 'Редактировать заметку',
      'editor_title_hint': 'Заголовок заметки...',
      'editor_content_hint': 'Напишите что-нибудь...',
      'todo_title': 'СПИСОК ЗАДАЧ',
      'todo_add': 'Добавить задачу',
      'todo_hint': 'Название задачи...',
      'status_new': 'Новый черновик',
      'status_saved': 'Сохранено',
      'lock_dialog_title': 'Биометрия AuraLock',
      'lock_dialog_sub': 'Защищенное хранилище заблокировано',
      'lock_dialog_status': 'Приложите палец к сенсору',
      'lock_dialog_scan': 'Чтение отпечатка...',
      'lock_dialog_match': 'Сопоставление данных...',
      'lock_dialog_success': 'Доступ разрешен!',
      'lock_dialog_help': 'Коснитесь сенсора для верификации',
      'dashboard_title': 'Аналитика продуктивности',
      'dashboard_sub': 'Статистика и сводка заметок',
      'dashboard_total': 'Всего заметок',
      'dashboard_pinned': 'Закрепленные заметки',
      'dashboard_archived': 'Архивные заметки',
      'dashboard_locked': 'Заблокированные заметки',
      'dashboard_trash': 'Корзина',
      'dashboard_empty_trash': 'Очистить корзину',
      'dashboard_lang': 'Настройки языка',
      'dashboard_lang_sub': 'Изменить язык интерфейса приложения',
      'dashboard_auto_delete': 'Автоочистка',
      'dashboard_auto_delete_sub': 'Навсегда удалять заметки в корзине',
      'empty_schedule': 'Напоминаний нет',
      'empty_schedule_sub': 'Ваше расписание на сегодня пусто.',
      'schedule_title': 'Умный график',
      'schedule_today': 'НАПОМИНАНИЯ НА СЕГОДНЯ',
    },
    'ja': {
      'tab_notes': 'メモ',
      'tab_schedule': '予定表',
      'tab_dashboard': 'ダッシュボード',
      'search_hint': 'メモを検索...',
      'section_pinned': '固定されたメモ',
      'section_all': 'すべてのメモ',
      'card_locked': 'ロックされたメモ',
      'card_locked_hint': 'タッチして金庫を開く...',
      'editor_new': '新規メモ',
      'editor_edit': 'メモを編集',
      'editor_title_hint': 'メモのタイトル...',
      'editor_content_hint': '何か書く...',
      'todo_title': 'タスクチェックリスト',
      'todo_add': 'タスクを追加',
      'todo_hint': 'タスク名...',
      'status_new': '新規下書き',
      'status_saved': '保存済み',
      'lock_dialog_title': 'AuraLock 生体認証',
      'lock_dialog_sub': '極秘の金庫がロックされています',
      'lock_dialog_status': '指紋センサーに触れてください',
      'lock_dialog_scan': '指紋を読み取り中...',
      'lock_dialog_match': '生体認証情報を照合中...',
      'lock_dialog_success': 'アクセスが許可されました！',
      'lock_dialog_help': '指紋センサーに触れて検証を開始',
      'dashboard_title': '生産性分析',
      'dashboard_sub': 'メモの統計と概要',
      'dashboard_total': 'メモの総数',
      'dashboard_pinned': 'ピン留めされたメモ',
      'dashboard_archived': 'アーカイブされたメモ',
      'dashboard_locked': '保護されたメモ',
      'dashboard_trash': 'ゴミ箱',
      'dashboard_empty_trash': 'ゴミ箱を空にする',
      'dashboard_lang': '言語設定',
      'dashboard_lang_sub': 'アプリの表示言語を変更します',
      'dashboard_auto_delete': '自動クリーン',
      'dashboard_auto_delete_sub': 'ゴミ箱内のメモを完全に削除',
      'empty_schedule': 'リマインダーなし',
      'empty_schedule_sub': '今日の予定はありません。',
      'schedule_title': 'スマートスケジュール',
      'schedule_today': '本日のリマインダー',
    },
    'ko': {
      'tab_notes': '메모',
      'tab_schedule': '일정',
      'tab_dashboard': '대시보드',
      'search_hint': '메모 검색...',
      'section_pinned': '고정됨',
      'section_all': '모든 메모',
      'card_locked': '잠긴 메모',
      'card_locked_hint': '보관함을 열려면 터치하세요...',
      'editor_new': '새 메모',
      'editor_edit': '메모 편집',
      'editor_title_hint': '메모 제목...',
      'editor_content_hint': '내용을 입력하세요...',
      'todo_title': '할 일 목록',
      'todo_add': '할 일 추가',
      'todo_hint': '할 일 제목...',
      'status_new': '새 임시저장',
      'status_saved': '저장됨',
      'lock_dialog_title': 'AuraLock 생체 인식',
      'lock_dialog_sub': '보안 보관함이 잠겨 있습니다',
      'lock_dialog_status': '지문 센서에 대세요',
      'lock_dialog_scan': '지문 읽는 중...',
      'lock_dialog_match': '생체 데이터 분석 중...',
      'lock_dialog_success': '액세스 허용!',
      'lock_dialog_help': '지문을 대어 인증 시작',
      'dashboard_title': '생산성 분석',
      'dashboard_sub': '메모 통계 및 요약',
      'dashboard_total': '총 메모 수',
      'dashboard_pinned': '고정된 메모',
      'dashboard_archived': '보관된 메모',
      'dashboard_locked': '잠긴 메모',
      'dashboard_trash': '휴지통',
      'dashboard_empty_trash': '휴지통 비우기',
      'dashboard_lang': '언어 설정',
      'dashboard_lang_sub': '애플리케이션 표시 언어 변경',
      'dashboard_auto_delete': '자동 정리',
      'dashboard_auto_delete_sub': '휴지통 안의 메모를 영구 삭제',
      'empty_schedule': '예정된 알림 없음',
      'empty_schedule_sub': '오늘 일정은 비어 있습니다.',
      'schedule_title': '스마트 일정',
      'schedule_today': '오늘의 알림',
    },
    'hi': {
      'tab_notes': 'नोट्स',
      'tab_schedule': 'अनुसूची',
      'tab_dashboard': 'डैशबोर्ड',
      'search_hint': 'खोजें...',
      'section_pinned': 'पिन किया हुआ',
      'section_all': 'सभी नोट्स',
      'card_locked': 'सुरक्षित नोट',
      'card_locked_hint': 'तिजोरी खोलने के लिए छुएं...',
      'editor_new': 'नया नोट',
      'editor_edit': 'नोट संपादित करें',
      'editor_title_hint': 'नोट का शीर्षक...',
      'editor_content_hint': 'कुछ लिखें...',
      'todo_title': 'कार्य सूची',
      'todo_add': 'नया कार्य जोड़ें',
      'todo_hint': 'कार्य का नाम...',
      'status_new': 'नया मसौदा',
      'status_saved': 'सुरक्षित',
      'lock_dialog_title': 'AuraLock बायोमेट्रिक्स',
      'lock_dialog_sub': 'अति सुरक्षित तिजोरी बंद है',
      'lock_dialog_status': 'फिंगरप्रिंट सेंसर को छुएं',
      'lock_dialog_scan': 'फिंगरप्रिंट पढ़ा जा रहा है...',
      'lock_dialog_match': 'बायोमेट्रिक्स मिलाया जा रहा है...',
      'lock_dialog_success': 'पहुंच स्वीकृत!',
      'lock_dialog_help': 'सत्यापन शुरू करने के लिए सेंसर छुएं',
      'dashboard_title': 'उत्पादकता विश्लेषण',
      'dashboard_sub': 'नोट्स के आंकड़े और सारांश',
      'dashboard_total': 'कुल नोट्स',
      'dashboard_pinned': 'पिन किए गए नोट्स',
      'dashboard_archived': 'संग्रहीत नोट्स',
      'dashboard_locked': 'लॉक किए गए नोट्स',
      'dashboard_trash': 'कचरा पेटी',
      'dashboard_empty_trash': 'कचरा खाली करें',
      'dashboard_lang': 'भाषा सेटिंग्स',
      'dashboard_lang_sub': 'एप्लिकेशन की भाषा बदलें',
      'dashboard_auto_delete': 'स्वतः साफ़',
      'dashboard_auto_delete_sub': 'कचरा पेटी के नोट्स को हमेशा के लिए हटाएं',
      'empty_schedule': 'कोई अनुस्मारक नहीं',
      'empty_schedule_sub': 'आज आपकी अनुसूची पूरी तरह साफ़ है।',
      'schedule_title': 'स्मार्ट अनुसूची',
      'schedule_today': 'आज के अनुस्मारक',
    },
    'de': {
      'tab_notes': 'Notizen',
      'tab_schedule': 'Termine',
      'tab_dashboard': 'Dashboard',
      'search_hint': 'Notizen suchen...',
      'section_pinned': 'ANGEHEFTET',
      'section_all': 'ALLE NOTIZEN',
      'card_locked': 'Gesperrte Notiz',
      'card_locked_hint': 'Tippen zum Entsperren...',
      'editor_new': 'Neue Notiz',
      'editor_edit': 'Notiz bearbeiten',
      'editor_title_hint': 'Titel...',
      'editor_content_hint': 'Schreibe etwas...',
      'todo_title': 'AUFGABENLISTE',
      'todo_add': 'Aufgabe hinzufügen',
      'todo_hint': 'Aufgabenname...',
      'status_new': 'Neuer Entwurf',
      'status_saved': 'Gespeichert',
      'lock_dialog_title': 'AuraLock Biometrie',
      'lock_dialog_sub': 'Sicherer Tresor gesperrt',
      'lock_dialog_status': 'Berühren Sie den Fingersensor',
      'lock_dialog_scan': 'Fingerabdruck wird gelesen...',
      'lock_dialog_match': 'Biometrie wird abgeglichen...',
      'lock_dialog_success': 'Zugriff gewährt!',
      'lock_dialog_help': 'Berühren Sie den Sensor zum Verifizieren',
      'dashboard_title': 'Produktivitätsanalyse',
      'dashboard_sub': 'Statistiken & Notizenübersicht',
      'dashboard_total': 'Notizen Gesamt',
      'dashboard_pinned': 'Angeheftete Notizen',
      'dashboard_archived': 'Archivierte Notizen',
      'dashboard_locked': 'Gesperrte Notizen',
      'dashboard_trash': 'Papierkorb',
      'dashboard_empty_trash': 'Papierkorb leeren',
      'dashboard_lang': 'Spracheinstellungen',
      'dashboard_lang_sub': 'Anzeigesprache der App ändern',
      'dashboard_auto_delete': 'Papierkorb autodelete',
      'dashboard_auto_delete_sub': 'Notizen im Papierkorb dauerhaft löschen',
      'empty_schedule': 'Keine Erinnerungen',
      'empty_schedule_sub': 'Ihr Terminkalender ist heute leer.',
      'schedule_title': 'Smarte Termine',
      'schedule_today': 'HEUTIGE ERINNERUNGEN',
    },
    'es': {
      'tab_notes': 'Notas',
      'tab_schedule': 'Agenda',
      'tab_dashboard': 'Panel',
      'search_hint': 'Buscar notas...',
      'section_pinned': 'FIJADAS',
      'section_all': 'TODAS LAS NOTAS',
      'card_locked': 'Nota bloqueada',
      'card_locked_hint': 'Toque para abrir la caja...',
      'editor_new': 'Nueva Nota',
      'editor_edit': 'Editar Nota',
      'editor_title_hint': 'Título...',
      'editor_content_hint': 'Escribe algo...',
      'todo_title': 'LISTA DE TAREAS',
      'todo_add': 'Agregar tarea',
      'todo_hint': 'Nombre de la tarea...',
      'status_new': 'Borrador nuevo',
      'status_saved': 'Guardado',
      'lock_dialog_title': 'Biometría AuraLock',
      'lock_dialog_sub': 'Bóveda de seguridad bloqueada',
      'lock_dialog_status': 'Toque el sensor de huellas',
      'lock_dialog_scan': 'Leyendo huella...',
      'lock_dialog_match': 'Coincidiendo biometría...',
      'lock_dialog_success': '¡Acceso concedido!',
      'lock_dialog_help': 'Toque la huella para verificar',
      'dashboard_title': 'Análisis de Productividad',
      'dashboard_sub': 'Estadísticas y resumen de notas',
      'dashboard_total': 'Notas totales',
      'dashboard_pinned': 'Notas fijadas',
      'dashboard_archived': 'Notas archivadas',
      'dashboard_locked': 'Notas bloqueadas',
      'dashboard_trash': 'Papelera',
      'dashboard_empty_trash': 'Vaciar papelera',
      'dashboard_lang': 'Ajustes de idioma',
      'dashboard_lang_sub': 'Cambiar el idioma de visualización de la app',
      'dashboard_auto_delete': 'Limpieza automática',
      'dashboard_auto_delete_sub': 'Eliminar permanentemente notas de la papelera',
      'empty_schedule': 'Sin recordatorios',
      'empty_schedule_sub': 'Su agenda está despejada hoy.',
      'schedule_title': 'Agenda inteligente',
      'schedule_today': 'RECORDATORIOS DE HOY',
    },
    'fr': {
      'tab_notes': 'Notes',
      'tab_schedule': 'Agenda',
      'tab_dashboard': 'Tableau',
      'search_hint': 'Rechercher des notes...',
      'section_pinned': 'ÉPINGLÉES',
      'section_all': 'TOUTES LES NOTES',
      'card_locked': 'Note verrouillée',
      'card_locked_hint': 'Toucher pour ouvrir le coffre...',
      'editor_new': 'Nouvelle Note',
      'editor_edit': 'Modifier la note',
      'editor_title_hint': 'Titre de la note...',
      'editor_content_hint': 'Écrire quelque chose...',
      'todo_title': 'LISTE DE TÂCHES',
      'todo_add': 'Ajouter une tâche',
      'todo_hint': 'Nom de la tâche...',
      'status_new': 'Nouveau brouillon',
      'status_saved': 'Enregistré',
      'lock_dialog_title': 'Biométrie AuraLock',
      'lock_dialog_sub': 'Coffre sécurisé verrouillé',
      'lock_dialog_status': 'Touchez le lecteur d\'empreintes',
      'lock_dialog_scan': 'Lecture d\'empreinte...',
      'lock_dialog_match': 'Analyse biométrique...',
      'lock_dialog_success': 'Accès autorisé !',
      'lock_dialog_help': 'Touchez le lecteur pour vérifier',
      'dashboard_title': 'Analyse de productivité',
      'dashboard_sub': 'Statistiques & résumé des notes',
      'dashboard_total': 'Total des notes',
      'dashboard_pinned': 'Notes épinglées',
      'dashboard_archived': 'Notes archivées',
      'dashboard_locked': 'Notes verrouillées',
      'dashboard_trash': 'Corbeille',
      'dashboard_empty_trash': 'Vider la corbeille',
      'dashboard_lang': 'Paramètres de langue',
      'dashboard_lang_sub': 'Changer la langue d\'affichage de l\'application',
      'dashboard_auto_delete': 'Nettoyage auto',
      'dashboard_auto_delete_sub': 'Supprimer définitivement les notes de la corbeille',
      'empty_schedule': 'Aucun rappel',
      'empty_schedule_sub': 'Votre agenda est vide aujourd\'hui.',
      'schedule_title': 'Agenda intelligent',
      'schedule_today': 'RAPPELS DU JOUR',
    },
  };

  static String translate(BuildContext context, String key) {
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final lang = noteProvider.languageCode;

      if (key == 'tab_trash_archive') {
        if (lang == 'en') return 'Trash & Archive';
        if (lang == 'ar') return 'المهملات والأرشيف';
        if (lang == 'zh') return '废纸篓和归档';
        if (lang == 'ru') return 'Корзина и архив';
        if (lang == 'ja') return 'ゴミ箱とアーカイブ';
        if (lang == 'ko') return '휴지통 및 보관';
        if (lang == 'hi') return 'कचरा और संग्रह';
        if (lang == 'de') return 'Papierkorb & Archiv';
        if (lang == 'es') return 'Papelera y archivo';
        if (lang == 'fr') return 'Corbeille & Archive';
        return 'Sampah & Arsip';
      }
      if (key == 'Catatan Tanpa Judul') {
        if (lang == 'en') return 'Untitled Note';
        if (lang == 'ar') return 'ملاحظة بدون عنوان';
        if (lang == 'zh') return '无标题笔记';
        if (lang == 'ru') return 'Заметка без названия';
        if (lang == 'ja') return '無題のメモ';
        if (lang == 'ko') return '제목 없는 메모';
        if (lang == 'hi') return 'बिना शीर्षक वाला नोट';
        if (lang == 'de') return 'Unbenannte Notiz';
        if (lang == 'es') return 'Nota sin título';
        if (lang == 'fr') return 'Note sans titre';
      }
      if (key == 'Catatan kosong...') {
        if (lang == 'en') return 'Empty note...';
        if (lang == 'ar') return 'ملاحظة فارغة...';
        if (lang == 'zh') return '空笔记...';
        if (lang == 'ru') return 'Пустая заметка...';
        if (lang == 'ja') return '空のメモ...';
        if (lang == 'ko') return '빈 메모...';
        if (lang == 'hi') return 'खाली नोट...';
        if (lang == 'de') return 'Leere Notiz...';
        if (lang == 'es') return 'Nota vacía...';
        if (lang == 'fr') return 'Note vide...';
      }
      if (key == 'Kategori Catatan') {
        if (lang == 'en') return 'Notes Categories';
        if (lang == 'ar') return 'فئات الملاحظات';
        if (lang == 'zh') return '笔记类别';
        if (lang == 'ru') return 'Категории заметок';
        if (lang == 'ja') return 'メモのカテゴリ';
        if (lang == 'ko') return '메모 카테고리';
        if (lang == 'hi') return 'नोट श्रेणियां';
        if (lang == 'de') return 'Notizkategorien';
        if (lang == 'es') return 'Categorías de notas';
        if (lang == 'fr') return 'Catégories de notes';
      }
      if (key == 'Tindakan Cepat') {
        if (lang == 'en') return 'Quick Actions';
        if (lang == 'ar') return 'إجراءات سريعة';
        if (lang == 'zh') return '快速操作';
        if (lang == 'ru') return 'Быстрые действия';
        if (lang == 'ja') return 'クイックアクション';
        if (lang == 'ko') return '빠른 작업';
        if (lang == 'hi') return 'त्वरित कार्रवाई';
        if (lang == 'de') return 'Schnelle Aktionen';
        if (lang == 'es') return 'Acciones rápidas';
        if (lang == 'fr') return 'Actions rapides';
      }
      if (key == 'Bakar Tempat Sampah') {
        if (lang == 'en') return 'Empty Trash Bin';
        if (lang == 'ar') return 'إفراغ سلة المهملات';
        if (lang == 'zh') return '清空废纸篓';
        if (lang == 'ru') return 'Очистить корзину';
        if (lang == 'ja') return 'ゴミ箱を空にする';
        if (lang == 'ko') return '휴지통 비우기';
        if (lang == 'hi') return 'कचरा खाली करें';
        if (lang == 'de') return 'Papierkorb leeren';
        if (lang == 'es') return 'Vaciar papelera';
        if (lang == 'fr') return 'Vider la corbeille';
      }
      if (key == 'Aktif') {
        if (lang == 'en') return 'Active';
        if (lang == 'ar') return 'نشط';
        if (lang == 'zh') return '活动';
        if (lang == 'ru') return 'Активные';
        if (lang == 'ja') return 'アクティブ';
        if (lang == 'ko') return '활성';
        if (lang == 'hi') return 'सक्रिय';
        if (lang == 'de') return 'Aktiv';
        if (lang == 'es') return 'Activo';
        if (lang == 'fr') return 'Actif';
      }
      if (key == 'Arsip') {
        if (lang == 'en') return 'Archive';
        if (lang == 'ar') return 'الأرشيف';
        if (lang == 'zh') return '归档';
        if (lang == 'ru') return 'Архив';
        if (lang == 'ja') return 'アーカイブ';
        if (lang == 'ko') return '보관';
        if (lang == 'hi') return 'संग्रह';
        if (lang == 'de') return 'Archiv';
        if (lang == 'es') return 'Archivo';
        if (lang == 'fr') return 'Archive';
      }
      if (key == 'Sampah') {
        if (lang == 'en') return 'Trash';
        if (lang == 'ar') return 'المهملات';
        if (lang == 'zh') return '废纸篓';
        if (lang == 'ru') return 'Корзина';
        if (lang == 'ja') return 'ゴミ箱';
        if (lang == 'ko') return '휴지통';
        if (lang == 'hi') return 'कचरा';
        if (lang == 'de') return 'Papierkorb';
        if (lang == 'es') return 'Papelera';
        if (lang == 'fr') return 'Corbeille';
      }
      if (key == 'e2ee_title') {
        if (lang == 'en') return 'End-to-End Encryption';
        if (lang == 'ar') return 'التشفير التام بين الأطراف';
        if (lang == 'zh') return '端到端加密';
        if (lang == 'ru') return 'Сквозное шифрование';
        if (lang == 'ja') return 'エンドツーエンド暗号化';
        if (lang == 'ko') return '종단간 암호화';
        if (lang == 'hi') return 'एंड-टू-挨ंड एन्क्रिप्शन';
        if (lang == 'de') return 'Ende-zu-Ende-Verschlüsselung';
        if (lang == 'es') return 'Cifrado de extremo a extremo';
        if (lang == 'fr') return 'Chiffrement de bout en bout';
        return 'Enkripsi End-to-End';
      }
      if (key == 'e2ee_desc') {
        if (lang == 'en') return 'Secure your notes with a private passphrase';
        if (lang == 'ar') return 'تأمين ملاحظاتك بعبارة مرور خاصة';
        if (lang == 'zh') return '使用私密密码安全保护您的笔记';
        if (lang == 'ru') return 'Защитите заметки личным паролем';
        if (lang == 'ja') return '個人用パスフレーズでメモを保護';
        if (lang == 'ko') return '개인 비밀번호로 메모 보호';
        if (lang == 'hi') return 'निजी पासफ़्रेज़ के साथ अपने नोट्स सुरक्षित करें';
        if (lang == 'de') return 'Notizen mit Passwort sichern';
        if (lang == 'es') return 'Asegure notas con una contraseña privada';
        if (lang == 'fr') return 'Sécurisez vos notes avec une phrase secrète';
        return 'Amankan catatan Anda dengan kunci sandi pribadi';
      }
      if (key == 'e2ee_active') {
        if (lang == 'en') return 'Encryption Active';
        if (lang == 'ar') return 'التشفير نشط';
        if (lang == 'zh') return '加密已激活';
        if (lang == 'ru') return 'Шифрование активно';
        if (lang == 'ja') return '暗号化が有効';
        if (lang == 'ko') return '암호화 활성화됨';
        if (lang == 'hi') return 'एन्क्रिप्शन सक्रिय';
        if (lang == 'de') return 'Verschlüsselung aktiv';
        if (lang == 'es') return 'Cifrado activo';
        if (lang == 'fr') return 'Chiffrement actif';
        return 'Enkripsi Aktif';
      }
      if (key == 'e2ee_enable') {
        if (lang == 'en') return 'Enable Encryption';
        if (lang == 'ar') return 'تفعيل التشفير';
        if (lang == 'zh') return '启用加密';
        if (lang == 'ru') return 'Включить шифрование';
        if (lang == 'ja') return '暗号化を有効にする';
        if (lang == 'ko') return '암호화 활성화';
        if (lang == 'hi') return 'एन्क्रिप्शन सक्षम करें';
        if (lang == 'de') return 'Verschlüsselung aktivieren';
        if (lang == 'es') return 'Habilitar cifrado';
        if (lang == 'fr') return 'Activer le chiffrement';
        return 'Aktifkan Enkripsi';
      }
      if (key == 'e2ee_disable') {
        if (lang == 'en') return 'Disable Encryption';
        if (lang == 'ar') return 'تعطيل التشفير';
        if (lang == 'zh') return '禁用加密';
        if (lang == 'ru') return 'Выключить шифрование';
        if (lang == 'ja') return '暗号化を無効にする';
        if (lang == 'ko') return '암호화 비활성화';
        if (lang == 'hi') return 'एन्क्रिप्शन अक्षम करें';
        if (lang == 'de') return 'Verschlüsselung deaktivieren';
        if (lang == 'es') return 'Deshabilitar cifrado';
        if (lang == 'fr') return 'Désactiver le chiffrement';
        return 'Nonaktifkan Enkripsi';
      }
      if (key == 'e2ee_pass_hint') {
        if (lang == 'en') return 'Enter passphrase...';
        if (lang == 'ar') return 'أدخل عبارة المرور...';
        if (lang == 'zh') return '输入密码...';
        if (lang == 'ru') return 'Введите пароль...';
        if (lang == 'ja') return 'パスフレーズを入力...';
        if (lang == 'ko') return '비밀번호 입력...';
        if (lang == 'hi') return 'पासफ़्रेज़ दर्ज करें...';
        if (lang == 'de') return 'Passwort eingeben...';
        if (lang == 'es') return 'Introducir contraseña...';
        if (lang == 'fr') return 'Entrez la phrase secrète...';
        return 'Masukkan kata sandi...';
      }

      if (key == 'sync_title') {
        if (lang == 'en') return 'Google Cloud Sync';
        if (lang == 'ar') return 'مزامنة جوجل السحابية';
        if (lang == 'zh') return '谷歌云同步';
        if (lang == 'ru') return 'Облако Google Sync';
        if (lang == 'ja') return 'Googleクラウド同期';
        if (lang == 'ko') return 'Google 클라우드 동기화';
        if (lang == 'hi') return 'गूगल क्लाउड सिंक';
        if (lang == 'de') return 'Google Cloud-Synchronisierung';
        if (lang == 'es') return 'Sincronización de Google';
        if (lang == 'fr') return 'Synchronisation Google';
        return 'Google Cloud Sync';
      }
      if (key == 'sync_desc') {
        if (lang == 'en') return 'Backup your notes online';
        if (lang == 'ar') return 'نسخ ملاحظاتك احتياطيًا عبر الإنترنت';
        if (lang == 'zh') return '在线备份您的笔记';
        if (lang == 'ru') return 'Резервное копирование заметок онлайн';
        if (lang == 'ja') return 'オンラインでメモをバックアップ';
        if (lang == 'ko') return '온라인으로 메모 백업';
        if (lang == 'hi') return 'अपने नोट्स ऑनलाइन बैकअप करें';
        if (lang == 'de') return 'Sichern Sie Ihre Notizen online';
        if (lang == 'es') return 'Copia de seguridad de notas en línea';
        if (lang == 'fr') return 'Sauvegardez vos notes en ligne';
        return 'Cadangkan catatan Anda secara online';
      }
      if (key == 'sync_now') {
        if (lang == 'en') return 'Sync Now';
        if (lang == 'ar') return 'مزامنة الآن';
        if (lang == 'zh') return '立即同步';
        if (lang == 'ru') return 'Синхронизировать';
        if (lang == 'ja') return '今すぐ同期';
        if (lang == 'ko') return '지금 동기화';
        if (lang == 'hi') return 'अभी सिंक करें';
        if (lang == 'de') return 'Jetzt synchronisieren';
        if (lang == 'es') return 'Sincronizar ahora';
        if (lang == 'fr') return 'Synchroniser maintenant';
        return 'Sinkronisasikan Sekarang';
      }
      if (key == 'sync_google') {
        if (lang == 'en') return 'Sign in with Google';
        if (lang == 'ar') return 'تسجيل الدخول باستخدام جوجل';
        if (lang == 'zh') return '使用 Google 登录';
        if (lang == 'ru') return 'Войти через Google';
        if (lang == 'ja') return 'Googleでサインイン';
        if (lang == 'ko') return 'Google로 로그인';
        if (lang == 'hi') return 'गूगल से साइन इन करें';
        if (lang == 'de') return 'Mit Google anmelden';
        if (lang == 'es') return 'Iniciar sesión con Google';
        if (lang == 'fr') return 'Se connecter avec Google';
        return 'Masuk dengan Google';
      }
      if (key == 'sync_active') {
        if (lang == 'en') return 'Sync Active';
        if (lang == 'ar') return 'المزامنة نشطة';
        if (lang == 'zh') return '同步已激活';
        if (lang == 'ru') return 'Синхронизация активна';
        if (lang == 'ja') return '同期がアクティブ';
        if (lang == 'ko') return '동기화 활성화됨';
        if (lang == 'hi') return 'सिंक सक्रिय';
        if (lang == 'de') return 'Synchronisierung aktiv';
        if (lang == 'es') return 'Sincronización activa';
        if (lang == 'fr') return 'Synchro active';
        return 'Sinkronisasi Aktif';
      }
      if (key == 'sync_disconnect') {
        if (lang == 'en') return 'Disconnect Account';
        if (lang == 'ar') return 'قطع اتصال الحساب';
        if (lang == 'zh') return '断开账户连接';
        if (lang == 'ru') return 'Отключить аккаунт';
        if (lang == 'ja') return 'アカウントを切断';
        if (lang == 'ko') return '계정 연결 해제';
        if (lang == 'hi') return 'खाता अलग करें';
        if (lang == 'de') return 'Konto trennen';
        if (lang == 'es') return 'Desconectar cuenta';
        if (lang == 'fr') return 'Déconnecter le compte';
        return 'Putuskan Hubungan';
      }
      if (key == 'sync_connecting') {
        if (lang == 'en') return 'Connecting to Google Drive...';
        if (lang == 'ar') return 'جاري الاتصال بجوجل درايف...';
        if (lang == 'zh') return '正在连接到 Google 云端硬盘...';
        if (lang == 'ru') return 'Подключение к Google Диску...';
        if (lang == 'ja') return 'Googleドライブに接続中...';
        if (lang == 'ko') return 'Google 드라이브에 연결 중...';
        if (lang == 'hi') return 'गूगल ड्राइव से जुड़ रहा है...';
        if (lang == 'de') return 'Verbindung mit Google Drive...';
        if (lang == 'es') return 'Conectando a Google Drive...';
        if (lang == 'fr') return 'Connexion à Google Drive...';
        return 'Menghubungkan ke Google Drive...';
      }
      if (key == 'sync_success') {
        if (lang == 'en') return 'Sync Completed Successfully!';
        if (lang == 'ar') return 'تمت المزامنة بنجاح!';
        if (lang == 'zh') return '同步成功完成！';
        if (lang == 'ru') return 'Синхронизация завершена!';
        if (lang == 'ja') return '同期が正常に完了しました！';
        if (lang == 'ko') return '동기화가 성공적으로 완료되었습니다!';
        if (lang == 'hi') return 'सिंक सफलतापूर्वक पूरा हुआ!';
        if (lang == 'de') return 'Synchronisation erfolgreich!';
        if (lang == 'es') return '¡Sincronización completada!';
        if (lang == 'fr') return 'Synchro réussie !';
        return 'Sinkronisasi Berhasil!';
      }
      if (key == 'sync_uploading') {
        if (lang == 'en') return 'Uploading database to cloud...';
        if (lang == 'ar') return 'جاري رفع قاعدة البيانات إلى السحابة...';
        if (lang == 'zh') return '正在将数据库上传到云端...';
        if (lang == 'ru') return 'Загрузка базы данных в облако...';
        if (lang == 'ja') return 'データベースをクラウドにアップロード中...';
        if (lang == 'ko') return '데이터베이스를 클라우드에 업로드 중...';
        if (lang == 'hi') return 'डेटाबेस क्लाउड पर अपलोड हो रहा है...';
        if (lang == 'de') return 'Datenbank wird in die Cloud geladen...';
        if (lang == 'es') return 'Subiendo base de datos a la nube...';
        if (lang == 'fr') return 'Téléchargement de la base de données...';
        return 'Mengunggah database ke cloud...';
      }
      if (key == 'sync_last') {
        if (lang == 'en') return 'Last synced: ';
        if (lang == 'ar') return 'آخر مزامنة: ';
        if (lang == 'zh') return '最后同步时间：';
        if (lang == 'ru') return 'Синхронизировано: ';
        if (lang == 'ja') return '最終同期：';
        if (lang == 'ko') return '최근 동기화: ';
        if (lang == 'hi') return 'अंतिम सिंक: ';
        if (lang == 'de') return 'Zuletzt synchronisiert: ';
        if (lang == 'es') return 'Última sincronización: ';
        if (lang == 'fr') return 'Dernière synchro : ';
        return 'Terakhir sinkronisasi: ';
      }

      return _translations[lang]?[key] ?? _translations['id']?[key] ?? key;
    } catch (_) {
      return _translations['id']?[key] ?? key;
    }
  }

  static String translateReactive(BuildContext context, String key) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final lang = noteProvider.languageCode;

    if (key == 'tab_trash_archive') {
      if (lang == 'en') return 'Trash & Archive';
      if (lang == 'ar') return 'المهملات والأرشيف';
      if (lang == 'zh') return '废纸篓和归档';
      if (lang == 'ru') return 'Корзина и архив';
      if (lang == 'ja') return 'ゴミ箱とアーカイブ';
      if (lang == 'ko') return '휴지통 및 보관';
      if (lang == 'hi') return 'कचरा और संग्रह';
      if (lang == 'de') return 'Papierkorb & Archiv';
      if (lang == 'es') return 'Papelera y archivo';
      if (lang == 'fr') return 'Corbeille & Archive';
      return 'Sampah & Arsip';
    }
    if (key == 'Catatan Tanpa Judul') {
      if (lang == 'en') return 'Untitled Note';
      if (lang == 'ar') return 'ملاحظة بدون عنوان';
      if (lang == 'zh') return '无标题笔记';
      if (lang == 'ru') return 'Заметка без названия';
      if (lang == 'ja') return '無題のメモ';
      if (lang == 'ko') return '제목 없는 메모';
      if (lang == 'hi') return 'बिना शीर्षक वाला नोट';
      if (lang == 'de') return 'Unbenannte Notiz';
      if (lang == 'es') return 'Nota sin título';
      if (lang == 'fr') return 'Note sans titre';
    }
    if (key == 'Catatan kosong...') {
      if (lang == 'en') return 'Empty note...';
      if (lang == 'ar') return 'ملاحظة فارغة...';
      if (lang == 'zh') return '空笔记...';
      if (lang == 'ru') return 'Пустая заметка...';
      if (lang == 'ja') return '空のメモ...';
      if (lang == 'ko') return '빈 메모...';
      if (lang == 'hi') return 'खाली नोट...';
      if (lang == 'de') return 'Leere Notiz...';
      if (lang == 'es') return 'Nota vacía...';
      if (lang == 'fr') return 'Note vide...';
    }
    if (key == 'Kategori Catatan') {
      if (lang == 'en') return 'Notes Categories';
      if (lang == 'ar') return 'فئات الملاحظات';
      if (lang == 'zh') return '笔记类别';
      if (lang == 'ru') return 'Категории заметок';
      if (lang == 'ja') return 'メモのカテゴリ';
      if (lang == 'ko') return '메모 카테고리';
      if (lang == 'hi') return 'नोट श्रेणियां';
      if (lang == 'de') return 'Notizkategorien';
      if (lang == 'es') return 'Categorías de notas';
      if (lang == 'fr') return 'Catégories de notes';
    }
    if (key == 'Tindakan Cepat') {
      if (lang == 'en') return 'Quick Actions';
      if (lang == 'ar') return 'إجراءات سريعة';
      if (lang == 'zh') return '快速操作';
      if (lang == 'ru') return 'Быстрые действия';
      if (lang == 'ja') return 'クイックアクション';
      if (lang == 'ko') return '빠른 작업';
      if (lang == 'hi') return 'त्वरित कार्रवाई';
      if (lang == 'de') return 'Schnelle Aktionen';
      if (lang == 'es') return 'Acciones rápidas';
      if (lang == 'fr') return 'Actions rapides';
    }
    if (key == 'Bakar Tempat Sampah') {
      if (lang == 'en') return 'Empty Trash Bin';
      if (lang == 'ar') return 'إفraغ سلة المهملات';
      if (lang == 'zh') return '清空废纸篓';
      if (lang == 'ru') return 'Очистить корзину';
      if (lang == 'ja') return 'ゴミ箱を空にする';
      if (lang == 'ko') return '휴지통 비우기';
      if (lang == 'hi') return 'कचरा खाली करें';
      if (lang == 'de') return 'Papierkorb leeren';
      if (lang == 'es') return 'Vaciar papelera';
      if (lang == 'fr') return 'Vider la corbeille';
    }
    if (key == 'Aktif') {
      if (lang == 'en') return 'Active';
      if (lang == 'ar') return 'نشط';
      if (lang == 'zh') return '活动';
      if (lang == 'ru') return 'Активные';
      if (lang == 'ja') return 'アクティブ';
      if (lang == 'ko') return '활성';
      if (lang == 'hi') return 'सक्रिय';
      if (lang == 'de') return 'Aktiv';
      if (lang == 'es') return 'Activo';
      if (lang == 'fr') return 'Actif';
    }
    if (key == 'Arsip') {
      if (lang == 'en') return 'Archive';
      if (lang == 'ar') return 'الأرشيف';
      if (lang == 'zh') return '归档';
      if (lang == 'ru') return 'Архив';
      if (lang == 'ja') return 'アーカイブ';
      if (lang == 'ko') return '보관';
      if (lang == 'hi') return 'संग्रह';
      if (lang == 'de') return 'Archiv';
      if (lang == 'es') return 'Archivo';
      if (lang == 'fr') return 'Archive';
    }
    if (key == 'Sampah') {
      if (lang == 'en') return 'Trash';
      if (lang == 'ar') return 'المهملات';
      if (lang == 'zh') return '废纸篓';
      if (lang == 'ru') return 'Корзина';
      if (lang == 'ja') return 'ゴミ箱';
      if (lang == 'ko') return '휴지통';
      if (lang == 'hi') return 'कचरा';
      if (lang == 'de') return 'Papierkorb';
      if (lang == 'es') return 'Papelera';
      if (lang == 'fr') return 'Corbeille';
    }
    if (key == 'e2ee_title') {
      if (lang == 'en') return 'End-to-End Encryption';
      if (lang == 'ar') return 'التشفير التام بين الأطراف';
      if (lang == 'zh') return '端到端加密';
      if (lang == 'ru') return 'Сквозное шифрование';
      if (lang == 'ja') return 'エンドツーエンド暗号化';
      if (lang == 'ko') return '종단간 암호화';
      if (lang == 'hi') return 'एंड-to-एंड एन्क्रिप्शन';
      if (lang == 'de') return 'Ende-zu-Ende-Verschlüsselung';
      if (lang == 'es') return 'Cifrado de extremo a extremo';
      if (lang == 'fr') return 'Chiffrement de bout en bout';
      return 'Enkripsi End-to-End';
    }
    if (key == 'e2ee_desc') {
      if (lang == 'en') return 'Secure your notes with a private passphrase';
      if (lang == 'ar') return 'تأمين ملاحظاتك بعبارة مرور خاصة';
      if (lang == 'zh') return '使用私密密码安全保护您的笔记';
      if (lang == 'ru') return 'Защитите заметки личным паролем';
      if (lang == 'ja') return '個人用パスフレーズでメモを保護';
      if (lang == 'ko') return '개인 비밀번호로 메모 보호';
      if (lang == 'hi') return 'निजी पासफ़्रेज़ के साथ अपने नोट्स सुरक्षित करें';
      if (lang == 'de') return 'Notizen mit Passwort sichern';
      if (lang == 'es') return 'Asegure notas con una contraseña privada';
      if (lang == 'fr') return 'Sécurisez vos notes avec une phrase secrète';
      return 'Amankan catatan Anda dengan kunci sandi pribadi';
    }
    if (key == 'e2ee_active') {
      if (lang == 'en') return 'Encryption Active';
      if (lang == 'ar') return 'التشفير نشط';
      if (lang == 'zh') return '加密已激活';
      if (lang == 'ru') return 'Шифрование активно';
      if (lang == 'ja') return '暗号化が有効';
      if (lang == 'ko') return '암호화 활성화됨';
      if (lang == 'hi') return 'एन्क्रिप्शन सक्रिय';
      if (lang == 'de') return 'Verschlüsselung aktiv';
      if (lang == 'es') return 'Cifrado activo';
      if (lang == 'fr') return 'Chiffrement actif';
      return 'Enkripsi Aktif';
    }
    if (key == 'e2ee_enable') {
      if (lang == 'en') return 'Enable Encryption';
      if (lang == 'ar') return 'تفعيل التشفير';
      if (lang == 'zh') return '启用加密';
      if (lang == 'ru') return 'Включить шифрование';
      if (lang == 'ja') return '暗号化を有効にする';
      if (lang == 'ko') return '암호화 활성화';
      if (lang == 'hi') return 'एन्क्रिप्शन सक्षम करें';
      if (lang == 'de') return 'Verschlüsselung aktivieren';
      if (lang == 'es') return 'Habilitar cifrado';
      if (lang == 'fr') return 'Activer le chiffrement';
      return 'Aktifkan Enkripsi';
    }
    if (key == 'e2ee_disable') {
      if (lang == 'en') return 'Disable Encryption';
      if (lang == 'ar') return 'تعطيل التشفير';
      if (lang == 'zh') return '禁用加密';
      if (lang == 'ru') return 'Выключить шифрование';
      if (lang == 'ja') return '暗号化を無効にする';
      if (lang == 'ko') return '암호화 비활성화';
      if (lang == 'hi') return 'एन्क्रिप्शन अक्षम करें';
      if (lang == 'de') return 'Verschlüsselung deaktivieren';
      if (lang == 'es') return 'Deshabilitar cifrado';
      if (lang == 'fr') return 'Désactiver le chiffrement';
      return 'Nonaktifkan Enkripsi';
    }
    if (key == 'e2ee_pass_hint') {
      if (lang == 'en') return 'Enter passphrase...';
      if (lang == 'ar') return 'أدخل عبارة المرور...';
      if (lang == 'zh') return '输入密码...';
      if (lang == 'ru') return 'Введите пароль...';
      if (lang == 'ja') return 'パスフレーズを入力...';
      if (lang == 'ko') return '비밀번호 입력...';
      if (lang == 'hi') return 'पासफ़्रेज़ दर्ज करें...';
      if (lang == 'de') return 'Passwort eingeben...';
      if (lang == 'es') return 'Introducir contraseña...';
      if (lang == 'fr') return 'Entrez la phrase secrète...';
      return 'Masukkan kata sandi...';
    }

    if (key == 'sync_title') {
      if (lang == 'en') return 'Google Cloud Sync';
      if (lang == 'ar') return 'مزامنة جوجل السحابية';
      if (lang == 'zh') return '谷歌云同步';
      if (lang == 'ru') return 'Облако Google Sync';
      if (lang == 'ja') return 'Googleクラウド同期';
      if (lang == 'ko') return 'Google 클라우드 동기화';
      if (lang == 'hi') return 'गूगल क्लाउड सिंक';
      if (lang == 'de') return 'Google Cloud-Synchronisierung';
      if (lang == 'es') return 'Sincronización de Google';
      if (lang == 'fr') return 'Synchronisation Google';
      return 'Google Cloud Sync';
    }
    if (key == 'sync_desc') {
      if (lang == 'en') return 'Backup your notes online';
      if (lang == 'ar') return 'نسخ ملاحظاتك احتياطيًا عبر الإنترنت';
      if (lang == 'zh') return '在线备份您的笔记';
      if (lang == 'ru') return 'Резервное копирование заметок онлайн';
      if (lang == 'ja') return 'オンラインでメモをバックアップ';
      if (lang == 'ko') return '온라인으로 메모 백업';
      if (lang == 'hi') return 'अपने नोट्स ऑनलाइन बैकअप करें';
      if (lang == 'de') return 'Sichern Sie Ihre Notizen online';
      if (lang == 'es') return 'Copia de seguridad de notas en línea';
      if (lang == 'fr') return 'Sauvegardez vos notes en ligne';
      return 'Cadangkan catatan Anda secara online';
    }
    if (key == 'sync_now') {
      if (lang == 'en') return 'Sync Now';
      if (lang == 'ar') return 'مزامنة الآن';
      if (lang == 'zh') return '立即同步';
      if (lang == 'ru') return 'Синхронизировать';
      if (lang == 'ja') return '今すぐ同期';
      if (lang == 'ko') return '지금 동기화';
      if (lang == 'hi') return 'अभी सिंक करें';
      if (lang == 'de') return 'Jetzt synchronisieren';
      if (lang == 'es') return 'Sincronizar ahora';
      if (lang == 'fr') return 'Synchroniser maintenant';
      return 'Sinkronisasikan Sekarang';
    }
    if (key == 'sync_google') {
      if (lang == 'en') return 'Sign in with Google';
      if (lang == 'ar') return 'تسجيل الدخول باستخدام جوجل';
      if (lang == 'zh') return '使用 Google 登录';
      if (lang == 'ru') return 'Войти через Google';
      if (lang == 'ja') return 'Googleでサインイン';
      if (lang == 'ko') return 'Google로 로그인';
      if (lang == 'hi') return 'गूगल से साइन इन करें';
      if (lang == 'de') return 'Mit Google anmelden';
      if (lang == 'es') return 'Iniciar sesión con Google';
      if (lang == 'fr') return 'Se connecter avec Google';
      return 'Masuk dengan Google';
    }
    if (key == 'sync_active') {
      if (lang == 'en') return 'Sync Active';
      if (lang == 'ar') return 'المزامنة نشطة';
      if (lang == 'zh') return '同步已激活';
      if (lang == 'ru') return 'Синхронизация активна';
      if (lang == 'ja') return '同期がアクティブ';
      if (lang == 'ko') return '동기화 활성화됨';
      if (lang == 'hi') return 'सिंक सक्रिय';
      if (lang == 'de') return 'Synchronisierung aktiv';
      if (lang == 'es') return 'Sincronización activa';
      if (lang == 'fr') return 'Synchro active';
      return 'Sinkronisasi Aktif';
    }
    if (key == 'sync_disconnect') {
      if (lang == 'en') return 'Disconnect Account';
      if (lang == 'ar') return 'قطع اتصال الحساب';
      if (lang == 'zh') return '断开账户连接';
      if (lang == 'ru') return 'Отключить аккаунт';
      if (lang == 'ja') return 'アカウントを切断';
      if (lang == 'ko') return '계정 연결 해제';
      if (lang == 'hi') return 'खाता अलग करें';
      if (lang == 'de') return 'Konto trennen';
      if (lang == 'es') return 'Desconectar cuenta';
      if (lang == 'fr') return 'Déconnecter le compte';
      return 'Putuskan Hubungan';
    }
    if (key == 'sync_connecting') {
      if (lang == 'en') return 'Connecting to Google Drive...';
      if (lang == 'ar') return 'جاري الاتصال بجوجل درايف...';
      if (lang == 'zh') return '正在连接到 Google 云端硬盘...';
      if (lang == 'ru') return 'Подключение к Google Диску...';
      if (lang == 'ja') return 'Googleドライブに接続中...';
      if (lang == 'ko') return 'Google 드라이브에 연결 중...';
      if (lang == 'hi') return 'गूगल ड्राइव से जुड़ रहा है...';
      if (lang == 'de') return 'Verbindung mit Google Drive...';
      if (lang == 'es') return 'Conectando a Google Drive...';
      if (lang == 'fr') return 'Connexion à Google Drive...';
      return 'Menghubungkan ke Google Drive...';
    }
    if (key == 'sync_success') {
      if (lang == 'en') return 'Sync Completed Successfully!';
      if (lang == 'ar') return 'تمت المزامنة بنجاح!';
      if (lang == 'zh') return '同步成功完成！';
      if (lang == 'ru') return 'Синхронизация завершена!';
      if (lang == 'ja') return '同期が正常に完了しました！';
      if (lang == 'ko') return '동기화가 성공적으로 완료되었습니다!';
      if (lang == 'hi') return 'सिंक सफलतापूर्वक पूरा हुआ!';
      if (lang == 'de') return 'Synchronisation erfolgreich!';
      if (lang == 'es') return '¡Sincronización completada!';
      if (lang == 'fr') return 'Synchro réussie !';
      return 'Sinkronisasi Berhasil!';
    }
    if (key == 'sync_uploading') {
      if (lang == 'en') return 'Uploading database to cloud...';
      if (lang == 'ar') return 'جاري رفع قاعدة البيانات إلى السحابة...';
      if (lang == 'zh') return '正在将数据库上传到云端...';
      if (lang == 'ru') return 'Загрузка базы данных в облако...';
      if (lang == 'ja') return 'データベースをクラウドにアップロード中...';
      if (lang == 'ko') return '데이터베이스를 클라우드에 업로드 중...';
      if (lang == 'hi') return 'डेटाबेस क्लाउड पर अपलोड हो रहा है...';
      if (lang == 'de') return 'Datenbank wird in die Cloud geladen...';
      if (lang == 'es') return 'Subiendo base de datos a la nube...';
      if (lang == 'fr') return 'Téléchargement de la base de données...';
      return 'Mengunggah database ke cloud...';
    }
    if (key == 'sync_last') {
      if (lang == 'en') return 'Last synced: ';
      if (lang == 'ar') return 'آخر مزامنة: ';
      if (lang == 'zh') return '最后同步时间：';
      if (lang == 'ru') return 'Синхронизировано: ';
      if (lang == 'ja') return '最終同期：';
      if (lang == 'ko') return '최근 동기화: ';
      if (lang == 'hi') return 'अंतिम सिंक: ';
      if (lang == 'de') return 'Zuletzt synchronisiert: ';
      if (lang == 'es') return 'Última sincronización: ';
      if (lang == 'fr') return 'Dernière synchro : ';
      return 'Terakhir sinkronisasi: ';
    }

    return _translations[lang]?[key] ?? _translations['id']?[key] ?? key;
  }
}
