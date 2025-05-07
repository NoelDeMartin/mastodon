FROM ghcr.io/mastodon/mastodon:v4.3.8

USER root
RUN sed -i '/^\([[:space:]]*\)= stylesheet_link_tag/a\    = stylesheet_link_tag "/extra/styles.css", skip_pipeline: true, media: "all"' /opt/mastodon/app/views/layouts/application.html.haml
