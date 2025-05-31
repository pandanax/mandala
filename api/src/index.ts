import { PrismaClient } from '@prisma/client';
import express, { Request, Response, NextFunction } from 'express';
import https from 'https';
import fs from 'fs';
import path from 'path';

const prisma = new PrismaClient();
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use((req: Request, res: Response, next: NextFunction) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});

app.get('/status', async (req: Request, res: Response) => {
    try {
        await prisma.$queryRaw`SELECT 1`;
        res.json({
            status: 'OK',
            db: 'connected',
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error('Database connection error:', error);
        // Проверяем тип ошибки
        const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
        res.status(500).json({
            status: 'ERROR',
            db: 'disconnected',
            error: errorMessage
        });
    }
});

// Аналогично исправляем в других обработчиках
app.get('/users', async (req: Request, res: Response) => {
    try {
        const users = await prisma.user.findMany({
            include: { data: true },
        });
        res.json(users);
    } catch (error) {
        console.error('Error fetching users:', error);
        const errorMessage = error instanceof Error ? error.message : 'Internal server error';
        res.status(500).json({ error: errorMessage });
    }
});

// И в функции main
async function main() {
    try {
        console.log("Connecting to DB with URL:", process.env.DB_URL);
        await prisma.$connect();
        console.log('Successfully connected to database');

        // Выбираем режим запуска (HTTP/HTTPS)
        if (process.env.NODE_ENV === 'production') {
            try {
                const sslDir = '/app/ssl-certs/live/api.mandala-app.online';
                const options = {
                    key: fs.readFileSync(path.join(sslDir, 'privkey.pem')),
                    cert: fs.readFileSync(path.join(sslDir, 'fullchain.pem')),
                };

                https.createServer(options, app).listen(port, () => {
                    console.log(`HTTPS server running on port ${port}`);
                });
            } catch (sslError) {
                console.error('SSL setup failed:', sslError);
                console.log('Falling back to HTTP');
                app.listen(port, () => {
                    console.log(`HTTP server running on port ${port}`);
                });
            }
        } else {
            app.listen(port, () => {
                console.log(`HTTP server running on port ${port}`);
            });
        }
    } catch (error) {
        console.error('Failed to connect to database:', error instanceof Error ? error.message : error);
        process.exit(1);
    }
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        process.on('SIGTERM', async () => {
            console.log('SIGTERM signal received: closing HTTP server');
            await prisma.$disconnect();
            process.exit(0);
        });
    });
