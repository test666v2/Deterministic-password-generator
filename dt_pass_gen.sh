#!/bin/bash

###################################################

# Deterministic password generator using argon2 and SHA-512
# also bash, awk, tr, xxd, grep, etc and your terminal of choice

# see https://github.com/P-H-C/phc-winner-argon2
# see https://en.wikipedia.org/wiki/Argon2
# see https://en.wikipedia.org/wiki/SHA-2

# argon2 -h
# Usage:  argon2 [-h] salt [-d] [-t iterations] [-m memory] [-p parallelism] [-l hash length] [-e|-r]
# Password is read from stdin
# Parameters:
#	salt		The salt to use, at least 8 characters
#  -d		Use Argon2d instead of Argon2i (which is the default)
#  -t N		Sets the number of iterations to N (default = 3)
#  -m N		Sets the memory usage of 2^N KiB (default 12)
#  -p N		Sets parallelism to N threads (default 1)
#  -l N		Sets hash output length to N bytes (default 32)
#  -e		Output only encoded hash
#  -r		Output only the raw bytes of the hash
#  -h		Print argon2 usage

###################################################

# DISCLAIMER

# This script is not supported or endorsed by argon2 creators or maintainers
# Use this script at your own risk
# You, as a user, have no right to support even if implied
# Carefully read the script and then interpret, modify, correct, fork, disdain, whatever

###################################################

#Copyright (c) <2017> <test666v2>
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

###################################################

# Starting values for some variables

ARGON2_CPU_THREADS=2 # -p parallelism
ARGON2_MAX_PASSWORD_LENGTH=110
ARGON2_MAX_SALT_LENGTH=64
ARGON2_MEMORY=16  # -m memory (2^16=65536)
ARGON2_MIN_ITERATIONS=16
ARGON2_OBFUSCATOR_LENGTH=16384 # -l hash length
PASSWORD_FINAL_OUTPUT_LENGTH=64
SHA_512_MIN_ITERATIONS=16
STEALTH_MODE="OFF"
HELP="It\'s better to use a local (non-online) password manager (keepassx comes to mind) than this script\n\n
If you want a truly random password, type in terminal\n
head /dev/urandom | tr -dc '[:graph:]' | fold -w64 | shuf -n1\n\n
If you stil want to use this script, you will have to remember a master password and 2 to 4 numbers (yikes!!)\n\n
\_(⊙_ʖ⊙)_/     ¯٩(͡๏̯͡๏)۶     (ఠ_ఠ)     (yeah, asking too much from brain power)\n\n
It asks for:\n
- a website name / mail address / whatever : this is the salt\n
- a master password\n
- the number of SHA-512 iterations (n>=$SHA_512_MIN_ITERATIONS, defaults to $SHA_512_MIN_ITERATIONS) to obfustate the salt; the higher, the better\n
- the number of argon2 iterations (n>=$ARGON2_MIN_ITERATIONS, defaults to $ARGON2_MIN_ITERATIONS) to obfustate the password (argon 2 has a higher CPU cost than SHA-512); the higher, the better\n
- an optional password length (minimum is 11 characters); just press ENTER to accept the default $PASSWORD_FINAL_OUTPUT_LENGTH characters\n
- an optional password starting position; just enter <1> for a no-brainer password position\n\n"

########################################################

# Intro

echo
echo "Deterministic password generator (VERY EARLY ALPHA - things may change)"
echo
echo "Generate \"strong\" \"NON-RANDOM\" or \"deterministic passwords\" for your accounts"
echo

if [ ! -z $1 ] # show $HELP & exit if there are any number of arguments in command line
   then
      echo -e "$HELP"
      exit
fi

########################################################

#Get variables from user

while [ "$STEALTH_MODE"  == "OFF" ]
   do
      echo "Stealth Mode"
      read -r -p "Do you want to hide your typing ? Type [ YES ] & press [ ENTER ] for \"Stealth Mode\" or simply press [ ENTER ] for normal working > " STEALTH_MODE
      STEALTH_MODE=$(
            case "$STEALTH_MODE" in
               "YES") echo "-s" ;;
               "") echo "" ;;
               *) echo "OFF" ;; # for all entered keywords other than "YES" or "empty" keep in the loop
            esac)
   done

