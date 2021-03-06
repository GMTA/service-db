#!/usr/bin/env bats

# Debugging
teardown () {
	echo
	# TODO: figure out how to deal with this (output from previous run commands showing up along with the error message)
	echo "Note: ignore the lines between \"...failed\" above and here"
	echo
	echo "Status: $status"
	echo "Output:"
	echo "================================================================"
	echo "$output"
	echo "================================================================"
}

# Global skip
# Uncomment below, then comment skip in the test you want to debug. When done, reverse.
#SKIP=1

@test "MySQL initialization" {
	[[ $SKIP == 1 ]] && skip

	### Setup ###
	make start
	sleep 30 # TODO: replace with a healthcheck

	### Tests ###
	# MySQL does a restart, so there should be two of these in the logs after a successful start
	run bash -c 'make logs 2>&1 | grep "mysqld: ready for connections" | wc -l'
	[[ "$output" =~ "2" ]]
}

@test "Default database present" {
	[[ $SKIP == 1 ]] && skip

	run make mysql-query QUERY='SHOW DATABASES;'
	[[ "$output" =~ "default" ]]
}

@test "Check variables" {
	[[ $SKIP == 1 ]] && skip

	# Grab variables from the container
	# -s used to supress echoing of the actual make command
	mysqlVars=$(make -s mysql-query QUERY='SHOW VARIABLES;')
	# Compare with the expected values
	# This will trigger a diff only when a variable from mysql-variables.txt is missing or modified in $mysqlVars
	run bash -c "echo '$mysqlVars' | diff --changed-group-format='%<' --unchanged-group-format='' mysql-variables.txt -"
	[[ "$output" == "" ]]
}
