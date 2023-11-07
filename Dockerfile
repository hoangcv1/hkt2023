# Use an official Ruby 3.1.4 runtime as the base image
FROM ruby:3.1.4

# Set the working directory inside the container
WORKDIR /app

# # Copy your application code into the container
COPY . /app

# Install any required gems
RUN gem install dotenv

RUN cp .env.sample .env

# Define the command to run your Ruby application
