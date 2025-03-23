# Build stage
FROM node:16-alpine as build
WORKDIR /app
COPY package*.json ./
# RUN npm ci
RUN npm ci --legacy-peer-deps

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Add health check endpoint
RUN mkdir -p /usr/share/nginx/html/health
RUN echo '{"status":"Healthy","uptime":0}' > /usr/share/nginx/html/health/index.json

# Add custom nginx config with metrics endpoint
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
