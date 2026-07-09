# Multi-stage build for security and size
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Production stage - minimal attack surface
FROM node:20-alpine AS production

# Security: Run as non-root
RUN addgroup -g 1000 -S appgroup &&     adduser -u 1000 -S appuser -G appgroup

WORKDIR /app

# Copy only necessary files
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup . .

# Security: Read-only root filesystem support
RUN mkdir -p /tmp && chown appuser:appgroup /tmp

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3     CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["node", "server.js"]
