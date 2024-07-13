#!/bin/bash

# Function to log with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to print separator
print_separator() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '='
}

# Print separator and start time
print_separator
log "Script started"

# Email configuration
FROM="request@domain.lex.ma"
SUBJECT_PREFIX="P(DROP)"
BODY="isitjoever.com"

# File paths
PROBABILITY_FILE="isitjoever.com/probability.txt"
SUBSCRIBERS_FILE="isitjoever.com/subscribers.csv"

log "Using probability file: $PROBABILITY_FILE"
log "Using subscribers file: $SUBSCRIBERS_FILE"

# Function to send email
send_email() {
    local to="$1"
    local subject="$2"
    local body="$3"
    
    email_content=$(cat <<EOF
From: $FROM
To: $to
Subject: $subject

$body
EOF
)
    
    echo "$email_content" | /usr/sbin/sendmail -t
    
    if [ $? -eq 0 ]; then
        log "Email sent successfully to $to with subject '$subject'"
    else
        log "Failed to send email to $to with subject '$subject'"
    fi
}

# Function to update subscriber file
update_subscriber_file() {
    local email="$1"
    local column="$2"
    log "Updating subscriber file for $email, column $column"
    awk -F',' -v email="$email" -v col="$column" 'BEGIN {OFS=","} 
    NR==1 {for (i=1; i<=NF; i++) if ($i == col) {col_index = i}} 
    $1 == email {$col_index = 0} 
    {print}' "$SUBSCRIBERS_FILE" > "${SUBSCRIBERS_FILE}.tmp" && mv "${SUBSCRIBERS_FILE}.tmp" "$SUBSCRIBERS_FILE"
    log "Subscriber file updated"
}

# Function to compare floats
compare_floats() {
    awk -v n1="$1" -v n2="$2" 'BEGIN {if (n1<n2) exit 0; exit 1}'
}

# Read probability
probability=$(cat "$PROBABILITY_FILE")
log "Current probability: $probability"

# Check if probability is within the target range
if compare_floats "$probability" 0.3 || compare_floats 0.7 "$probability"; then
    log "Probability is outside normal range. Processing subscribers."
    # Read subscribers file
    while IFS=',' read -r email l30 l20 l10 g70 g80 g90 || [ -n "$email" ]; do
        if [ "$email" != "email" ]; then  # Skip header
            log "Processing subscriber: $email"
            if compare_floats "$probability" 0.1 && [ "$l10" -eq 1 ]; then
                log "Probability < 10% for $email"
                send_email "$email" "${SUBJECT_PREFIX}<10%" "$BODY"
                update_subscriber_file "$email" "l10"
            elif compare_floats "$probability" 0.2 && [ "$l20" -eq 1 ]; then
                log "Probability < 20% for $email"
                send_email "$email" "${SUBJECT_PREFIX}<20%" "$BODY"
                update_subscriber_file "$email" "l20"
            elif compare_floats "$probability" 0.3 && [ "$l30" -eq 1 ]; then
                log "Probability < 30% for $email"
                send_email "$email" "${SUBJECT_PREFIX}<30%" "$BODY"
                update_subscriber_file "$email" "l30"
            elif compare_floats 0.9 "$probability" && [ "$g90" -eq 1 ]; then
                log "Probability > 90% for $email"
                send_email "$email" "${SUBJECT_PREFIX}>90%" "$BODY"
                update_subscriber_file "$email" "g90"
            elif compare_floats 0.8 "$probability" && [ "$g80" -eq 1 ]; then
                log "Probability > 80% for $email"
                send_email "$email" "${SUBJECT_PREFIX}>80%" "$BODY"
                update_subscriber_file "$email" "g80"
            elif compare_floats 0.7 "$probability" && [ "$g70" -eq 1 ]; then
                log "Probability > 70% for $email"
                send_email "$email" "${SUBJECT_PREFIX}>70%" "$BODY"
                update_subscriber_file "$email" "g70"
            else
                log "No action needed for $email"
            fi
        fi
    done < "$SUBSCRIBERS_FILE"
else
    log "Probability is within normal range (0.3 - 0.7). No actions taken."
fi

# Print end time and separator
log "Script finished"
print_separator

