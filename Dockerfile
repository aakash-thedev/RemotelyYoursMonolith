# syntax=docker/dockerfile:1
FROM ruby:3.1.4-slim AS base

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment true && \
    bundle config set --local without "development test" && \
    bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/cache

# Copy application code
COPY . .

# Precompile bootsnap cache
RUN bundle exec bootsnap precompile --gemfile app/ lib/

EXPOSE 3001

# Default to running the web server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
