# Hackattic – Backup Restore (Automated via GitHub Actions)

This repository solves the [Hackattic “Backup Restore” challenge](https://hackattic.com/challenges/backup_restore/) automatically using **GitHub Actions** and a temporary **PostgreSQL service**.

---

## What it does

1. Requests a fresh problem dump from Hackattic API.  
2. Decodes and restores it into PostgreSQL.  
3. Extracts all SSNs for people with 'status = 'alive''.  
4. Submits the result back to Hackattic via API.  
5. Prints the Hackattic response in the Action log.

Everything runs automatically inside a GitHub Actions workflow — no local setup required.

---

## 🛠️ How to use

1. **Fork this repository** to your own GitHub account.

2. **Add your Hackattic access token**  
   Go to:  
   `Settings → Secrets and variables → Actions → New repository secret`
   - Name: 'HACKATTIC_TOKEN'
   - Value: your Hackattic access token

3. **Run the workflow manually**  
   - Open the **Actions** tab in your fork  
   - Select `backup_restore` → **Run workflow**

4. Wait a minute.  
   The Action will:
   - Spin up a PostgreSQL container
   - Restore the dump
   - Extract “alive” SSNs
   - Submit your solution
   - Print the result (e.g. `{"status": "ok"}`)

---

## 🧩 Requirements

- A valid Hackattic account and `access_token`
- A GitHub account with Actions enabled

---

## 🧰 Notes

- Workflow runs in a fresh ephemeral PostgreSQL 16 service each time.
- Your token never leaves GitHub; it’s stored as a secret.
- You can adapt `solve.sh` to run locally if you prefer.

---

## 🧠 Example output

Run ./solve.sh
{
“status”: “ok”,
“message”: “Challenge solved!”
}

or 

{
  "message": "woah there! you've solved this one, no need to convince me more.",
  "hint": "if you want to refine your solution, pass &playground=1 to disable this warning"
}
