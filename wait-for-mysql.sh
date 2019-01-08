#!/usr/bin/env bash
#   Use this script to test if a given TCP host/port are available

WAITFORMYSQL_cmdname=${0##*/}

echoerr() { if [[ $WAITFORMYSQL_QUIET -ne 1 ]]; then echo "$@" 1>&2; fi }

usage()
{
    cat << USAGE >&2
Usage:
    $WAITFORMYSQL_cmdname host:port [-t timeout] [-- command args]
    -h HOST | --host=HOST       Host or IP of MySQL Server
    -p PORT | --port=PORT       Port of MySQL Server
                                Alternatively, you specify the host and port as host:port
    -u USER | --user=USER       User to authenticate as
    -p PASSWORD | --password=PASSWORD
                                Password of the user to authenticate as
    -d DATABASE | --database=DATABASE
                                Name of the database
    -q | --quiet                Do not output any status messages
    -t TIMEOUT | --timeout=TIMEOUT
                                Timeout in seconds, zero for no timeout
    -- COMMAND ARGS             Execute command with args after the test finishes
USAGE
    exit 1
}

wait_for_mysql()
{
    if [[ $WAITFORMYSQL_TIMEOUT -gt 0 ]]; then
        echoerr "$WAITFORMYSQL_cmdname: waiting $WAITFORMYSQL_TIMEOUT seconds for MySQL server ($WAITFORMYSQL_HOST:$WAITFORMYSQL_PORT)"
    else
        echoerr "$WAITFORMYSQL_cmdname: waiting for MySQL server ($WAITFORMYSQL_HOST:$WAITFORMYSQL_PORT) without a timeout"
    fi

    WAITFORMYSQL_start_ts=$(date +%s)
    WAITFORMYSQL_i=0
    while :
    do
        (mysql -h $WAITFORMYSQL_HOST -P $WAITFORMYSQL_PORT -u $WAITFORMYSQL_USER -p$WAITFORMYSQL_PASSWORD -e 'SELECT 1' $WAITFORMYSQL_DATABASE) >/dev/null 2>&1
        WAITFORMYSQL_result=$?

        if [[ $WAITFORMYSQL_result -eq 0 ]]; then
            WAITFORMYSQL_end_ts=$(date +%s)
            echoerr "$WAITFORMYSQL_cmdname: MySQL server ($WAITFORMYSQL_HOST:$WAITFORMYSQL_PORT) is available after $((WAITFORMYSQL_end_ts - WAITFORMYSQL_start_ts)) seconds"
            break
        fi
        WAITFORMYSQL_i=$((WAITFORMYSQL_i+1))
        if [[ $WAITFORMYSQL_i -gt $WAITFORMYSQL_TIMEOUT ]]; then
            WAITFORMYSQL_result=1
            break
        fi

        sleep 1
    done
    return $WAITFORMYSQL_result
}

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        *:* )
        WAITFORMYSQL_hostport=(${1//:/ })
        WAITFORMYSQL_HOST=${WAITFORMYSQL_hostport[0]}
        WAITFORMYSQL_PORT=${WAITFORMYSQL_hostport[1]}
        shift 1
        ;;
        -q | --quiet)
        WAITFORMYSQL_QUIET=1
        shift 1
        ;;
        -h)
        WAITFORMYSQL_HOST="$2"
        if [[ $WAITFORMYSQL_HOST == "" ]]; then break; fi
        shift 2
        ;;
        --host=*)
        WAITFORMYSQL_HOST="${1#*=}"
        shift 1
        ;;
        -P)
        WAITFORMYSQL_PORT="$2"
        if [[ $WAITFORMYSQL_PORT == "" ]]; then break; fi
        shift 2
        ;;
        --port=*)
        WAITFORMYSQL_PORT="${1#*=}"
        shift 1
        ;;
        -u)
        WAITFORMYSQL_USER="$2"
        if [[ $WAITFORMYSQL_USER == "" ]]; then break; fi
        shift 2
        ;;
        --user=*)
        WAITFORMYSQL_USER="${1#*=}"
        shift 1
        ;;
        -p)
        WAITFORMYSQL_PASSWORD="$2"
        if [[ $WAITFORMYSQL_PASSWORD == "" ]]; then break; fi
        shift 2
        ;;
        --password=*)
        WAITFORMYSQL_PASSWORD="${1#*=}"
        shift 1
        ;;
        -d)
        WAITFORMYSQL_DATABASE="$2"
        if [[ $WAITFORMYSQL_DATABASE == "" ]]; then break; fi
        shift 2
        ;;
        --database=*)
        WAITFORMYSQL_DATABASE="${1#*=}"
        shift 1
        ;;
        -t)
        WAITFORMYSQL_TIMEOUT="$2"
        if [[ $WAITFORMYSQL_TIMEOUT == "" ]]; then break; fi
        shift 2
        ;;
        --timeout=*)
        WAITFORMYSQL_TIMEOUT="${1#*=}"
        shift 1
        ;;
        --)
        shift
        WAITFORMYSQL_CLI=("$@")
        break
        ;;
        --help)
        usage
        ;;
        *)
        echoerr "Unknown argument: $1"
        usage
        ;;
    esac
done

WAITFORMYSQL_TIMEOUT=${WAITFORMYSQL_TIMEOUT:-30}
WAITFORMYSQL_PORT=${WAITFORMYSQL_PORT:-3306}
WAITFORMYSQL_QUIET=${WAITFORMYSQL_QUIET:-0}

if [[ "$WAITFORMYSQL_HOST" == "" ]]; then
    echoerr "Error: you need to provide a host of the MySQL server."
    usage
fi

if [[ "$WAITFORMYSQL_USER" == "" || "$WAITFORMYSQL_PASSWORD" == "" ]]; then
    echoerr "Error: you need to provide an user and password"
    usage
fi

if [[ "$WAITFORMYSQL_DATABASE" == "" ]]; then
    echoerr "Error: you need to specify a database name"
    usage
fi

wait_for_mysql

WAITFORMYSQL_RESULT=$?

if [[ $WAITFORMYSQL_CLI != "" ]]; then
    exec "${WAITFORMYSQL_CLI[@]}"
else
    exit $WAITFORMYSQL_RESULT
fi
