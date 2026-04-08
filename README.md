# 🌐 SkyPredict Air Monitoring System

A smart air quality monitoring system with **machine learning predictions**, **real-time sensor integration**, **intelligent alerts**, and a **premium dashboard**.

## 🏗️ Architecture

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│   Frontend   │◄───►│  Node.js Backend │◄───►│  Python ML   │
│  HTML/JS/CSS │     │  Express + APIs  │     │  FastAPI      │
│  Chart.js    │     │  port: 3000      │     │  port: 8000   │
│  Canvas 3D   │     └────────┬─────────┘     └──────────────┘
└──────────────┘              │
                     ┌────────┴─────────┐
                     │   SQLite DB      │
                     │  (air_quality)   │
                     └────────┬─────────┘
                              │
                     ┌────────┴─────────┐
                     │  Sensor Bridge   │
                     │  HW / Simulation │
                     └──────────────────┘
```

## 📁 Project Structure

```
/ml_model          → Machine learning (Python)
  ├── model.py         ML prediction engine (Ridge + Polynomial)
  ├── server.py        FastAPI server (port 8000)
  ├── requirements.txt Python dependencies
  └── saved_model/     Persisted trained models

/backend           → API server (Node.js)
  ├── index.js         Express entry point
  ├── db.js            SQLite connection
  ├── utils.js         AQI calculations
  └── routes/
      ├── sensor.js      Sensor data ingestion
      ├── records.js     Historical records & stats
      ├── predictions.js ML prediction proxy
      ├── alerts.js      Intelligent alert system
      └── health.js      Health check

/frontend          → Dashboard UI
  ├── index.html       Main page (SPA)
  ├── css/index.css    Premium dark theme
  └── js/
      ├── main.js        App logic + routing
      ├── charts.js      Canvas trend charts
      └── cube.js        3D particle visualization

/hardware          → Sensor integration
  ├── sensor_bridge.js      Auto-detect HW or simulate
  ├── arduino_sketch/       Reference Arduino code
  └── README.md             Wiring & setup guide

/database-new      → SQLite database
  ├── schema.sql       Table schema
  ├── seed.sql         Sample data
  └── air_quality.db   Database file
```



- **Algorithm**: Ridge Regression with Polynomial Features (degree 2)
- **Features**: Cyclical time encoding, rolling averages (3h/6h/12h), lag features, rate of change
- **Targets**: AQI, PM2.5, CO2, Temperature, Humidity
- **Forecast**: 72-hour hourly predictions with confidence scores
- **Auto-retrain**: Model improves as new sensor data arrives

## 🔔 Alert System

| Level   | AQI   | PM2.5    | CO2      |
|---------|-------|----------|----------|
| ⚠️ Caution | >100  | >35 µg/m³ | >900 ppm |
| 🟠 Warning | >150  | >55 µg/m³ | >1200 ppm|
| 🔴 Danger  | >200  | >150 µg/m³| >2000 ppm|
Alerts are based on **both current readings AND predicted future data**.

 Hardware Support

The sensor bridge auto-detects Arduino/ESP32 via serial port. If no hardware is found, it runs in simulation mode with realistic diurnal patterns.

**Supported sensors**: PMS5003, MH-Z19B, SGP30, DHT22

See [hardware/README.md](hardware/README.md) for wiring diagrams.
