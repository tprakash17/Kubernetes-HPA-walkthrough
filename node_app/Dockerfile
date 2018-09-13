# Used node image from dockerhub
FROM node 

# Copy source code
COPY . /app

# Change working directory
WORKDIR /app

# Install dependencies
RUN npm install

# Expose API port to the outside
EXPOSE 3000 

# Launch application
CMD ["node","app.js"]
