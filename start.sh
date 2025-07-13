#!/bin/bash

echo "🚀 Starting Foodi database services with pgAdmin UI..."
# Start the services
docker-compose up -d db mongo pgadmin

echo "⏳ Waiting for services to be ready..."
sleep 3
echo "✅ Services started successfully!"
echo ""
echo "🔗 Access URLs:"
echo "   📊 pgAdmin (PostgreSQL UI): http://localhost:8080"
echo "   🗄️  PostgreSQL directly:    localhost:5432"
echo "   🍃 MongoDB directly:        localhost:27017"
echo ""
echo "🔐 pgAdmin Login:"
echo "   Email:    admin@foodi.com"
echo "   Password: admin123"
echo ""
echo "🔗 To connect to PostgreSQL in pgAdmin:"
echo "   Host:     db (or localhost if external)"
echo "   Port:     5432"
echo "   Database: foodi_db"
echo "   Username: postgres"
echo "   Password: password"
echo ""
echo "🛑 To stop services: docker-compose down"
