FROM hugomods/hugo:exts

COPY . /src

RUN hugo --minify