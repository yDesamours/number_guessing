#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

#read username
echo "Enter your username:"
read USERNAME

#search for user in database
USER_ID="$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")"
# if not found
if [[ -z $USER_ID ]]
  then
    #insert the new user
    INSERT_USER="$($PSQL "INSERT INTO players (username) VALUES ('$USERNAME')")"
    #insert succeed
    if [[ $INSERT_USER == "INSERT 0 1" ]]
      then
        echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
        #get new user id
        USER_ID="$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")"
    fi
  else
    echo "$($PSQL "SELECT COUNT(*), MIN(guesses) FROM players INNER JOIN games USING(player_id) WHERE username='$USERNAME'")" |\
    while IFS='|' read COUNT BEST
    do
      if [[ -z $BEST ]]
        then
        BEST=0
      fi
      echo -e "\nWelcome back, $USERNAME! You have played $COUNT games, and your best game took $BEST guesses."
    done
fi

ATTEMPT=0
NUMBER=$(( $RANDOM / 1000 +1))
echo $NUMBER
GUESS=0

  echo -e "\nGuess the secret number between 1 and 1000:"
while [[ $ATTEMPT != $NUMBER ]]
do
  read ATTEMPT

  (( GUESS++ ))

  if [[ ! $ATTEMPT =~ ^[0-9][0-9]*$ ]]
  then
    echo  -e "\nThat is not an integer, guess again:"
  else
    if [[ $ATTEMPT -eq $NUMBER ]]
      then
        INSERT_GAMES="$($PSQL "INSERT INTO games (player_id, guesses) VALUES ($USER_ID, $GUESS)")"
        echo "You guessed it in $GUESS tries. The secret number was $NUMBER. Nice job!"
    elif [[ $ATTEMPT -gt $NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
    else
        echo -e "\nIt's higher than that, guess again:"
    fi
  fi
done
