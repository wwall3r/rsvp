ARG GLEAM_VERSION=v1.10.0

# Build stage - compile the application
FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-erlang-alpine AS builder

WORKDIR /app

# Add project code
COPY . .

RUN gleam deps download
RUN gleam export erlang-shipment

# Runtime stage - slim image with only what's needed to run
FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-erlang-alpine

# Copy the compiled server code from the builder stage
COPY --from=builder /build/server/build/erlang-shipment /app

# Set up the entrypoint
WORKDIR /app
RUN echo '#!/bin/sh\nexec ./entrypoint.sh "$@"' > /app/start.sh \
  && chmod +x /app/start.sh

# Set environment variables
ENV PORT=8080

# Expose the port the server will run on
EXPOSE 8080

# Run the server
CMD ["/app/start.sh", "run"]
