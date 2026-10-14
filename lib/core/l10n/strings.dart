import 'package:flutter/widgets.dart';

import '../../services/app_settings.dart';

/// Makes the selected UI language available to the widget tree.
///
/// Wrapped around the Navigator in `main.dart`. Any widget that calls
/// [tr] depends on it, so changing the language in Settings rebuilds
/// every visible screen immediately.
class LangScope extends InheritedWidget {
  final String lang;

  const LangScope({super.key, required this.lang, required super.child});

  static String of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LangScope>();
    return scope?.lang ?? AppSettings.instance.language;
  }

  @override
  bool updateShouldNotify(LangScope oldWidget) => oldWidget.lang != lang;
}

/// Translates a UI string key into the selected language ('am' or 'en').
///
/// The *content* of the app (Ge'ez / Amharic / English readings) is not
/// affected; this only covers menus, titles, buttons and messages.
String tr(BuildContext context, String key) => trLang(LangScope.of(context), key);

/// Same as [tr] but without a [BuildContext] (used by notifications).
String trLang(String lang, String key) {
  final entry = _strings[key];
  if (entry == null) return key;
  return lang == 'en' ? entry[1] : entry[0];
}

// key: [Amharic, English]
const Map<String, List<String>> _strings = {
  // Navigation
  'nav_today': ['የዛሬ', 'Today'],
  'nav_daily': ['የየእለት', 'Daily'],
  'nav_teachings': ['ትምህርቶች', 'Teachings'],
  'nav_monthly': ['የወር', 'Monthly'],
  'nav_mahlet': ['ማኅሌት', 'Mahlet'],
  'nav_search': ['ፍለጋ', 'Search'],
  'nav_more': ['ተጨማሪ', 'More'],
  'nav_seasonal': ['የዘመን', 'Seasonal'],
  'nav_feasts': ['በዓላት', 'Feasts'],
  'nav_audio': ['ድምፅ ቤተ መጻሕፍት', 'Audio library'],
  'drawer_subtitle': ['የቤተ ክርስቲያን ንባባት', 'Gitsawe Lectionary'],

  // Screen titles
  'title_today': ['የዕለቱ ግጻዌ', "Today's Gitsawe"],
  'title_daily': ['የየእለቱ ግጻዌ ማውጫ', 'Daily Gitsawe index'],
  'title_daily_detail': ['የዕለት ግጻዌ', 'Daily reading'],
  'title_monthly': ['የወር ግጻዌ', 'Monthly Gitsawe'],
  'title_seasonal': ['የዘመን ግጻዌ', 'Seasonal Gitsawe'],
  'title_feasts': ['በዓላት', 'Feasts'],
  'title_mahlet': ['ሥርዓተ ማኅሌት', 'Mahlet service'],
  'title_teachings': ['ትምህርቶች', 'Teachings'],
  'title_search': ['ፍለጋ', 'Search'],
  'title_more': ['ተጨማሪ', 'More'],
  'title_audio': ['ድምፅ ቤተ መጻሕፍት', 'Audio library'],
  'title_settings': ['ቅንብሮች', 'Settings'],
  'title_bookmarks': ['የተቀመጡ ንባባት', 'Bookmarks'],
  'title_about': ['ስለ መተግበሪያው', 'About'],
  'title_privacy': ['የግላዊነት ፖሊሲ', 'Privacy policy'],
  'title_missed': ['ያመለጡ ንባባት', 'Missed readings'],

  // Common
  'retry': ['እንደገና ሞክር', 'Retry'],
  'loading_error': ['መረጃውን መጫን አልተቻለም።', 'Could not load the data.'],
  'listen': ['አድምጥ', 'Listen'],
  'stop': ['አቁም', 'Pause'],
  'now_playing': ['አሁን በመጫወት ላይ', 'Now playing'],
  'skip': ['ዝለል', 'Skip'],
  'next': ['ቀጥል', 'Next'],
  'start': ['ጀምር', 'Get started'],
  'tracks': ['ትራኮች', 'tracks'],
  'sections': ['ክፍሎች', 'sections'],
  'source': ['ምንጭ', 'Source'],
  'hymn': ['መዝሙር', 'Hymn'],
  'close': ['ዝጋ', 'Close'],

  // Today
  'today': ['ዛሬ', 'Today'],
  'prev_day': ['ያለፈው ቀን', 'Previous day'],
  'next_day': ['የሚቀጥለው ቀን', 'Next day'],
  'back_to_today': ['ወደ ዛሬ ተመለስ', 'Back to today'],
  'no_reading_today': [
    'ለዚህ ቀን የተለየ የግጻዌ ንባብ በመተግበሪያው ውስጥ የለም። ከታች የስንክሳር ንባብ ይገኛል።',
    'There is no dedicated Gitsawe reading for this day in the app yet. The Synaxarium reading is shown below.'
  ],
  'today_load_error': ['የዛሬን ንባብ መጫን አልተቻለም።', "Couldn't load today's reading."],

  // Reading view
  'sinksar': ['ስንክሳር', 'Synaxarium'],
  'sinksar_reading': ['ስንክሳር ንባብ', 'Synaxarium reading'],
  'negh_readings': ['ንባባተ ነግህ', 'Morning readings'],
  'kidassie_readings': ['ንባባተ ቅዳሴ', 'Liturgy readings'],
  'kidassie': ['ቅዳሴ', 'Liturgy'],
  'share_sinksar': ['ስንክሳር አጋራ', 'Share Synaxarium'],
  'share_negh': ['ንባባተ ነግህ አጋራ', 'Share morning readings'],
  'play_all': ['ንባባቱን በተራ አድምጥ', 'Play all readings'],
  'bookmark': ['አስቀምጥ', 'Bookmark reading'],
  'remove_bookmark': ['ከተቀመጡት አስወግድ', 'Remove bookmark'],
  'share_reading': ['አጋራ', 'Share reading'],
  'stat_daily': ['የዕለት ግጻዌ', 'Daily'],
  'stat_monthly': ['የወር ግጻዌ', 'Monthly'],
  'stat_seasonal': ['የዘመን ግጻዌ', 'Seasonal'],
  'stat_feasts': ['በዓላት', 'Feasts'],
  'stat_mahlet': ['ማኅሌት', 'Mahlet'],
  'part_msbak': ['ምስባክ', 'Psalm (Misbak)'],
  'part_first': ['ቀዳማይ ንባብ (፩ኛ ዲያቆን)', 'First reading (1st deacon)'],
  'part_second': ['ካልዓይ ንባብ (፪ኛ ዲያቆን)', 'Second reading (2nd deacon)'],
  'part_kahn': ['የ፪ኛው ካህን ንባብ', 'Reading of the 2nd priest'],
  'part_wengel': ['ወንጌል', 'Gospel'],
  'tag_geez': ['ግዕዝ', "Ge'ez"],
  'tag_amharic': ['አማርኛ', 'Amharic'],
  'tag_english': ['English', 'English'],

  // Lists
  'no_daily': ['ምንም የዕለት ግጻዌ አልተገኘም።', 'No daily readings available.'],
  'no_monthly': ['ምንም የወር ግጻዌ አልተገኘም።', 'No monthly readings available.'],
  'no_seasonal': ['ምንም የዘመን ግጻዌ አልተገኘም።', 'No seasonal readings available.'],
  'no_feasts': ['ምንም በዓል አልተገኘም።', 'No feasts available.'],
  'no_mahlet': ['ምንም ማኅሌት አልተገኘም።', 'No Mahlet available.'],
  'no_teachings': ['ምንም ትምህርት አልተገኘም።', 'No teachings available.'],
  'daily_details': ['የዕለት ግጻዌ', 'Daily reading'],

  // Search
  'search_hint': ['ርዕስ፣ ስንክሳር ወይም ቃል ይፈልጉ', 'Search titles, synaxarium or verses'],
  'search_empty': ['ንባብ ለማግኘት ቃል ያስገቡ', 'Type a word to find readings'],
  'search_none': ['ምንም ውጤት አልተገኘም', 'No results found'],
  'search_results': ['ውጤቶች', 'results'],

  // Bookmarks
  'no_bookmarks': ['ገና ምንም አልተቀመጠም', 'No bookmarks yet'],
  'no_bookmarks_hint': ['የተቀመጡ ንባባት እዚህ ይታያሉ', 'Your saved readings will appear here'],
  'bookmark_missing': ['ይህ ንባብ አልተገኘም', 'This reading could not be found'],

  // Missed
  'missed_updates': ['ያመለጡ ንባባት', 'Missed readings'],
  'all_caught_up': ['ሁሉንም ንባባት አንብበዋል።', "You're all caught up."],
  'reading_fallback_title': ['ንባብ', 'Reading'],

  // More
  'more_widget': ['የመነሻ ገጽ መግብር ጨምር', 'Add home screen widget'],
  'more_widget_sub': ['ከተለያዩ የግጻዌ መግብሮች ይምረጡ', 'Choose from several Gitsawe widgets'],
  'widget_pick': ['የመግብር ዓይነት ይምረጡ', 'Choose a widget type'],
  'widget_reading': ['የዕለቱ ንባብ እና ስንክሳር', 'Reading & Synaxarium'],
  'widget_verse': ['የዕለቱ ምስባክ', 'Verse of the day'],
  'widget_medium': ['መካከለኛ ማጠቃለያ', 'Medium summary'],
  'widget_compact': ['ጥቅል ማጠቃለያ', 'Compact summary'],
  'widget_requested': ['መግብሩን ወደ መነሻ ገጽ ለመጨመር ተጠይቋል', 'Widget requested — confirm on your home screen'],
  'widget_failed': ['መግብር መጨመር አልተቻለም። በመነሻ ገጽ ላይ በረጅሙ ይጫኑ።', "Couldn't add the widget. Long-press your home screen instead."],
  'share_app': ['መተግበሪያውን አጋራ', 'Share Gitsawe app'],
  'share_app_text': [
    'ግጻዌ — የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተ ክርስቲያን የዕለት ንባባት፣ ማኅሌት እና ስንክሳር።',
    'Gitsawe — Ethiopian Orthodox daily readings, hymns, and liturgy.'
  ],
  'share_image_failed': ['ምስሉን መፍጠር አልተቻለም።', 'Could not create a shareable image.'],
  'audio_error': ['ድምፁን ማጫወት አልተቻለም። ኢንተርኔትዎን ያረጋግጡ።', "Couldn't play the audio. Check your internet connection."],
  'copied': ['መጋራት አልተቻለም። ጽሑፉ ተገልብጧል።', 'Sharing is unavailable. Text copied instead.'],
  'clear_cache': ['መረጃ እንደገና ጫን', 'Reload data'],
  'clear_cache_sub': ['የንባብ መረጃውን እንደገና ከመተግበሪያው ይጭናል', 'Reloads the bundled reading data'],
  'cache_cleared': ['መረጃው እንደገና ተጭኗል', 'Data reloaded'],

  // Settings
  'settings_general': ['አጠቃላይ', 'General'],
  'settings_appearance': ['መልክ', 'Appearance'],
  'settings_storage': ['ማከማቻ', 'Storage'],
  'settings_language': ['ቋንቋ', 'Language'],
  'settings_notifications': ['የዕለት ንባብ ማሳሰቢያ', 'Daily reading reminder'],
  'settings_reminder_time': ['የማሳሰቢያ ሰዓት', 'Reminder time'],
  'settings_on': ['በርቷል', 'On'],
  'settings_off': ['ጠፍቷል', 'Off'],
  'settings_font': ['የጽሑፍ መጠን', 'Text size'],
  'font_small': ['ትንሽ', 'Small'],
  'font_medium': ['መካከለኛ', 'Medium'],
  'font_medium_large': ['መካከለኛ-ትልቅ', 'Medium large'],
  'font_large': ['ትልቅ', 'Large'],
  'font_decrease': ['ጽሑፍ ቀንስ', 'Decrease text size'],
  'font_increase': ['ጽሑፍ ጨምር', 'Increase text size'],
  'settings_dark': ['ጥቁር ገጽታ', 'Dark mode'],
  'notif_permission_denied': [
    'ማሳሰቢያ ለመላክ የማሳወቂያ ፈቃድ ያስፈልጋል። በስልክ ቅንብሮች ውስጥ ያብሩት።',
    'Notification permission is needed for reminders. Enable it in system settings.'
  ],
  'notif_title': ['የዕለቱ ግጻዌ', "Today's Gitsawe"],
  'notif_fallback_body': ['የዛሬን ንባብ ለማንበብ ይክፈቱ', "Open to read today's readings"],
  'notif_channel': ['የዕለት ግጻዌ ማሳሰቢያ', 'Daily Gitsawe reminders'],
  'notif_channel_desc': ['የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ግጻዌ የዕለት ማሳሰቢያ።', 'Daily reminders for the Ethiopian Orthodox Gitsawe readings.'],

  // About
  'about_heading': ['ስለ ግጻዌ', 'About Gitsawe'],
  'about_p1': [
    'ግጻዌ ለኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተ ክርስቲያን ምእመናን የተዘጋጀ የዕለት ንባብ ጓደኛ ነው። የዕለት ንባባትን፣ ማኅሌትን፣ ስንክሳርን እና ትምህርቶችን በአንድ ቦታ ያገኛሉ።',
    'Gitsawe is a liturgical companion for the Ethiopian Orthodox Tewahedo Church. It brings together daily readings, hymns, Mahlet, the Synaxarium and teachings in one place — helping you stay connected to the rhythm of the Church calendar.'
  ],
  'about_p2': [
    'የመጽሐፍ ቅዱስ ንባባትን ይከተሉ፣ በየዕለቱ ያሰላስሉ፣ ቅዳሴውንም ወደ ልብዎ ያቅርቡ።',
    'Use it to follow Bible readings, reflect on daily prayers, and keep the liturgy close to your heart.'
  ],
  'about_version': ['ስሪት', 'Version'],
  'about_privacy': ['የግላዊነት ፖሊሲ', 'Privacy policy'],
  'about_source': ['የምንጭ ኮድ እና ማውጫ', 'Source code & releases'],
  'about_copy': ['አድራሻ ቅዳ', 'Copy link'],
  'about_copied': ['አድራሻው ተቀድቷል', 'Link copied'],
  'about_report': ['ችግር ያሳውቁ', 'Report a problem'],

  // Privacy
  'privacy_body': [
    'ግጻዌ የግል መረጃዎን አይሰበስብም፣ አያከማችም፣ አይልክምም።\n\n'
        '• መለያ (አካውንት) አያስፈልግም።\n'
        '• ማስታወቂያ፣ የተጠቃሚ ክትትል (analytics) ወይም የሶስተኛ ወገን መከታተያ የለም።\n'
        '• ቅንብሮችዎ (ቋንቋ፣ ገጽታ፣ የጽሑፍ መጠን፣ የተቀመጡ ንባባት) በስልክዎ ላይ ብቻ ይቀመጣሉ።\n'
        '• የድምፅ ትምህርቶችን ሲያዳምጡ ድምፁ ከ eathebook.org ይሰራጫል (ይወርዳል)፤ ያ ድረ ገጽ የእርስዎን የአይፒ አድራሻ ሊያይ ይችላል።\n'
        '• የማሳሰቢያ ፈቃድ ለዕለት ንባብ ማሳሰቢያ ብቻ ነው የሚውለው፤ ማንኛውም ጊዜ ሊያጠፉት ይችላሉ።',
    'Gitsawe does not collect, store or transmit your personal information.\n\n'
        '• No account is required.\n'
        '• There are no ads, no analytics and no third-party trackers.\n'
        '• Your settings (language, theme, text size, bookmarks) are stored only on your device.\n'
        '• When you play audio lessons, the audio is streamed from eathebook.org; that website can see your IP address.\n'
        '• The notification permission is used only for the daily reading reminder, which you can turn off at any time.'
  ],
  'privacy_full': ['ሙሉ ፖሊሲ በ GitHub ላይ ይገኛል፦', 'The full policy is available on GitHub:'],

  // Onboarding
  'onb1_title': ['እንኳን ደህና መጡ', 'Welcome'],
  'onb1_desc': [
    'ወደ ግጻዌ መተግበሪያ እንኳን በደህና መጡ። የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተ ክርስቲያን የዕለት ንባባትን እዚህ ያገኛሉ።',
    'Welcome to Gitsawe. Find the daily readings of the Ethiopian Orthodox Tewahedo Church here.'
  ],
  'onb2_title': ['የዕለት ንባባት', 'Daily readings'],
  'onb2_desc': [
    'ምስባክ፣ ወንጌል፣ ቅዳሴና ስንክሳርን በየቀኑ በቀላሉ ይከታተሉ።',
    'Follow the Psalm, Gospel, Liturgy and Synaxarium easily every day.'
  ],
  'onb3_title': ['ማኅሌትና በዓላት', 'Mahlet & feasts'],
  'onb3_desc': [
    'የወር በዓላትንና የማኅሌት ሥርዓታትን በማንኛውም ጊዜ ይመልከቱ።',
    'Browse the monthly feasts and Mahlet services at any time.'
  ],
};
