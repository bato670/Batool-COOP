import { createClient } from '@supabase/supabase-js';
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

export const config = { api: { bodyParser: false } };

export default async function handler(req, res) {
  // استخدمي مكتبة formidable أو busboy لتحليل رفع الملفات (multipart)
  // ثم: const { data, error } = await supabase.storage.from('attachments').upload(path, fileBuffer);
  res.status(200).json({ message: 'أضيفي هنا تحليل الرفع + supabase.storage.upload' });
}
