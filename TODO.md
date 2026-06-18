# TODO - secret removal before push

## Step 1
- Inspect current usage of `xendit-backend-express/cleanbee-firebase-admin.json` (where it’s referenced).

## Step 2
- Remove the Firebase service account JSON from the repo and ensure `.gitignore` prevents it from being tracked again.

## Step 3
- Update `xendit-backend-express/server.js` to initialize firebase-admin using environment credentials (e.g., `GOOGLE_APPLICATION_CREDENTIALS` or `FIREBASE_ADMIN_SA_JSON`).

## Step 4
- Add instructions to create local `.env` (keep secrets out of git).

## Step 5
- Verify by checking git status and (if needed) removing the file from git index.

