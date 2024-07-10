# Dockerized Full Stack Web Application Deployment

This project demonstrates a full stack web application deployment using Docker containers. It consists of a React frontend, a FastAPI backend with PostgreSQL database, and uses Nginx Proxy Manager to proxy both services to run on the same port.

## Table of Contents
- [Dockerized Full Stack Web Application Deployment](#dockerized-full-stack-web-application-deployment)
  - [Table of Contents](#table-of-contents)
  - [Project Structure](#project-structure)
  - [Technologies](#technologies)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
    - [Step 1: Clone the Repository](#step-1-clone-the-repository)
    - [Step2: Configure the backend](#step2-configure-the-backend)
    - [Step3: Configure frontend side of the application](#step3-configure-frontend-side-of-the-application)
    - [Step4: Dockerize the application](#step4-dockerize-the-application)
    - [Step 5: Domain setup](#step-5-domain-setup)
      - [Step A: Log in to AWS Management Console](#step-a-log-in-to-aws-management-console)
      - [Step B: Navigate to Route 53](#step-b-navigate-to-route-53)
      - [Step C: Create a Hosted Zone](#step-c-create-a-hosted-zone)
      - [Step D: Create an A Record](#step-d-create-an-a-record)
      - [Step E: Create an Alias Record (Optional)](#step-e-create-an-alias-record-optional)
      - [Step F: Verify Your Records](#step-f-verify-your-records)
    - [Step 6](#step-6)
    - [Step 7](#step-7)
    - [Step 8](#step-8)
    - [Conclusion](#conclusion)

## Project Structure

The repository is organized into two main directories:

- **frontend**: Contains the ReactJS application.
- **backend**: Contains the FastAPI application and PostgreSQL database integration.

Each directory has its own README file with detailed instructions specific to that part of the application.

## Technologies

- Frontend: React (latest version as of July 2024)
- Backend: FastAPI (latest version as of July 2024)
- Database: PostgreSQL (latest version as of July 2024)
- Containerization: Docker
- Proxy: Nginx Proxy Manager

## Prerequisites

- Docker and Docker Compose
- An AWS EC2 instance
- A domain name pointed to the EC2 instance's public IP address

## Getting Started

To get started with this template, please follow the instructions in the respective directories:

- [Frontend README](./frontend/README.md)
- [Backend README](./backend/README.md)

### Step 1: Clone the Repository

```bash
git clone https://github.com/hngprojects/devops-stage-2
cd devops-stage-2
```

### Step2: Configure the backend

The frontend of this application depends on the backend for full functionality so we will begin by configuring the backend.

```bash
cd backend
```

Dependencies
The backend depends on a postgresQL database, It would also require poetry to be installed before starting up

Installing Poetry

To install Poetry, follow these steps:

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

Add Poetry to your PATH:

```bash
export PATH="$HOME/.poetry/bin:$PATH" >> ~/.bashrc
source ~./bashrc
poetry --version
```

Install the dependencies

```bash
poetry install
```

Setup PostgreSQL:

Follow these steps to install PostgreSQL on Linux and configure a user named app with password my_password and a database named app. Give all permissions of the app database to the app user.

Install PostgreSQL on Ubuntu OS:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

Switch to the PostgreSQL user and access the PostgreSQL

```bash
sudo -i -u postgres
psql
```

Create a user with desired named "coco" with password "coco123"

```bash
CREATE USER coco WITH PASSWORD 'coco123';
```

Create a database named app

```bash
CREATE DATABASE coco_db;
```

Grant all permissions of the app database to the app user

```bash
GRANT ALL PRIVILEGES ON DATABASE coco_db TO coco;
```

Exit the PostgreSQL prompt and switch back to the default user

```bash
\q
exit
```

Set database credentials
Edit the PostgreSQL environment variables located in the .env file. Make sure the credentials match the database credentials you just created.

```bash
POSTGRES_SERVER=localhost
POSTGRES_PORT=5432
POSTGRES_DB=coco_db
POSTGRES_USER=coco
POSTGRES_PASSWORD=coco123
```

Running this command starts the database with the necessary tables:

```bash
poetry run bash ./prestart.sh
```

Run the backend server with this command:

```bash
poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Step3: Configure frontend side of the application

```bash
cd devops-stage-2/frontend
```

Install the dependencies

The frontend was built with `Nodejs` and `npm` for dependency management.

```bash
sudo apt update
sudo apt install nodejs npm
```

Install dependencies

```bash
npm install
```

Run the fronted server and make it accessible from all network interfaces:

```bash
npm run dev -- --host
```

Accessing the application on the browser:

```bash
Frontend: http://<your_server_IP>:5173
Backend API: http://<your_server_IP>:8000/api
Backend DOCS: http://<your_server_IP>:8000/docs
Backend REDOC: http://<your_server_IP>:8000/redoc
Adminer (Database management): http://<your_server_IP>:8080
Nginx Proxy Manager admin panel: http://<your_server_IP>:8090
```


logging to the application frontend:
The login credentials can be found in the .env located in the backend folder

```bash
FIRST_SUPERUSER=devops@hng.tech
FIRST_SUPERUSER_PASSWORD=devops#HNG11
```

Please remember to Change the VITE_API_URL variable in the frontend `.env` file:

```bash
VITE_API_URL=http://<your_instance_ip>:8000
```

Also in our backend `.env` file we need to add http://<your_server_IP>:5173 to the end of the string of allowed IPs.

```bash
BACKEND_CORS_ORIGINS="http://localhost,http://localhost:5173,https://localhost,https://localhost:5173,http://<your_server_IP>:5173"
```

We successfully setup the application locally.


### Step4: Dockerize the application

Containerizing the application

Now we need to repeat the entire process, but this time, We would utilize Docker containers. we will start by writing Dockerfiles for both frontend and backend and then move to the project's root directory and configure a docker compose file that will run the dockerfiles of the frontend and backend:

- The Frontend and Backend
- The postgres database the backend depends on
- Adminer
- Nginx proxy Manager

Firstly we need to install docker and docker compose on our machine.

Update the package list:

```bash
sudo apt-get update
```

Install required packages:

```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```

Add Docker’s official GPG key:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Add the Docker repository to APT sources:

```bash
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
```

Update the package list again:

```bash
sudo apt-get update
```

Install Docker:

```bash
sudo apt-get install docker-ce
```

Verify that Docker is installed correctly:

```bash
docker --version
sudo systemctl status docker
```

Install Docker Compose
Download the latest version of Docker Compose:

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')" /usr/local/bin/docker-compose
```

Apply executable permissions to the binary:

```bash
sudo chmod +x /usr/local/bin/docker-compose
```

Verifying Docker Compose installation version:

```bash
docker-compose --version
```

Add your user to the docker group:

```bash
sudo usermod -aG docker $USER
```

Let's start by writing the Dockerfile for the backend application

```bash
cd devops-stage-2/backend
nano Dockerfile
```

```bash
# Use the latest official Python image as a base
FROM python:latest

# Install Node.js and npm
RUN apt-get update && apt-get install -y \
    nodejs \
    npm

# Install Poetry using pip
RUN pip install poetry

# Set the working directory
WORKDIR /app

# Copy the application files
COPY . .

# Install dependencies using Poetry
RUN poetry install

# Expose the port FastAPI runs on
EXPOSE 8000

# Run the prestart script and start the server
CMD ["sh", "-c", "poetry run bash ./prestart.sh && poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"]
```

This repeats the entire process we carried out locally all in one file.

Next, we would write the Dockerfile for the frontend application

```bash
cd devops-stage-2/frontend
nano Dockerfile
```

```bash
# Use the latest official Node.js image as a base
FROM node:latest

# Set the working directory
WORKDIR /app

# Copy the application files
COPY . .

# arg command
ARG VITE_API_URL=${VITE_API_URL}

# Install dependencies
RUN npm install

# Expose the port the development server runs on
EXPOSE 5173

# Run the development server
CMD ["npm", "run", "dev", "--", "--host"]
```

Finally, lets write the docker-compose file that would run the entire application

```bash
cd devops-stage-2
nano docker-compose.yml
```

```bash
version: '3.8'

services:
  backend:
    build:
      context: ./backend

    container_name: fastapi_app
    ports:
      - "8000:8000"
    depends_on:
      - db
    env_file:
      - ./backend/.env

  frontend:
    build:
      context: ./frontend
      args:
        - VITE_API_URL=http://neyothetechguy.com.ng
    container_name: nodejs_app
    ports:
      - "5173:5173"
    environment:
      - VITE_API_URL=http://neyothetechguy.com.ng

  db:
    image: postgres:latest
    container_name: postgres_db
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: coco
      POSTGRES_PASSWORD: coco123
      POSTGRES_DB: coco_db

  adminer:
    image: adminer
    container_name: adminer
    ports:
      - "8080:8080"
    depends_on:
      - db

  proxy:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx_proxy_manager
    restart: unless-stopped
    ports:
      - '80:80'    # Public HTTP Port
      - '8090:81'  # Admin Web Port
      - '443:443'  # Public HTTPS Port
    environment:
      DB_SQLITE_FILE: "/data/database.sqlite"
      DB_PGSQL_HOST: "db"
      DB_PGSQL_PORT: 5432
      DB_PGSQL_USER: "proxy_user"
      DB_PGSQL_PASSWORD: "proxy00123"
      DB_PGSQL_NAME: "proxy_db"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    depends_on:
      - db
      - backend
      - frontend
      - adminer

volumes:
  postgres_data:
  data:
  letsencrypt:
```

Start the application

```bash
docker-compose up --build
```

If you get a permission denied error, run with sudo

```bash
sudo docker-compose up -build
```

### Step 5: Domain setup 

Let me walk you through the step-by-step guide in creating hosted zone and A records in AWS

#### Step A: Log in to AWS Management Console

- Go to the AWS website and sign in to your account using your email address and password.
- Make sure you are in the correct region where you want to create your hosted zone.

#### Step B: Navigate to Route 53

- Click on the "Services" dropdown menu at the top of the page and select "Route 53" under the "Networking & Connectivity" section.
- Alternatively, you can type "Route 53" in the search bar and select the service from the results.

#### Step C: Create a Hosted Zone

- Click on the "Create a hosted zone" button.
- Enter the domain name you want to create a hosted zone for (e.g., (link unavailable)).
- Select the type of hosted zone you want to create (e.g., public hosted zone).
- Click "Create hosted zone".

#### Step D: Create an A Record

- In the hosted zone, click on the "Create record set" button.
- Select "A" as the record type.
- Enter the following values:
    - Name: The subdomain you want to create the A record for (e.g., www).
    - Value: The IP address of the resource you want to point to (e.g., the IP address of your EC2 instance).
    - TTL (optional): The time to live for the record (e.g., 300 seconds).
- Click "Create record set".

#### Step E: Create an Alias Record (Optional)

- If you want to point your domain to an AWS resource (e.g., an ELB or S3 bucket), you need to create an alias record.
- Select "Alias" as the record type.
- Enter the following values:
    - Name: The subdomain you want to create the alias record for (e.g., www).
    - Value: The Amazon Resource Name (ARN) of the AWS resource you want to point to.
    - TTL (optional): The time to live for the record (e.g., 300 seconds).
- Click "Create record set".

#### Step F: Verify Your Records

- Go to the "Route 53" dashboard and select your hosted zone.
- Click on the "Records" tab.
- Verify that your A record and alias record (if created) are listed and have the correct values.

Finally go to your domain prover (qserver) and add the name servers copied and save it and let it get propagated by the provider.
- Note: that it may take some time for the changes to propagate globally.

Domain Setup
We need to setup domain and subdomains for the frontend, backend, adminer service and Nginx proxy manager.
Remember we are required to route port 80 to both frontend and backend:

- domain - Frontend
- domain/api - Backend
- db.domain - Adminer
- proxy.domain - Nginx proxy manager

### Step 6

Routing domains using Nginx proxy manager
We now have everything set up, we can run docker-compose up --build to build our application and up and running. We would need to install Docker and Docker-compose first.


### Step 7
Reverse Proxying and SSL setup with Nginx proxy manager
Access the Proxy manager UI by entering http://<ip_address>:81 in your browser, Ensure that port is open in your security group or firewall.
Login with the default Admin credentials

```bash
Email: admin@example.com
Password: changeme
```

Click on Proxy host and setup the proxy for your frontend and backend
Map your domain name to the service name of your frontend and the port the container is listening on Internally.

Click on the SSL tab and request a new certificate

Repeat the same process for;

db.domain: to route to your adminer service on port 8080
proxy.domain: to route to the proxy service UI on port 81
You don't need to do the advanced setup on the db and proxy domain



### Step 8

Setup Adminer

Access the adminer web interface on `db.<your_domain>`


Login with the db credentials in your backend .env file



Access your frontend on `<your_domain>`



Our FullstackApp is now runing and fully set up.


### Conclusion

We have now successfully:

Configured and tested the full stack application locally

Containerized the application

Setup Docker compose

Configured Adminer for Database management

Configured Reverse Proxying with Nginx Proxy Manager

Setup SSL certificates for our domains.
