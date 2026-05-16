# ══════════════════════════════════════════════════════════════════
# Trippo Backend - Multi-Stage Production Dockerfile
# NestJS + Prisma + PostgreSQL + PostGIS
# ══════════════════════════════════════════════════════════════════

# ──────────────────────────────────────────────────────────────────
# Stage 1: Builder - Install all deps, generate Prisma, build TS
# ──────────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

# Install build dependencies for native modules (bcrypt, etc.)
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy dependency manifests first for better cache
COPY package.json package-lock.json* ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci --ignore-scripts=false

# Copy source code and Prisma schema
COPY . .

# Generate Prisma client from schema
RUN npx prisma generate

# Build the NestJS project (TypeScript -> JavaScript)
RUN npm run build

# Prune devDependencies — only production deps remain
RUN npm prune --omit=dev

# ──────────────────────────────────────────────────────────────────
# Stage 2: Production - Minimal image with built artifacts
# ──────────────────────────────────────────────────────────────────
FROM node:20-alpine AS production

# Install dumb-init for proper PID 1 signal handling
# Install curl for health checks
RUN apk add --no-cache dumb-init curl

# Create non-root user for security
RUN addgroup -g 1001 -S trippo && \
    adduser -S trippo -u 1001 -G trippo

WORKDIR /app

# Copy production node_modules from builder (already pruned)
COPY --from=builder --chown=trippo:trippo /app/node_modules ./node_modules

# Copy built application
COPY --from=builder --chown=trippo:trippo /app/dist ./dist

# Copy Prisma schema and migrations (needed for prisma migrate deploy)
COPY --from=builder --chown=trippo:trippo /app/prisma ./prisma

# Copy package.json for version info and scripts
COPY --from=builder --chown=trippo:trippo /app/package.json ./

# Set environment
ENV NODE_ENV=production \
    APP_PORT=3000

# Expose application port
EXPOSE 3000

# Switch to non-root user
USER trippo

# Health check — hits the /api/v1/health endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:${APP_PORT}/api/v1/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start: run migrations then launch the app
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]
