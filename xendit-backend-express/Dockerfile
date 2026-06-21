# Use official lightweight Node.js image.
FROM node:18-slim

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
COPY package*.json ./

# Install dependencies.
RUN npm install --only=production

# Copy local code to the container image.
COPY . .

# Expose port (Cloud Run automatically sets the PORT env variable)
EXPOSE 3000

# Run the web service on container startup.
CMD [ "node", "server.js" ]
