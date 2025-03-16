# FROM hugomods/hugo

# # Copy the public folder to Apache's web root
# COPY . /src

# RUN hugo mod get && hugo mod tidy

# # Expose the HTTP port
# EXPOSE 1313

# CMD ["server", "-D"]

# Stage 1: Build Hugo Site
FROM hugomods/hugo AS builder

# Set working directory
WORKDIR /src

# Copy the site source files
COPY . .

# Build the Hugo site
RUN hugo --config /src/hugo.toml

# Stage 2: Serve with Nginx
FROM nginx:latest

# Copy built Hugo site from the builder stage to Nginx's web root
COPY --from=builder /src/public /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]