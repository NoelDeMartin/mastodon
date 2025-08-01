FROM ghcr.io/mastodon/mastodon:v4.4.2

USER root
RUN sed -i '/^\([[:space:]]*\)= custom_stylesheet/a\    = stylesheet_link_tag "/extra/styles.css", skip_pipeline: true, media: "all"' /opt/mastodon/app/views/layouts/application.html.haml
