#!/bin/bash
# URL to fetch the JSON data from
URL="https://api.manifold.markets/v0/slug/will-biden-be-the-2024-democratic-n"
# Use curl to fetch the data, grep to find the line with "probability", and awk to extract the value
PROBABILITY=$(curl -s $URL | grep -o '"probability":[^,]*' | awk -F':' '{print $2}')
# Perform the subtraction using Python and save the result to a file
python3 -c "print('{:.4f}'.format(1.0 - float($PROBABILITY)))" > isitjoever.com/probability.txt
# Output the saved probability to verify
echo "Probability saved to probability.txt: $(cat isitjoever.com/probability.txt)"

