import { app } from './src/app';
import { prisma } from './src/config/database';
import { env } from './src/config/env';

async function verifyHealthEndpoint() {
  const server = app.listen(env.PORT);

  await new Promise<void>((resolve, reject) => {
    server.once('listening', () => resolve());
    server.once('error', (err) => reject(err));
  });

  try {
    const url = `http://localhost:${env.PORT}/api/v1/health`;
    const res = await fetch(url);
    const body = await res.json();
    console.log(`HTTP STATUS: ${res.status}`);
    console.log('RESPONSE JSON:', JSON.stringify(body, null, 2));

    if (res.status !== 200 || !body.success) {
      process.exitCode = 1;
    }
  } finally {
    await new Promise<void>((resolve) => server.close(() => resolve()));
    await prisma.$disconnect();
  }
}

verifyHealthEndpoint().catch((err) => {
  console.error('Health verification failed:', err);
  process.exit(1);
});

