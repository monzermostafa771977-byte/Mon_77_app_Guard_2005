# HARES — حارس (Stage 1)

مشروع تأسيسي لتطبيق رفاهية رقمية عربي يعمل محليًا أولًا، باستخدام Flutter وAndroid/Kotlin.

## الموجود في هذه المرحلة
- واجهة عربية RTL وهوية أزرق ليلي وذهبي.
- تنقل أساسي وصفحات أولية.
- قاعدة SQLite محلية بإصدار مخطط 1.
- إعدادات أولية وسجل عادات.
- إعداد Android بمعرف التطبيق `com.monzer.hares`.
- GitHub Actions لتحليل المصدر وتشغيل الاختبارات وبناء APK تجريبي قابل للتثبيت.

## ما لم يُنفذ بعد
- قراءة إحصاءات استخدام التطبيقات الحقيقية.
- تقييد التطبيقات أو الحظر المتقدم.
- نظام المهلات الاستثنائية التشغيلي.
- النسخ الاحتياطي المشفر والاستعادة.
- المساعد السحابي.

## تشغيل محلي
يتطلب Flutter stable وJava 17 وAndroid SDK:

```bash
flutter create --platforms=android --org com.monzer --project-name hares .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## GitHub
راجع `GITHUB_UPLOAD_AR.md` لرفع المشروع وتشغيل بناء APK من GitHub Actions.
راجع `docs/BUILD_AND_TEST.md` و`docs/STAGE_STATUS.md` للتفاصيل.
