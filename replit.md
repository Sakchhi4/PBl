# Workspace

## Overview

pnpm workspace monorepo using TypeScript. Each package manages its own dependencies.

## Stack

- **Monorepo tool**: pnpm workspaces
- **Node.js version**: 24
- **Package manager**: pnpm
- **TypeScript version**: 5.9
- **API framework**: Express 5
- **Database**: PostgreSQL + Drizzle ORM
- **Validation**: Zod (`zod/v4`), `drizzle-zod`
- **API codegen**: Orval (from OpenAPI spec)
- **Build**: esbuild (CJS bundle)

## Structure

```text
artifacts-monorepo/
├── artifacts/              # Deployable applications
│   ├── api-server/         # Express API server (Node.js + Express.js)
│   └── aqi-dashboard/      # AQI Monitoring Dashboard (React + Vite, plain JS/JSX frontend)
├── lib/                    # Shared libraries
│   ├── api-spec/           # OpenAPI spec + Orval codegen config
│   ├── api-client-react/   # Generated React Query hooks
│   ├── api-zod/            # Generated Zod schemas from OpenAPI
│   └── db/                 # Drizzle ORM schema + DB connection
├── scripts/                # Utility scripts (single workspace package)
│   └── src/                # Individual .ts scripts, run via `pnpm --filter @workspace/scripts run <script>`
├── pnpm-workspace.yaml     # pnpm workspace (artifacts/*, lib/*, lib/integrations/*, scripts)
├── tsconfig.base.json      # Shared TS options (composite, bundler resolution, es2022)
├── tsconfig.json           # Root TS project references
└── package.json            # Root package with hoisted devDeps
```

## AQI Monitoring Dashboard

Real-time air quality monitoring dashboard connected to ESP32 IoT hardware.

### Features
- Real-time AQI, PM2.5, CO2, VOC, Temperature, Humidity display
- Interactive 3D AQI cube (Canvas 2D API) that changes color by AQI level
- Recharts line chart for AQI trends (last 50 readings)
- Recharts bar chart for pollutant composition
- Historical data table
- Precautions panel based on current AQI
- Auto-refresh every 5 seconds

### Frontend Tech
- Plain JavaScript/JSX (no TypeScript in client)
- React + Vite
- Recharts (charts)
- Canvas 2D API (3D cube visualization)
- Tailwind CSS (dark theme)

### Backend Tech
- Node.js + Express.js
- PostgreSQL database
- 180+ seeded records from research dataset (AQI range: 9-453)

### API Endpoints
- `POST /api/sensor/data` — Submit ESP32 sensor readings (pm25, co2, voc, temperature?, humidity?)
- `GET /api/sensor/latest` — Get latest sensor reading
- `GET /api/records?limit=100&offset=0` — Get historical records
- `GET /api/records/stats` — Get summary statistics

### AQI Calculation
Based on US EPA standard:
- Good (0-50): Green
- Moderate (51-100): Yellow
- Unhealthy for Sensitive Groups (101-150): Orange
- Unhealthy (151-200): Red
- Very Unhealthy (201-300): Purple
- Hazardous (301+): Maroon

### Database Schema
Table: `air_quality`
- id, timestamp, pm25, co2, voc, temperature, humidity, aqi, aqi_category, precautions

## TypeScript & Composite Projects

Every package extends `tsconfig.base.json` which sets `composite: true`. The root `tsconfig.json` lists all packages as project references. This means:

- **Always typecheck from the root** — run `pnpm run typecheck` (which runs `tsc --build --emitDeclarationOnly`). This builds the full dependency graph so that cross-package imports resolve correctly. Running `tsc` inside a single package will fail if its dependencies haven't been built yet.
- **`emitDeclarationOnly`** — we only emit `.d.ts` files during typecheck; actual JS bundling is handled by esbuild/tsx/vite...etc, not `tsc`.
- **Project references** — when package A depends on package B, A's `tsconfig.json` must list B in its `references` array. `tsc --build` uses this to determine build order and skip up-to-date packages.

## Root Scripts

- `pnpm run build` — runs `typecheck` first, then recursively runs `build` in all packages that define it
- `pnpm run typecheck` — runs `tsc --build --emitDeclarationOnly` using project references

## Packages

### `artifacts/api-server` (`@workspace/api-server`)

Express 5 API server. Routes live in `src/routes/` and use `@workspace/api-zod` for request and response validation and `@workspace/db` for persistence.

- Entry: `src/index.ts` — reads `PORT`, starts Express
- App setup: `src/app.ts` — mounts CORS, JSON/urlencoded parsing, routes at `/api`
- Routes: `src/routes/index.ts` mounts sub-routers; `health.ts`, `sensor.ts`, `records.ts`
- Depends on: `@workspace/db`, `@workspace/api-zod`, `zod`
- `pnpm --filter @workspace/api-server run dev` — run the dev server

### `artifacts/aqi-dashboard` (`@workspace/aqi-dashboard`)

React + Vite frontend (plain JS/JSX, no TypeScript in client code).

- Entry: `src/main.jsx`
- App: `src/App.jsx`
- Pages: `src/pages/Dashboard.jsx`
- Components: `AqiCube.jsx`, `MetricCard.jsx`, `Charts.jsx`, `DataTable.jsx`
- Hooks: `src/hooks/use-aqi.js`

### `lib/db` (`@workspace/db`)

Database layer using Drizzle ORM with PostgreSQL. Exports a Drizzle client instance and schema models.

- `src/schema/air_quality.ts` — `air_quality` table definition

### `lib/api-spec` (`@workspace/api-spec`)

OpenAPI 3.1 spec (`openapi.yaml`) and Orval config (`orval.config.ts`).

Run codegen: `pnpm --filter @workspace/api-spec run codegen`