while [ -z "$ARGON2_SALT" ]
   do
      read -r $STEALTH_MODE -p "Enter website / mail account / whatever (from 1 to $ARGON2_MAX_SALT_LENGTH characters) ? > " ARGON2_SALT
      ARGON2_SALT_SIZE=$(echo "$ARGON2_SALT" | awk '{print length}')
      (( ARGON2_SALT_SIZE >= 1 ))  || ARGON2_SALT="" # keep loop until ARGON2_SALT >= 1 # hey USER, at least type ONE character
      (( ARGON2_SALT_SIZE <= ARGON2_MAX_SALT_LENGTH )) || ARGON2_SALT="" # keep loop until ARGON2_SALT <= ARGON2_MAX_SALT_LENGTH
   done
[ -z $STEALTH_MODE ] || echo # writeln if STEALTH_MODE is enabled

while [ -z "$ARGON2_PASSWORD" ]
   do
      read -r -s -p "Enter master password (forced hidden keyboard typing) (from 1 to $ARGON2_MAX_PASSWORD_LENGTH characters) ? > " ARGON2_PASSWORD
      ARGON2_PASSWORD_SIZE=$(echo "$ARGON2_PASSWORD" | awk '{print length}')
      (( ARGON2_PASSWORD_SIZE >= 1 ))  || ARGON2_PASSWORD="" # keep loop until size of ARGON2_PASSWORD >= 1 # hey USER, at least type ONE character
      (( ARGON2_PASSWORD_SIZE <= ARGON2_MAX_PASSWORD_LENGTH )) || ARGON2_PASSWORD="" # keep loop until size of ARGON2_PASSWORD <= ARGON2_MAX_PASSWORD_LENGTH
   done
echo # because of "read -s" :	secure input - don't show typing on a terminal

while (( SHA_512_ITERATIONS < SHA_512_MIN_ITERATIONS ))
   do
      read -r $STEALTH_MODE -p "Iterations for SHA-512 (min=$SHA_512_MIN_ITERATIONS) ? > " SHA_512_ITERATIONS
      [ ! -z "${SHA_512_ITERATIONS##*[!0-9]*}" ]  || SHA_512_ITERATIONS=0 # test if the user inputs a positive non zero integer, forcing loop until this condition is met
   done
[ -z $STEALTH_MODE ] || echo # writeln if STEALTH_MODE is enabled

while (( ARGON2_ITERATIONS < ARGON2_MIN_ITERATIONS ))
   do
      read -r $STEALTH_MODE -p "Iterations for ARGON2 (min=$ARGON2_MIN_ITERATIONS) ? > " ARGON2_ITERATIONS
      [ ! -z "${ARGON2_ITERATIONS##*[!0-9]*}" ]  || ARGON2_ITERATIONS=0 # test if the user inputs a positive non zero integer, forcing loop until this condition is met
   done
[ -z $STEALTH_MODE ] || echo # writeln if STEALTH_MODE is enabled

while (( MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH == 0 ))
   do
      read -r $STEALTH_MODE -p "Desired length of password (>=11) or press ENTER for the default length of $PASSWORD_FINAL_OUTPUT_LENGTH ? > " MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH
      MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH=$(
            case "$MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH" in
               "") echo $PASSWORD_FINAL_OUTPUT_LENGTH ;;
               *) [ -z "${MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH##*[!0-9]*}" ] && echo 0 || echo $MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH;;
            esac)
      (( MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH >= 11 ))  || MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH=0 # keep loop until password size >= 11 (11 is "hardcoded" for a decent password length)
   done
PASSWORD_FINAL_OUTPUT_LENGTH=$MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH
[ -z $STEALTH_MODE ] || echo # writeln if STEALTH_MODE is enabled

########################################################

# Obfuscators for ARGON2_PASSWORD & ARGON2_SALT

# Step 1 - SHA-512 obfuscator

