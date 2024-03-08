#!/bin/bash
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
  #Verify if argument is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number = $1;");
  else
    #Verify if argument is a symbol or a name
    if [[ ${#1} -le 2 ]]; then
      ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol='$1';");
    else
      ELEMENT=$($PSQL "SELECT * FROM elements WHERE name LIKE '%$1%'");
    fi
  fi

  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    IFS='|' read -ra ELEMENT <<< "$ELEMENT"

    ELEMENT_ATOMIC_NUMBER=${ELEMENT[0]}
    ELEMENT_SYMBOL=${ELEMENT[1]}
    ELEMENT_NAME=${ELEMENT[2]}

    PROPERTIES=$($PSQL "SELECT * FROM properties WHERE atomic_number=$ELEMENT_ATOMIC_NUMBER");

    IFS='|' read -ra PROPERTIES <<< "$PROPERTIES"
  
    ELEMENT_MELTING_POINT=${PROPERTIES[2]}
    ELEMENT_BOILING_POINT=${PROPERTIES[3]}
    ELEMENT_MASS=${PROPERTIES[1]}

    ELEMENT_TYPE=${PROPERTIES[4]}
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$ELEMENT_TYPE");
    

    echo "The element with atomic number $ELEMENT_ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $TYPE, with a mass of $ELEMENT_MASS amu. $ELEMENT_NAME has a melting point of $ELEMENT_MELTING_POINT celsius and a boiling point of $ELEMENT_BOILING_POINT celsius."
  fi
fi