import BetterSqlite3 from 'better-sqlite3';
import path from 'path';

const dbPath = path.resolve('data', 'air_quality.db');
const sqlite = new BetterSqlite3(dbPath);
const row = sqlite.prepare('SELECT COUNT(*) as count FROM air_quality').get();
console.log(`Row count: ${row.count}`);
sqlite.close();
