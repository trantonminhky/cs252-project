# Start from the pre-built image
FROM mobiledevops/flutter-sdk-image:latest

# Switch to the root user, which is guaranteed to work
USER root

# Fix git ownership issues (still good to keep)
RUN git config --global --add safe.directory /home/mobiledevops/.flutter-sdk

# Set a generic working directory owned by root
WORKDIR /app

# Just run a bash shell so the container stays alive
CMD ["bash"]