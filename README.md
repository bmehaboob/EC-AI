# EC Search Backend

This is the Node.js + Playwright backend for the EC Search and Boundary Diagram Generator.

## Setup

1.  **Install Dependencies**:
    ```bash
    npm install
    npx playwright install chromium
    ```

2.  **Database Setup**:
    -   Ensure you have a PostgreSQL database running.
    -   Run the schema script in `src/db/schema.sql` to create the tables.
    -   Create a `.env` file with your database URL:
        ```
        DATABASE_URL=postgresql://user:password@localhost:5432/ec_db
        PORT=3000
        ```

3.  **Run Locally**:
    ```bash
    npm run dev
    ```

## API Endpoints

-   `POST /api/ec/start-search`: Opens the browser for manual CAPTCHA entry.
    -   Body: `{ "district": "...", "sro": "...", "docNumber": "...", "year": "..." }`
-   `POST /api/ec/fetch-and-parse`: After submitting, scrapes results and saves to DB.
    -   Body: `{ "sessionId": "..." }`

## Deployment (Railway)

1.  Push this code to a GitHub repository.
2.  Connect the repository to Railway.
3.  Add a PostgreSQL database service in Railway.
4.  Set the `DATABASE_URL` environment variable in the value provided by Railway.
5.  Railway will automatically detect the `Dockerfile` and build the image with Playwright support.
