FROM hugomods/hugo

# Copy the public folder to Apache's web root
COPY / /src

# Expose the HTTP port
EXPOSE 1313

CMD ["server", "-D"]