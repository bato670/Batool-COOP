export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();
  const { text, mode } = req.body;
  const prompts = {
    rewrite: `أعد صياغة النص التالي بأسلوب حكومي رسمي قانوني: \n\n${text}`,
    skills: `استخرج 4-6 مهارات مهنية من النص التالي: \n\n${text}`,
    score: `قيّم أداء هذا الأسبوع من 100 مع تعليق مختصر: \n\n${text}`,
  };
  const r = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompts[mode] || prompts.rewrite }],
    }),
  });
  const data = await r.json();
  res.status(200).json({ result: data.choices?.[0]?.message?.content || '' });
}
