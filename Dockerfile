FROM hugomods/hugo

# Copy the public folder to Apache's web root
COPY . /src

# RUN hugo mod get && hugo mod tidy

VOLUME ["/src/hugo.toml"]

# Expose the HTTP port
EXPOSE 1313

CMD ["server", "-D", "--buildDrafts", "--baseURL", "https://hugo.gavriliu.com/"]