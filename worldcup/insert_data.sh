#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS 
do
  if [[ $YEAR != "year" ]]
  then
    # get team ID from winner 
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if winner not found
    if [[ -z $TEAM_ID ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO TEAMS(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "Insert 0 1" ]]
      then
        echo Inserted into teams a: $WINNER
      fi
    fi
    # get team ID from opponent
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $TEAM_ID  ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "Insert 0 1" ]]
      then
        echo Inserted into teams b, $OPPONENT
      fi
    fi
    
    # get winner ID and opponent id from table games
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # filling games table

    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round, winner_id, opponent_id, winner_goals, opponent_goals)
     VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")

    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $ROUND $WINNER_ID $OPPONENT_ID
    fi



  fi
done