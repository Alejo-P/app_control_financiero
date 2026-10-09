import { Buffer } from 'node:buffer';

const MAX_BYTES = 4 * 1024 * 1024;
export function providerReason(message) {
  if (typeof message !== 'string') return 'unknown';
  if (/api.?key.*invalid|invalid.*api.?key/i.test(message)) return 'invalid_api_key';
  if (/only send testing emails|your own email address/i.test(message)) return 'recipient_not_allowed';
  if (/domain.*not verified/i.test(message)) return 'sender_not_verified';
  if (/attachment/i.test(message)) return 'attachment_rejected';
  if (/invalid.*\bfrom\b|\bfrom\b.*(?:invalid|valid)/i.test(message)) return 'invalid_sender';
  if (/invalid.*recipient|\bto\b.*(?:invalid|valid)/i.test(message)) return 'invalid_recipient';
  return 'unknown';
}
const json = (status, body, headers = {}) => new Response(JSON.stringify(body), {
  status, headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store', ...headers },
});

async function readBounded(request) {
  if (!request.body) throw new Error('empty');
  const reader = request.body.getReader();
  const chunks = [];
  let length = 0;
  try {
    while (true) {
      const { value, done } = await reader.read();
      if (done) break;
      length += value.byteLength;
      if (length > MAX_BYTES) { await reader.cancel(); throw new Error('too_large'); }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  return Buffer.concat(chunks, length);
}

export function createWorker(send = fetch) {
  return {
    async fetch(request, env) {
      try {
        const url = new URL(request.url);
        if (url.pathname !== '/reports') return json(404, { code: 'not_found' });
        if (request.method !== 'POST') return json(405, { code: 'method_not_allowed' }, { Allow: 'POST' });
        if (!env.RESEND_API_KEY || !env.REPORT_TO || !env.REPORT_FROM || !env.IP_LIMITER || !env.SERVICE_LIMITER) {
          return json(503, { code: 'not_configured' });
        }
        const ip = request.headers.get('CF-Connecting-IP');
        if (!ip) return json(400, { code: 'invalid_request' });
        const limited = await env.IP_LIMITER.limit({ key: ip });
        if (!limited.success) return json(429, { code: 'rate_limited' }, { 'Retry-After': '60' });
        if (!(await env.SERVICE_LIMITER.limit({ key: 'reports' })).success) {
          return json(429, { code: 'rate_limited' }, { 'Retry-After': '60' });
        }
        const reportId = request.headers.get('X-Report-ID') ?? '';
        if (!/^\d{10,20}$/.test(reportId)) return json(400, { code: 'invalid_report_id' });
        if (request.headers.get('Content-Type')?.split(';')[0].trim() !== 'application/zip') {
          return json(415, { code: 'invalid_content_type' });
        }
        const declaredSize = request.headers.get('Content-Length');
        if (declaredSize && (!/^\d+$/.test(declaredSize) || Number(declaredSize) > MAX_BYTES)) {
          return json(413, { code: 'too_large' });
        }
        let zip;
        try { zip = await readBounded(request); }
        catch (error) {
          return json(error.message === 'too_large' ? 413 : 400,
            { code: error.message === 'too_large' ? 'too_large' : 'invalid_archive' });
        }
        // Check the local-file ZIP signature; do not unpack untrusted archives.
        if (zip.length < 4 || zip[0] !== 0x50 || zip[1] !== 0x4b || zip[2] !== 0x03 || zip[3] !== 0x04) {
          return json(400, { code: 'invalid_archive' });
        }
        const digest = Buffer.from(await crypto.subtle.digest('SHA-256', zip)).toString('hex');
        const response = await send('https://api.resend.com/emails', {
          method: 'POST',
          signal: AbortSignal.timeout(15000),
          headers: { Authorization: `Bearer ${env.RESEND_API_KEY}`,
            'Content-Type': 'application/json', 'Idempotency-Key': `report-${reportId}-${digest}` },
          body: JSON.stringify({
            from: env.REPORT_FROM,
            to: [env.REPORT_TO],
            subject: `Mi Presupuesto - Reporte de error ${reportId}`,
            text: 'Se adjunta un reporte de diagnóstico enviado desde Mi Presupuesto.\n'
              + 'El ZIP contiene la descripción, datos técnicos y registros recientes.',
            attachments: [{ filename: `reporte_error_${reportId}.zip`, content: zip.toString('base64') }],
          }),
        });
        if (!response.ok) {
          const allowedNames = new Set(['validation_error', 'missing_api_key',
            'restricted_api_key', 'invalid_permission', 'suspended_api_key',
            'invalid_attachment', 'invalid_idempotency_key', 'invalid_idempotent_request',
            'daily_quota_exceeded', 'monthly_quota_exceeded', 'rate_limit_exceeded']);
          let providerName = 'unknown';
          let reason = 'unknown';
          try {
            const failure = await response.json();
            if (allowedNames.has(failure.name)) providerName = failure.name;
            reason = providerReason(failure.message);
          } catch (_) {}
          console.error(JSON.stringify({ event: 'report_email_rejected',
            provider_status: response.status, provider_error: providerName, provider_reason: reason }));
          if (response.status === 429) return json(429, { code: 'rate_limited' }, { 'Retry-After': '60' });
          // Do not expose provider errors, addresses, credentials or attachments.
          return json(502, { code: 'email_failed' });
        }
        const payload = await response.json();
        if (typeof payload.id !== 'string' || !payload.id) return json(502, { code: 'email_failed' });
        return json(202, { status: 'accepted', report_id: reportId });
      } catch (_) {
        console.error(JSON.stringify({ event: 'report_worker_failed' }));
        return json(503, { code: 'temporarily_unavailable' });
      }
    },
  };
}

export default createWorker();
