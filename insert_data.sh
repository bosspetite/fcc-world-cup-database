#!/bin/bash

# World Cup Database Insert Script
# This script processes a CSV file and inserts the data into the PostgreSQL database

PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"

# Check if CSV file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <csv_file>"
    exit 1
fi

CSV_FILE=$1

# Check if file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: File $CSV_FILE not found!"
    exit 1
fi

echo "Starting import from $CSV_FILE..."

# Create database if it doesn't exist
createdb worldcup 2>/dev/null

# Create tables
$PSQL "CREATE TABLE IF NOT EXISTS teams(team_id SERIAL PRIMARY KEY, name VARCHAR(50) UNIQUE NOT NULL);"
$PSQL "CREATE TABLE IF NOT EXISTS games(game_id SERIAL PRIMARY KEY, year INT NOT NULL, round VARCHAR(50) NOT NULL, winner_id INT REFERENCES teams(team_id) NOT NULL, opponent_id INT REFERENCES teams(team_id) NOT NULL, winner_goals INT NOT NULL, opponent_goals INT NOT NULL);"

# Clear existing data
$PSQL "TRUNCATE teams, games RESTART IDENTITY CASCADE;"

# Read CSV file line by line (skip header)
tail -n +2 "$CSV_FILE" | while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
    # Insert winner team if not exists
    WINNER_ID=$($PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT(name) DO NOTHING RETURNING team_id;")
    if [ -z "$WINNER_ID" ]; then
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    fi
    
    # Insert opponent team if not exists
    OPPONENT_ID=$($PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT(name) DO NOTHING RETURNING team_id;")
    if [ -z "$OPPONENT_ID" ]; then
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
    fi
    
    # Insert game
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);"
    
    echo "Inserted: $year $round - $winner vs $opponent ($winner_goals-$opponent_goals)"
done

echo "Import completed successfully!"

# Display summary
TEAM_COUNT=$($PSQL "SELECT COUNT(*) FROM teams;")
GAME_COUNT=$($PSQL "SELECT COUNT(*) FROM games;")

echo "Summary:"
echo "- Teams imported: $TEAM_COUNT"
echo "- Games imported: $GAME_COUNT"
