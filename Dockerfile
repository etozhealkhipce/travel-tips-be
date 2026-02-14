###################
# DEPS
###################
FROM node:22-alpine AS deps
WORKDIR /opt

RUN apk add --no-cache libc6-compat

COPY package.json package-lock.json ./
RUN npm ci

###################
# BUILD
###################
FROM node:22-alpine AS build
WORKDIR /opt/app

RUN apk add --no-cache \
  build-base python3 make g++ \
  autoconf automake \
  zlib-dev libpng-dev \
  vips-dev \
  git

COPY --from=deps /opt/node_modules /opt/node_modules
ENV PATH=/opt/node_modules/.bin:$PATH

COPY . .
ENV NODE_ENV=production
RUN npm run build

###################
# PROD DEPS
###################
FROM node:22-alpine AS prod-deps
WORKDIR /opt

RUN apk add --no-cache libc6-compat
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

###################
# RUNTIME
###################
FROM node:22-alpine AS runtime
WORKDIR /opt/app
ENV NODE_ENV=production

RUN apk add --no-cache vips libc6-compat

COPY --from=prod-deps /opt/node_modules /opt/node_modules
ENV PATH=/opt/node_modules/.bin:$PATH

COPY --from=build /opt/app /opt/app

RUN chown -R node:node /opt/app
USER node

EXPOSE 1337
CMD ["npm", "run", "start"]
