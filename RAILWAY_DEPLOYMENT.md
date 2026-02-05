# How to Deploy to Railway

Since your app uses **Puppeteer/Playwright** and **PostgreSQL**, Railway is a great choice because it supports Dockerfiles seamlessly.

## Prerequisites

1.  **GitHub Repository**: Push your code (`d:/Personal/EC-AI`) to a new public or private GitHub repository.
2.  **Railway Account**: Sign up at [railway.app](https://railway.app).

## Step-by-Step Deployment

### 1. Create Project on Railway
1.  Go to your Railway Dashboard.
2.  Click **"New Project"** -> **"Deploy from GitHub repo"**.
3.  Select your `ec-search-backend` repository.
4.  Click **"Deploy Now"**.

### 2. Add PostgreSQL Database
1.  In your Railway project view, click **"New"** (or command + K) -> **Database** -> **PostgreSQL**.
2.  Wait for the database container to start.

### 3. Connect Backend to Database
1.  Click on the **PostgreSQL** card.
2.  Go to the **"Variables"** tab.
3.  Copy the `DATABASE_URL` (it looks like `postgresql://postgres:password@...`).
4.  Click on your **Backend (Node.js)** card.
5.  Go to the **"Variables"** tab.
6.  Click **"New Variable"**.
    -   **Key**: `DATABASE_URL`
    -   **Value**: Paste the URL you copied.
7.  Railway will automatically redeploy your app with the new environment variable.

### 4. Important: The "Headless" Limitation
**CRITICAL NOTE**: You mentioned: *"User sees browser to enter CAPTCHA"*.

When running on **Railway (Cloud)**, the browser runs in **Headless Mode** (invisible). There is no screen for you to see or interact with.
-   **If you deploy this to Railway**, `headless: false` will NOT work (it will crash or do nothing visible).
-   **Solution for Cloud**:
    1.  **Screenshot Proxy**: You would need to update the code to take a screenshot of the CAPTCHA, send it to your Frontend, have the user type it, and send it back to the backend to fill.
    2.  **Hybrid Approach**: Run the "Search/Captcha" step **Locally** on your machine (where you can see the browser), and use the Railway Backend only for parsing and storing the data.

### 5. Verify Deployment
1.  Click on your Backend card.
2.  Go to **"Settings"** -> **"Networking"**.
3.  Generate a Domain (e.g., `ec-search-production.up.railway.app`).
4.  Test the API:
    ```bash
    curl -X POST https://your-domain.up.railway.app/api/ec/start-search ...
    ```
