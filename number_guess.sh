#!/bin/bash
echo "# This is a number guessing game" >> number_guess.sh

# Define the database file for user data
DB_FILE="user_data.txt"

# Generate a random secret number between 1 and 1000
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# Prompt for username and check for existing user data
echo -n "Enter your username: "
read USERNAME

if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username should not exceed 22 characters."
  exit 1
fi

# Check if the user exists in the database
USER_DATA=$(grep "^$USERNAME:" "$DB_FILE")
if [[ $USER_DATA ]]; then
  # Existing user
  GAMES_PLAYED=$(echo "$USER_DATA" | cut -d ':' -f 2)
  BEST_GAME=$(echo "$USER_DATA" | cut -d ':' -f 3)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=1000
fi

# Start the guessing game
echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0
while true; do
  read GUESS

  # Check if input is an integer
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if ((GUESS > SECRET_NUMBER)); then
    echo "It's lower than that, guess again:"
  elif ((GUESS < SECRET_NUMBER)); then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update user data and save to database
((GAMES_PLAYED++))
if ((NUMBER_OF_GUESSES < BEST_GAME)); then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

# Write updated data back to the file
grep -v "^$USERNAME:" "$DB_FILE" > temp_db.txt
echo "$USERNAME:$GAMES_PLAYED:$BEST_GAME" >> temp_db.txt
mv temp_db.txt "$DB_FILE"
