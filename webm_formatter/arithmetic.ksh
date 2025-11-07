#!/bin/ksh
typeset a
result=$(echo "3.5 + 2.1" | bc -l)
echo $result   
# b=(( 2.1 ))
#

a=1.72
b=1.71
 
if [ "$(printf '%s > %s\n' "$a" "$b" | bc -l)" -eq 1 ]; then
   echo "a is greater than b"
else
   echo "a is not greater than b"
fi   

# basic operation

numberOne=134
numberTwo=22

result=$(echo "3.5 + 2.1" | bc -l)

let "result = numberOne + numberTwo"

result=$((result * (2 + 2) + numberOne))

(( result = result * 33 ))

echo "$result"

