#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# توليد رقم عشوائي بين 1 و 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# طلب اسم المستخدم
echo "Enter your username:"
read USERNAME

# البحث عن المستخدم في قاعدة البيانات
USER_INFO=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  # مستخدم جديد
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # مستخدم موجود
  USER_ID=$USER_INFO
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# بدء اللعبة
echo "Guess the secret number between 1 and 1000:"
read GUESS
GUESS_COUNT=1

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  # التحقق من أن المدخل عدد صحيح
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  ((GUESS_COUNT++))
done

# عند الفوز
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

# حفظ نتيجة اللعبة
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)")

