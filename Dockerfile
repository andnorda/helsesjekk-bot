FROM oven/bun:1.0.10 as build

WORKDIR /app

COPY package.json /app/
COPY bun.lockb /app/
COPY bunfig.toml /app/
COPY prisma /app/prisma
COPY scripts /app/scripts
COPY node_modules /app/node_modules

ENV NODE_ENV=production

RUN bun install --production
RUN bun prisma:generate

FROM node:20-alpine as runner

ENV NODE_ENV production

WORKDIR /app

COPY --from=build /app/package.json /app/
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/prisma /app/prisma
COPY start.sh /app/
COPY next-logger.config.js /app/
COPY public /app/public/
COPY .next /app/.next

ENV NODE_ENV=production
ENV NODE_OPTIONS '-r next-logger'

EXPOSE 3000

CMD ["/bin/sh", "start.sh"]
