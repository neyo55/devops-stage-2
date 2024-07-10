# Use the latest official Node.js image as a base
FROM node:latest

# Set the working directory
WORKDIR /app

# Copy the application files
COPY . .

# arg command
ARG VITE_API_URL=${VITE_API_URL}

# Install dependencies
RUN npm install

# Expose the port the development server runs on
EXPOSE 5173

# Run the development server
CMD ["npm", "run", "dev", "--", "--host"]

############################################################################
# # Stage 1: Build the React application
# FROM node:16-alpine AS build

# # Set the working directory
# WORKDIR /app

# # Copy package.json and package-lock.json to the working directory
# COPY package.json package-lock.json ./

# # Install dependencies
# RUN npm install

# # Copy the rest of the application to the working directory
# COPY . .

# # Build the React application
# RUN npm run build

# # Stage 2: Serve the React application with Nginx
# FROM nginx:alpine

# # Remove the default Nginx website
# RUN rm -rf /usr/share/nginx/html/*

# # Copy the build output to the Nginx HTML directory
# COPY --from=build /app/dist /usr/share/nginx/html

# # Expose port 80
# EXPOSE 80

# # Start Nginx
# CMD ["nginx", "-g", "daemon off;"]
##############################################################################

















# # Stage 1: Build the React application
# FROM node:alpine AS builder

# # Set the working directory
# WORKDIR /app

# # Copy package.json and package-lock.json to the working directory
# COPY package*.json ./

# # Install dependencies
# RUN npm install

# # Copy the rest of the application to the working directory
# COPY . .

# # Build the React application
# RUN npm run build

# # Expose port (optional, may not be needed for building)
# # EXPOSE 3000  # Uncomment if needed

# # Stage 2: Serve the React application with Nginx
# FROM nginx:alpine

# WORKDIR /usr/share/nginx/html

# # Copy the build output to the Nginx HTML directory
# COPY --from=builder /app/dist .  

# # Expose port 80 for serving traffic
# EXPOSE 5173

# # Start Nginx in the foreground mode
# CMD ["nginx", "-g", "daemon off;"]






# # Stage 1: Build the React application
# FROM node-alpine AS build

# # Set the working directory
# WORKDIR /app

# # Copy package.json and package-lock.json to the working directory
# COPY package.json package-lock.json ./

# # Install dependencies
# RUN npm install

# # Copy the rest of the application to the working directory
# COPY . .

# # Build the React application
# RUN npm run build

# # Stage 2: Serve the React application with Nginx
# FROM node:alpine

# # Remove the default Nginx website
# RUN rm -rf /usr/share/npm/html/*

# # Copy the build output to the Nginx HTML directory
# COPY --from=build /app/dist /usr/share/npm/html

# # Expose port 80 to the outside world
# EXPOSE 5173

# # Start Nginx
# CMD ["npm", "-g", "daemon off;"]
