# منصة التدريب التعاوني الذكية (GTIP)

## هيكل المشروع — وين أضع كل ملف؟

```
gtip-platform/
├── public/
│   └── index.html          ← الواجهة الكاملة (الموقع نفسه)
├── api/
│   ├── auth/login.js        ← تسجيل الدخول
│   ├── weeks/[id].js         ← جلب/تعديل أسبوع تدريبي
│   ├── ai/rewrite.js         ← المساعد الذكي (OpenAI)
│   ├── admin/stats.js        ← إحصائيات لوحة الإدارة
│   └── upload/attachment.js  ← رفع المرفقات
├── database/
│   └── schema.sql            ← تُنفَّذ هذه داخل Supabase فقط، وليس في المشروع نفسه
├── package.json
├── vercel.json
├── .env.example               ← نموذج لأسماء المتغيرات (لا تضعي المفاتيح الحقيقية هنا)
└── .gitignore
```

القاعدة العامة: كل ملف HTML/CSS/JS للواجهة يذهب داخل `public/`. كل ملف يمثّل نقطة API يذهب داخل `api/` بنفس اسم المسار الذي تريدين استدعاءه (مثلاً `api/weeks/[id].js` يصبح متاحاً على `/api/weeks/123`).

---

## الخطوات كاملة من الصفر إلى النشر

### 1) تثبيت الأدوات (مرة واحدة فقط)
```bash
node -v      # تأكدي أن Node.js مثبت (أي إصدار 18 فأعلى)
npm install -g vercel
```

### 2) تجهيز مجلد المشروع على جهازك
- حمّلي كل الملفات المرفقة في هذا الرد ونظّميها بنفس الهيكل أعلاه على جهازك.

### 3) إنشاء حساب Supabase
1. اذهبي إلى supabase.com → New Project.
2. بعد إنشاء المشروع، افتحي **SQL Editor** ثم افتحي محتوى `database/schema.sql` وانسخيه ونفّذيه (Run) هناك — هذا الملف لا يُرفع كجزء من كود الموقع، بل يُنفَّذ داخل لوحة Supabase مباشرة.
3. من **Project Settings → API** انسخي:
   - `Project URL` → هذا هو `SUPABASE_URL`
   - `service_role key` → هذا هو `SUPABASE_SERVICE_ROLE_KEY`

### 4) إنشاء مفتاح OpenAI
- من platform.openai.com/api-keys أنشئي مفتاحاً جديداً → هذا هو `OPENAI_API_KEY`.

### 5) رفع المشروع على GitHub
```bash
cd gtip-platform
git init
git add .
git commit -m "Initial GTIP platform"
git branch -M main
git remote add origin https://github.com/USERNAME/gtip-platform.git
git push -u origin main
```
⚠️ لا ترفعي أبداً ملف `.env` الحقيقي (فيه المفاتيح) — ملف `.gitignore` المرفق يمنع ذلك تلقائياً.

### 6) الربط والنشر على Vercel
1. افتحي vercel.com → **Add New Project** → اختاري مستودع GitHub الذي رفعتِه.
2. قبل الضغط على Deploy، اذهبي إلى **Environment Variables** وأضيفي:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `OPENAI_API_KEY`
   (القيم من الخطوتين 3 و4 أعلاه)
3. اضغطي **Deploy**. بعد دقيقة تقريباً يعطيك Vercel رابطاً مباشراً للموقع الفعلي مثل:
   `https://gtip-platform.vercel.app`

### 7) كل تحديث لاحق
```bash
git add .
git commit -m "وصف التحديث"
git push
```
Vercel يعيد النشر تلقائياً بعد كل push — لا حاجة لأي خطوة إضافية.

---

## ملاحظة مهمة
الملف `public/index.html` المرفق حالياً يعمل بشكل مستقل (بيانات محفوظة في المتصفح) ليعطيك تجربة فعلية فوراً. بعد ربط Supabase، الخطوة التالية هي تعديل دوال JavaScript داخل `index.html` (مثل `doLogin`, `openWeek`, `runAI`) لتستدعي نقاط `/api/...` الحقيقية بدلاً من `localStorage`، لتصبح البيانات مشتركة بين كل المستخدمين وليست محفوظة محلياً فقط.
