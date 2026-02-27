#!/bin/ksh

# script uses hledger to generate a financial report file
# to be put in a chron job for automation

_date="$(date)";
_report="$(date '+%Y-%m-%d')-financial_report";
touch ~/finance/weekly_reports/$_report;
_path="$(printf '~/finance/weekly_reports/%s' $_report)";



printf "\n\n\n=====================================================\n" >> $_report;
printf "===== Report for: " >> $_path;
printf "%s " $_date >> $_path;
printf " ===== \n" >> $_path;
printf "=====================================================\n\n" >> $_path;

printf "\n\n\n\n======================\n" >> $_path;
printf "===== Statistics =====\n" >> $_path;
printf "======================\n\n" >> $_path;
hledger stats >> $_path;

printf "\n\n\n\n=================================\n" >> $_path;
printf "====| Budget: food expenses |====\n" >> $_path;
printf "=================================\n\n" >> $_path;
hledger bal --budget expenses:food expenses:dorotka:food >> $_path;

printf "\n\n\n\n=======================\n" >> $_path;
printf "====| Liabilities |====\n" >> $_path;
printf "=======================\n\n" >> $_path;
hledger bs assets:receivable:dorotka liabilities:dorotka >> $_path;

printf "\n\n\n\n============================\n" >> $_path;
printf "====| Income statement |====\n" >> $_path;
printf "============================\n\n" >> $_path;
hledger is >> $_path;

printf "\n\n\n\n=========================\n" >> $_path;
printf "====| Balance sheet |====\n" >> $_path;
printf "=========================\n\n" >> $_path;
hledger bs >> $_path;

printf "\n\n\n\n=====================\n" >> $_path;
printf "====| Cash flow |====\n" >> $_path;
printf "=====================\n\n" >> $_path;
hledger cf >> $_path;

printf "\n\n\n\n" >> $_path;

