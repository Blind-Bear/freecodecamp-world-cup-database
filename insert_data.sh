#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#Reset Sequence & Clear Tables
  echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
  echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")
  echo $($PSQL "TRUNCATE teams, games")

#Insert Teams
  cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do
    if [[ $YEAR != "year" ]]
    then

    #From Winner
      #Get Team_ID from Winner
        WTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

      #If not found, Insert
        if [[ -z $WTEAM_ID ]]
        then
          INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
          if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into teams, name $WINNER
            fi

        fi
    #From Opponent
      #Get Team_ID from Opponent
        OTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

      #If not found, Insert
        if [[ -z $OTEAM_ID ]]
        then
          INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
          if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into teams, name $OPPONENT
            fi
        fi
    fi
  done  
#Insert Games
  cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do
  if [[ $YEAR != "year" ]]
  then
    #Get team IDs
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    #Insert Game Info
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted game year: $YEAR, round: $ROUND, $WINNER vs $OPPONENT
    fi
  fi


  done
