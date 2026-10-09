import assert from 'node:assert/strict';
import { test } from 'node:test';
import { createWorker, providerReason } from '../src/index.js';

const ZIP = new Uint8Array([0x50, 0x4b, 3, 4, 1, 2, 3]);
const ID = '1791530000000000';
test('provider reasons classify rejection without exposing message content', () => {
  const cases = [
    ['API key is invalid: re_secret', 'invalid_api_key'],
    ['You can only send testing emails to your own email address (private@example.com)', 'recipient_not_allowed'],
    ['The private.example domain is not verified', 'sender_not_verified'],
    ['Invalid from field: private@example.com', 'invalid_sender'],
    ['Attachment private.zip is invalid', 'attachment_rejected'],
    ['Unknown issue private@example.com re_secret', 'unknown'],
  ];
  for (const [message, reason] of cases) assert.equal(providerReason(message), reason);
});
function env(overrides = {}) {
  return { RESEND_API_KEY: 'test-key', REPORT_TO: 'owner@example.com', REPORT_FROM: 'onboarding@resend.dev',
    IP_LIMITER: { limit: async () => ({ success: true }) },
    SERVICE_LIMITER: { limit: async () => ({ success: true }) }, ...overrides };
}
function request({ body = ZIP, headers = {}, method = 'POST', path = '/reports' } = {}) {
  return new Request(`https://reports.example.com${path}`, { method,
    headers: { 'CF-Connecting-IP': '192.0.2.1', 'Content-Type': 'application/zip', 'X-Report-ID': ID, ...headers },
    ...(method === 'POST' ? { body } : {}) });
}

test('only server config determines recipient; sends original ZIP as attachment', async () => {
  let sent;
  const worker = createWorker(async (url, options) => {
    sent = { url, ...options };
    return Response.json({ id: 'email-1' });
  });
  const response = await worker.fetch(request({ headers: { 'X-Recipient': 'attacker@example.com' } }), env());
  assert.equal(response.status, 202);
  assert.deepEqual(await response.json(), { status: 'accepted', report_id: ID });
  const body = JSON.parse(sent.body);
  assert.deepEqual(body.to, ['owner@example.com']);
  assert.deepEqual(new Uint8Array(Buffer.from(body.attachments[0].content, 'base64')), ZIP);
  assert.equal(sent.headers.Authorization, 'Bearer test-key');
});

test('retry of identical report uses the same idempotency key; changed bytes use another', async () => {
  const keys = [];
  const worker = createWorker(async (_, options) => {
    keys.push(options.headers['Idempotency-Key']);
    return Response.json({ id: 'email-1' });
  });
  await worker.fetch(request(), env());
  await worker.fetch(request(), env());
  await worker.fetch(request({ body: new Uint8Array([...ZIP, 4]) }), env());
  assert.equal(keys[0], keys[1]);
  assert.notEqual(keys[0], keys[2]);
});

test('missing credentials or bindings fails closed without sending', async () => {
  let calls = 0;
  const worker = createWorker(async () => { calls++; });
  for (const field of ['RESEND_API_KEY', 'REPORT_TO', 'REPORT_FROM', 'IP_LIMITER', 'SERVICE_LIMITER']) {
    assert.equal((await worker.fetch(request(), env({ [field]: undefined }))).status, 503);
  }
  assert.equal(calls, 0);
});

test('rate limits return 429 without invoking email provider', async () => {
  let calls = 0;
  const worker = createWorker(async () => { calls++; });
  for (const field of ['IP_LIMITER', 'SERVICE_LIMITER']) {
    const response = await worker.fetch(request(), env({ [field]: { limit: async () => ({ success: false }) } }));
    assert.equal(response.status, 429);
    assert.equal(response.headers.get('Retry-After'), '60');
  }
  assert.equal(calls, 0);
});

test('rejects oversized declared and actual bodies before email submission', async () => {
  let calls = 0;
  const worker = createWorker(async () => { calls++; });
  assert.equal((await worker.fetch(request({ headers: { 'Content-Length': '4194305' } }), env())).status, 413);
  assert.equal((await worker.fetch(request({ body: new Uint8Array(4194305) }), env())).status, 413);
  assert.equal(calls, 0);
});

test('rejects wrong method, route, ID, content type and archive', async () => {
  const worker = createWorker(async () => { throw new Error('must not send'); });
  const cases = [
    [{ method: 'GET' }, 405], [{ path: '/other' }, 404],
    [{ headers: { 'X-Report-ID': 'attacker@example.com' } }, 400],
    [{ headers: { 'Content-Type': 'text/plain' } }, 415], [{ body: 'not zip' }, 400],
  ];
  for (const [params, status] of cases) {
    assert.equal((await worker.fetch(request(params), env())).status, status);
  }
});

test('provider failures never expose body, credentials or claim success', async () => {
  for (const status of [401, 403, 429, 500]) {
    const worker = createWorker(async () => new Response('test-key owner@example.com sensitive content', { status }));
    const response = await worker.fetch(request(), env());
    assert.equal(response.status, status === 429 ? 429 : 502);
    assert.doesNotMatch(await response.text(), /test-key|owner@example|sensitive/);
  }
  const worker = createWorker(async () => { throw new Error('timeout secret'); });
  const response = await worker.fetch(request(), env());
  assert.equal(response.status, 503);
  assert.doesNotMatch(await response.text(), /secret/);
});

test('malformed provider success does not claim acceptance', async () => {
  const worker = createWorker(async () => Response.json({}));
  assert.equal((await worker.fetch(request(), env())).status, 502);
});
