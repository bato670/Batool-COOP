import { createClient } from '@supabase/supabase-js';
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

export default async function handler(req, res) {
  const { id } = req.query;
  if (req.method === 'GET') {
    const { data, error } = await supabase.from('weeks').select('*, tasks(*), attachments(*)').eq('id', id).single();
    if (error) return res.status(404).json({ error: error.message });
    return res.status(200).json(data);
  }
  if (req.method === 'PATCH') {
    const { data, error } = await supabase.from('weeks').update(req.body).eq('id', id).select().single();
    if (error) return res.status(400).json({ error: error.message });
    return res.status(200).json(data);
  }
  res.status(405).end();
}
