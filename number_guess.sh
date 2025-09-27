#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME
USERDATAFROMDB=$($PSQL "SELECT u.user_id, username, count(*) as games, min(guesses) as best_game from users u inner join games g using (user_id) WHERE username='$USERNAME' group by u.user_id, username")

if [[ -z $USERDATAFROMDB ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  IFS='|' read -r USERID USERNAME GAMES BESTGAME <<< "$USERDATAFROMDB"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES games, and your best game took $BESTGAME guesses."
fi

TARGET=$(( RANDOM % 1000 + 1 ))
COUNTER=0
PROMPT="Guess the secret number between 1 and 1000:"
while true
do
  echo $PROMPT
  read USERGUESS
  if [[ $USERGUESS =~ ^[0-9]+$ ]]
  then
    COUNTER=$((COUNTER + 1))
    if [[ $USERGUESS -gt $TARGET ]]
    then
      PROMPT="It's lower than that, guess again:"
    elif [[ $USERGUESS -lt $TARGET ]]
    then
      PROMPT="It's higher than that, guess again:"
    else
      echo "You guessed it in $COUNTER tries. The secret number was $TARGET. Nice job!"
      break
    fi    
  else
    PROMPT="That is not an integer, guess again:"
  fi
done

if [[ -z $USERDATAFROMDB ]]
then
  INSERTUSER=$($PSQL "INSERT INTO users (username) values('$USERNAME')")
  USERID=$($PSQL "select user_id from users where username = '$USERNAME';")
fi

INSERTGAME=$($PSQL "INSERT INTO games (user_id,guesses) Values($USERID,$COUNTER)")

