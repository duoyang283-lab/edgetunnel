FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY index.js .
RUN npx javascript-obfuscator index.js --output worker-internal.js \
    --compact true \
    --control-flow-flattening true \
    --string-array true \
    --string-array-encoding 'base64' \
    --unicode-escape-sequence true

FROM node:18-alpine
WORKDIR /opt/metrics
RUN cp /usr/local/bin/node /usr/local/bin/health-monitor
COPY --from=builder /app/worker-internal.js ./index.js
COPY --from=builder /app/package*.json ./
RUN npm install --production
EXPOSE 3000
CMD ["health-monitor", "index.js"]