echo "Computing SHA-512..."
for (( i  = 1; i <= SHA_512_ITERATIONS; i++ ))
      do
         ARGON2_PASSWORD+=$(echo "$ARGON2_PASSWORD" | shasum -a 512 | awk '{ print $1 }') # cumulative obfuscation for password using SHA-512
         ARGON2_SALT+=$(echo "$ARGON2_SALT" | shasum -a 512 | awk '{ print $1 }') # cumulative obfuscation for salt using SHA-512
     done

# Step 2 - Process ARGON2_PASSWORD

ARGON2_PASSWORD=$(echo $ARGON2_PASSWORD | rev) # invert password string (for some more obfuscation "magic", just because we can) ### not satisfied, will see a better way, perhaps some "deterministic position switching" ##
ARGON2_PASSWORD=$(echo $ARGON2_PASSWORD | xxd -r -p | tr -cd '!-~' | cut -c 1-$ARGON2_MAX_PASSWORD_LENGTH) # generate ASCII string from [!] to [~] characters, triming the excess ### not satisfied, will see a better way than trimming ##

# Step 3 - Process ARGON2_SALT

ARGON2_SALT=$(echo $ARGON2_SALT | rev) # invert salt string (for some more obfuscation "magic", just because we can) ### not satisfied, will see a better way, perhaps some "deterministic position switching" ##
ARGON2_SALT=$(echo $ARGON2_SALT | xxd -r -p | tr -cd '!-~' | cut -c 1-$ARGON2_MAX_SALT_LENGTH) # generate ASCII string from [!] to [~] characters, triming the excess ### not satisfied, will see a better way than trimming ##

########################################################

# "Argonize" -> argon2 used as another obfuscator

echo "Computing ARGON2..."
ARGON2_OUTPUT=$(echo -n "'$ARGON2_PASSWORD'" | argon2 "$ARGON2_SALT" -d -t $ARGON2_ITERATIONS -m $ARGON2_MEMORY -p $ARGON2_CPU_THREADS -l $ARGON2_OBFUSCATOR_LENGTH)

########################################################

# Process argon2 output

ARGON2_OUTPUT_HASH=$(echo "$ARGON2_OUTPUT" | grep "Hash"  | awk '{ print $2 }')

########################################################

# Build "deterministic password" ("very long" password)

FINAL_PASSWORD=$(echo "$ARGON2_OUTPUT_HASH" | xxd -r -p | tr -cd '!-~')
FINAL_PASSWORD_SIZE=$(echo "$FINAL_PASSWORD" | awk '{print length}')

########################################################

# Ask user for the starting position for the "deterministic password"

echo
echo "The built \"password\" has a size of $FINAL_PASSWORD_SIZE characters"
echo "You can choose a position for the start of the reported position and get $PASSWORD_FINAL_OUTPUT_LENGTH continuous characters from this position onwards"
echo "You can input a number between 1 and "$(( FINAL_PASSWORD_SIZE - PASSWORD_FINAL_OUTPUT_LENGTH + 1 ))
while (( PASSWORD_POSITION_START == 0 ))
   do
      read -r $STEALTH_MODE -p "Password Position start ? (enter <1> for a no-brainer position) > " PASSWORD_POSITION_START
      [ ! -z "${PASSWORD_POSITION_START##*[!0-9]*}" ]  || PASSWORD_POSITION_START=0 #  test if the user inputs a positive non zero integer, forcing loop until this condition is met
      (( PASSWORD_POSITION_START <= $(( FINAL_PASSWORD_SIZE - PASSWORD_FINAL_OUTPUT_LENGTH + 1 )) ))  || PASSWORD_POSITION_START=0 # test for upper limit size
   done
PASSWORD_POSITION_END=$(( PASSWORD_POSITION_START + PASSWORD_FINAL_OUTPUT_LENGTH - 1 ))
[ -z $STEALTH_MODE ] || echo # writeln if STEALTH_MODE is enabled

########################################################

# Show the "deterministic password" to user

echo
echo "Outputing $PASSWORD_FINAL_OUTPUT_LENGTH characters length password:"
echo "$FINAL_PASSWORD" | cut -c $PASSWORD_POSITION_START-$PASSWORD_POSITION_END # Show password
echo
