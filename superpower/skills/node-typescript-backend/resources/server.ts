// Production Fastify Server with Zod & Structured Logging
import Fastify from 'fastify';
import { z } from 'zod';

const app = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info',
    formatters: {
      level: (label) => ({ level: label }),
    },
  },
});

const HealthSchema = z.object({
  status: z.literal('ok'),
  timestamp: z.number(),
});

app.get('/health', async (request, reply) => {
  return reply.status(200).send({
    status: 'ok',
    timestamp: Date.now(),
  });
});

const start = async () => {
  try {
    const port = Number(process.env.PORT) || 3000;
    await app.listen({ port, host: '0.0.0.0' });
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
};

start();
