# First we will begin with ...
# Log file for script actions
LOG_FILE="update-dependencies.log"
ERROR_FILE="errors.log"

# Clear the log files if they exist
> "$LOG_FILE"
> "$ERROR_FILE"

# Run gqlgen generate and capture errors
echo "Running gqlgen generate to check for missing dependencies..." | tee -a "$LOG_FILE"
go run github.com/99designs/gqlgen generate 2> "$ERROR_FILE"

# Check for errors in errors.log
if grep -q "missing go.sum entry for module providing package" "$ERROR_FILE"; then
    echo "Identified missing modules. Updating dependencies..." | tee -a "$LOG_FILE"

    # Extract and run the go get commands from errors.log
    grep "go get" "$ERROR_FILE" | while read -r command; do
        if [ -n "$command" ]; then
            echo "Running command: $command" | tee -a "$LOG_FILE"
            # Execute the command
            eval "$command" >> "$LOG_FILE" 2>&1
        fi
    done
else
    echo "No missing modules found or errors in gqlgen generate." | tee -a "$LOG_FILE"
fi

echo "Dependency update process completed." | tee -a "$LOG_FILE"