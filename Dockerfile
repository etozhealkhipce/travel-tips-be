FROM node:20-alpine AS base

WORKDIR /app

RUN apk add --no-cache \
  libc6-compat \
  python3 \
  make \
  g++ \
  && rm -rf /var/cache/apk/*

FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci

FROM base AS build
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NODE_ENV=production
RUN npm run build

FROM base AS production
RUN apk add --no-cache tini && rm -rf /var/cache/apk/*

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Strapi 5: build output is dist/ (backend + admin in dist/build)
COPY --from=build /app/dist ./dist
COPY --from=build /app/config ./config
COPY --from=build /app/public ./public
COPY --from=build /app/database ./database
COPY --from=build /app/data ./data
COPY --from=build /app/.strapi-updater.json ./.strapi-updater.json

EXPOSE 1337

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["npm", "run", "start"]
