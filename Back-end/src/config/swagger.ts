import { Express, Request, Response, NextFunction } from 'express';
import fs from 'fs';
import path from 'path';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';

function getOpenApiPath(): string {
  const candidates = [
    path.resolve(process.cwd(), 'docs/openapi.yaml'),
    path.resolve(process.cwd(), 'Back-end/docs/openapi.yaml'),
    path.resolve(__dirname, '../../../docs/openapi.yaml'),
    path.resolve(__dirname, '../../docs/openapi.yaml'),
    path.resolve(__dirname, '../docs/openapi.yaml'),
  ];
  for (const c of candidates) {
    if (fs.existsSync(c)) return c;
  }
  return candidates[0];
}

export function setupSwagger(app: Express): void {
  const openapiPath = getOpenApiPath();

  app.get('/api-docs/openapi.json', (_req: Request, res: Response) => {
    try {
      const doc = YAML.load(openapiPath);
      res.status(200).json(doc);
    } catch (err) {
      res.status(500).json({ error: 'Failed to load openapi.yaml', detail: String(err) });
    }
  });

  app.use(
    '/api-docs',
    swaggerUi.serve,
    (req: Request, res: Response, next: NextFunction) => {
      try {
        const swaggerDocument = YAML.load(openapiPath);
        return swaggerUi.setup(swaggerDocument, {
          swaggerOptions: {
            persistAuthorization: true,
          },
        })(req, res, next);
      } catch (err) {
        console.warn('Swagger docs could not be loaded:', err);
        return next(err);
      }
    },
  );
}

