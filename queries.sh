#!/bin/bash

# World Cup Database Queries Script
# This script contains all the required queries for the World Cup project

PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

echo "World Cup Database Query Results"
echo "================================"

echo ""
echo "1. Total number of goals in all games from winning teams:"
$PSQL "SELECT SUM(winner_goals) FROM games;"

echo ""
echo "2. Total number of goals in all games from both teams combined:"
$PSQL "SELECT SUM(winner_goals + opponent_goals) FROM games;"

echo ""
echo "3. Average number of goals in all games from the winning teams:"
$PSQL "SELECT AVG(winner_goals) FROM games;"

echo ""
echo "4. Average number of goals in all games from the winning teams rounded to two decimal places:"
$PSQL "SELECT ROUND(AVG(winner_goals), 2) FROM games;"

echo ""
echo "5. Average number of goals in all games from both teams:"
$PSQL "SELECT AVG(winner_goals + opponent_goals) FROM games;"

echo ""
echo "6. Most goals scored in a single game by one team:"
$PSQL "SELECT MAX(winner_goals) FROM games;"

echo ""
echo "7. Number of games where the winning team scored more than two goals:"
$PSQL "SELECT COUNT(*) FROM games WHERE winner_goals > 2;"

echo ""
echo "8. Winner of the 2018 tournament team name:"
$PSQL "SELECT name FROM teams INNER JOIN games ON teams.team_id = games.winner_id WHERE year = 2018 AND round = 'Final';"

echo ""
echo "9. List of teams who played in the 2014 'Eighth-Final' round:"
$PSQL "SELECT DISTINCT(name) FROM teams INNER JOIN games ON teams.team_id = games.winner_id OR teams.team_id = games.opponent_id WHERE year = 2014 AND round = 'Eighth-Final' ORDER BY name;"

echo ""
echo "10. List of unique winning team names in the whole data set:"
$PSQL "SELECT DISTINCT(name) FROM teams INNER JOIN games ON teams.team_id = games.winner_id ORDER BY name;"

echo ""
echo "11. Year and team name of all the champions:"
$PSQL "SELECT year, name FROM teams INNER JOIN games ON teams.team_id = games.winner_id WHERE round = 'Final' ORDER BY year;"

echo ""
echo "12. List of teams that start with 'Co':"
$PSQL "SELECT name FROM teams WHERE name LIKE 'Co%';"
