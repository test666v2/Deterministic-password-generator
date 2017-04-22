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

Copy / paste the passord
