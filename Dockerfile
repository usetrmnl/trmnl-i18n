# Use official Ruby 3.4.5 image
FROM ruby:3.4.7

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/src/app

# Copy Gemfile, Gemfile.lock, and .ruby-version first
COPY Gemfile Gemfile.lock* .ruby-version ./

# Copy the rest of the project
COPY . .

# Update Ruby environment
RUN gem update --system

# Default command
CMD ["rake"]

