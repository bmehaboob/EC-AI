# Use the official Playwright image which comes with browsers installed
FROM mcr.microsoft.com/playwright:v1.40.1-jammy

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on (Railway will set PORT env var)
ENV PORT=3000
EXPOSE $PORT

# Start the application
CMD ["npm", "start"]
