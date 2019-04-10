#!/usr/bin/env bash

# This script runs frontend tests for both Jest and Karma

function show_usage() {
  echo -e "Usage:\n"
  echo -e "\thelp\t\tShow this help message\n"
  echo -e "\t-f|--file path\tSpecify a specs files pattern for both Jest and Karma, if this flag is defined twice, the second occurence is passed to Karma\n"
  echo -e "\t--w|--watch\tEnable watch mode for both Jest and Karma (off by default)\n"
}

if [ "$1" = "help" ]
then
  show_usage
  exit
fi

WATCH_ENABLED=0

JEST_ARGS=""
KARMA_ARGS=""
JEST_PATH=""
KARMA_PATH=""

# Args parsing
# Courtesy of https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
while (( "$#" )); do
  case "$1" in
    -f|--file)
      # Exit if more than 2 -f flags detected
      if ! [ -z "$KARMA_PATH" ]
      then
        echo "Too many file paths specified"
        exit 1
      fi
      # Set specs patterns
      if [ -z "$JEST_PATH" ]
      then
        # First specified path is for Jest
        JEST_PATH="$2"
      else
        # Second specified path is for Karma
        KARMA_PATH="$2"
      fi
      shift 2
      ;;
    -w|--watch)
      WATCH_ENABLED=1
      shift 1
      ;;
    --)
      shift
      break
      ;;
    -*|--*=)
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# Karma path defaults to Jest path if any
if [ -z "$KARMA_PATH" ]
then
  KARMA_PATH="$JEST_PATH"
fi

# Build file path args for Jest
if ! [ -z "$JEST_PATH" ]
then
  JEST_ARGS="$JEST_ARGS $JEST_PATH"
  echo -e "Jest pattern:\t$JEST_PATH"
fi

# Build file path args for Karma
if ! [ -z "$KARMA_PATH" ]
then
  KARMA_ARGS="$KARMA_ARGS -f $KARMA_PATH"
  echo -e "Karma pattern:\t$KARMA_PATH"
fi

# Build watch args for both Jest and Karma
if [ "$WATCH_ENABLED" = 1 ]
then
  JEST_ARGS="$JEST_ARGS --watch"
  KARMA_ARGS="$KARMA_ARGS --auto-watch --single-run false"
  echo "Running in watch mode"
fi

./node_modules/.bin/concurrently "yarn jest $JEST_ARGS" "yarn karma $KARMA_ARGS"
