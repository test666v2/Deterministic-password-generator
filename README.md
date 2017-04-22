# Deterministic-password-generator

## Deterministic password generator using argon2 and SHA-512

### (also bash, awk, tr, xxd, grep, etc and your terminal of choice)

You can have a master password and generate repeatable (deterministic) **"randomized strong"** passwords for you online accounts.

In a terminal window: 

>user@computer:~$ **/path/to/dt_pass_gen.sh**

>>Deterministic password generator (VERY EARLY ALPHA - things may change)
>>
>>Generate "strong" "NON-RANDOM" or "deterministic passwords" for your accounts
>>
>>Stealth Mode
>>
>>Do you want to hide your typing ? Type [ YES ] & press [ ENTER ] for "Stealth Mode" or simply press [ ENTER ] for normal working \> **<pressed the ENTER key\>**
>>
>>Enter website / mail account / whatever (from 1 to 64 characters) ? \> **github.com example_user**
>>
>>Enter master password (forced hidden keyboard typing) (from 1 to 110 characters) ? \> _typed password is_ **12345678_**
>>
>>Iterations for SHA-512 (min=16) ? \> **100**
>>
>>Iterations for ARGON2 (min=16) ? \> **101**
>>
>>Desired length of password (>=11) or press ENTER for the default length of 64 ? \> **70**
>>
>>Computing SHA-512...
>>
>>Computing ARGON2...
>>
>>
>>
>>The built "password" has a size of 5959 characters
>>
>>You can choose a position for the start of the reported position and get 70 continuous characters from this position onwards
>>
>>You can input a number between 1 and 5890
>>
>>Password Position start ? (enter <1> for a no-brainer position) \> **666**
>>
>>
>>Outputing 70 characters length password:
>>
>>,-"6ADo0W"Y^>SQ"Lw@X%VdCm4mM>e0vm;YlAu:o'4GyQh$u\;/|,ziJibOr?Fb4%^SEy3

Copy / paste the password


To get some help, typing in the terminal the script name and any characters displays a small help text:

>user@computer:~$ **/path/to/dt_pass_gen.sh whatever**
>>Deterministic password generator (VERY EARLY ALPHA - things may change)
>>
>>Generate "strong" "NON-RANDOM" or "deterministic passwords" for your accounts
>>
>>It\'s better to use a local (non-online) password manager (keepassx comes to mind) than this script
>>
>>
>>If you want a truly random password, type in terminal
>>
>>head /dev/urandom | tr -dc '[:graph:]' | fold -w64 | shuf -n1
>>
>>
>>If you stil want to use this script, you will have to remember a master password and 2 to 4 numbers (yikes!!)
>>
>>
>>\_(⊙_ʖ⊙)_/     ¯٩(͡๏̯͡๏)۶     (ఠ_ఠ)     (yeah, asking too much from brain power)
>>
>>
>>It asks for:
>>
>>\- a website name / mail address / whatever : this is the salt
>>
>>\- a master password
>>
>>\- the number of SHA-512 iterations (n>=16, defaults to 16) to obfustate the salt; the higher, the better
>>
>>\- the number of argon2 iterations (n>=16, defaults to 16) to obfustate the password (argon 2 has a higher CPU cost than SHA-512); the higher, the better
>>
>>\- an optional password length (minimum is 11 characters); just press ENTER to accept the default 64 characters
>>
>>\- an optional password starting position; just enter <1> for a no-brainer password position
