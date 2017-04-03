#!/bin/bash
#
####################################################
#
# Deterministic password generator using argon2 and SHA-512
# also bash, tr, xxd, grep, etc and your terminal of choice
#
# see https://github.com/P-H-C/phc-winner-argon2
# see https://en.wikipedia.org/wiki/Argon2
# see https://en.wikipedia.org/wiki/SHA-2
#
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
#
####################################################
#
# DISCLAIMER
#
# This script is not supported or endorsed by argon2 creators or maintainers
# Use this script at your own risk
# You, as a user, have no right to support even if implied
# Carefully read the script and then interpret, modify, correct, fork, disdain, whatever
#
####################################################
#
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
#
####################################################
#
ARGON2_CPU_THREADS=2 # -p parallelism
ARGON2_MAX_PASSWORD_LENGTH=110
ARGON2_MAX_SALT_LENGTH=64
ARGON2_MEMORY=16  # -m memory (2^16=65536)
ARGON2_MIN_ITERATIONS=16
ARGON2_OBFUSCATOR_LENGTH=16384 # -l hash length
PASSWORD_FINAL_OUTPUT_LENGTH=64
SHASUM_MIN_ITERATIONS=16
#
#########################################################
#
# Intro
echo
echo "Deterministic password generator"
echo
echo "Generate \"strong\" NON-RANDOM passwords for your accounts"
echo
help="It's better to use a local (non-online) password manager (keepassx comes to mind) than this script\n\n
You will have to remember a master password and 2-3, possibly 4 numbers\n\n
\_(⊙_ʖ⊙)_/     ¯٩(͡๏̯͡๏)۶     (ఠ_ఠ)     (yeah, asking too much from brain power)\n\n
Asks for:\n\n
- a website name / mail address / whatever : this is the salt\n\n
- a master password\n\n
- first iterations number (n>=$SHASUM_MIN_ITERATIONS) to obfustate the salt (executes n SHA-512); the higher, the better\n\n
- second iterations number (n>=$ARGON2_MIN_ITERATIONS) to obfustate the password using argon2 (higher CPU cost than shasum); the higher, the better\n\n
- optional password length number (n>=$PASSWORD_FINAL_OUTPUT_LENGTH); just press ENTER to accept the default $PASSWORD_FINAL_OUTPUT_LENGTH characters\n"
#
if [ ! -z $1 ]
   then 
      echo -e $help
      exit
fi
#
#########################################################
#
#Get variables
#
read -p "Website / mail account / whatever ? " ARGON2_SALT
#
read -s -p "Master password ? " ARGON2_PASSWORD
echo
#
SHASUM_ITERATIONS=0
while (($SHASUM_ITERATIONS < $SHASUM_MIN_ITERATIONS))
   do
      read -p "Iterations for shasums (min=$SHASUM_MIN_ITERATIONS) ? " SHASUM_ITERATIONS
   done
#
ARGON2_ITERATIONS=0
while (($ARGON2_ITERATIONS < $ARGON2_MIN_ITERATIONS))
   do
      read -p "Iterations for argon (min=$ARGON2_MIN_ITERATIONS) ? " ARGON2_ITERATIONS
   done
#
MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH=0
while (($MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH == 0))
   do
      read -p "Desired length of password (>=11) or press ENTER for the default length of $PASSWORD_FINAL_OUTPUT_LENGTH? " READ_NUMBER
      if [ -z $READ_NUMBER ]
         then MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH=$PASSWORD_FINAL_OUTPUT_LENGTH
         else (( $READ_NUMBER < 11 ))  || MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH=$READ_NUMBER
      fi
   done
PASSWORD_FINAL_OUTPUT_LENGTH=$MODIFY_PASSWORD_FINAL_OUTPUT_LENGTH
#
#########################################################
#
#########################################################
#
# Obfuscator for ARGON2_PASSORD & ARGON2_SALT
#
# SHA-512 obfuscator
#
echo "Computing SHA-512..."
for (( i  = 1; i <= $SHASUM_ITERATIONS; i++ ))
      do
         ARGON2_PASSWORD+=$(echo "$ARGON2_PASSWORD" | shasum -a 512 | awk '{ print $1 }') # cumulative obfuscation for password using SHA-512
         ARGON2_SALT+=$(echo "$ARGON2_SALT" | shasum -a 512 | awk '{ print $1 }') # cumulative obfuscation for salt using SHA-512
     done
#
# Process password
#
ARGON2_PASSWORD=$(echo $ARGON2_PASSWORD | rev) # invert password string
ARGON2_PASSWORD=$(echo $ARGON2_PASSWORD | xxd -r -p | tr -cd '[!-~]' | cut -c 1-$ARGON2_MAX_PASSWORD_LENGTH) # generate ASCII string from [!] to [~]
#
# Process salt
#
ARGON2_SALT=$(echo $ARGON2_SALT | rev) # invert salt string
ARGON2_SALT=$(echo $ARGON2_SALT | xxd -r -p | tr -cd '[!-~]' | cut -c 1-$ARGON2_MAX_SALT_LENGTH) # generate ASCII string from [!] to [~]
#
#########################################################
#
# "Argonize" -> argon 2 used as another obfuscator
#
echo "Computing ARGON2..."
ARGON2_OUTPUT=$(echo -n "'$ARGON2_PASSWORD'" | argon2 $ARGON2_SALT -d -t $ARGON2_ITERATIONS -m $ARGON2_MEMORY -p $ARGON2_CPU_THREADS -l $ARGON2_OBFUSCATOR_LENGTH)
#
#########################################################
#
# Process argon2 output
#
ARGON2_OUTPUT_HASH=$(echo "$ARGON2_OUTPUT" | grep "Hash"  | awk '{ print $2 }')
ARGON2_OUTPUT_HASH+=$(echo "$ARGON2_OUTPUT" | grep "Encoded"  | awk '{ print $2 }')
#
#########################################################
#
# Build and report "deterministic password" to user
#
echo
echo "Outputing $PASSWORD_FINAL_OUTPUT_LENGTH characters length password:"
echo "$ARGON2_OUTPUT_HASH" | xxd -r -p | tr -cd '[!-~]' | cut -c 1-$PASSWORD_FINAL_OUTPUT_LENGTH # generate ASCII string from [!] to [~]
echo

