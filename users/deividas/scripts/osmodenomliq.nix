{ pkgs }:

pkgs.writeShellScriptBin "osmodenomliq" ''
  	  # Default values
  	  GRPC_ADDR="grpc.osmosis.zone:443"
  	  VERBOSE=false

  	  # Print usage/help
  	  usage() {
  		echo "Usage: $0 <DENOM> [--grpc-addr <GRPC_ADDR>] [--verbose]"
  		echo ""
  		echo "Arguments:"
  		echo "  DENOM          (required) Denomination string (e.g., uosmo)"
  		echo ""
  		echo "Options:"
  		echo "  --grpc-addr    (optional) gRPC address (default: grpc.osmosis.zone:443)"
  		echo "  --verbose      (optional) Enable verbose output"
  		exit 1
  	  }

  	  # Check for at least one argument
  	  if [[ $# -lt 1 ]]; then
  		echo "Error: DENOM argument is required"
  		usage
  	  fi

  	  # First argument is DENOM
  	  DENOM="$1"
  	  shift

  	  # Parse flags
  	  while [[ $# -gt 0 ]]; do
  		case "$1" in
  		  --grpc-addr)
  			GRPC_ADDR="$2"
  			shift 2
  			;;
  		  --verbose)
  			VERBOSE=true
  			shift
  			;;
  		  -*|--*)
  			echo "Unknown option: $1"
  			usage
  			;;
  		  *)
  			echo "Unexpected argument: $1"
  			usage
  			;;
  		esac
  	  done

      echo "Using DENOM: $DENOM"
      echo "Using GRPC_ADDR: $GRPC_ADDR"

      # Get the list of pool IDs and addresses together
      POOLS_JSON=$(osmosisd query poolmanager list-pools-by-denom "$DENOM" --grpc-addr $GRPC_ADDR -o json)

      # Extract pool IDs and addresses as key-value pairs
      mapfile -t POOL_LIST < <(echo "$POOLS_JSON" | ${pkgs.jq}/bin/jq -r '.pools[] | "\(.id // .pool_id) \(.address // .contract_address)"')

      TOTAL_AMOUNT=0

      # Loop through each pool and extract information
      for POOL_ENTRY in "''${POOL_LIST[@]}"; do
          # Extract Pool ID and Address
          POOL_ID=$(echo "$POOL_ENTRY" | awk '{print $1}')
          POOL_ADDRESS=$(echo "$POOL_ENTRY" | awk '{print $2}')

          # Query balances for the pool address
          BALANCE_JSON=$(osmosisd query bank balances "$POOL_ADDRESS" --grpc-addr $GRPC_ADDR -o json 2>&1) # 2>&1 redirects stderr to stdout

          # Extract the amount for the specific denom
          AMOUNT=$(echo "$BALANCE_JSON" | ${pkgs.jq}/bin/jq -r --arg DENOM "$DENOM" '.balances[] | select(.denom == $DENOM) | .amount')

          echo "Pool ID: $POOL_ID, Address: $POOL_ADDRESS, Amount: $AMOUNT"
    	  if [[ $VERBOSE == true ]]; then
    		  echo "Balances for pool address $POOL_ADDRESS:"
    		  echo "$BALANCE_JSON" | ${pkgs.jq}/bin/jq
    	  fi

          # If amount exists, add it to total
          if [[ -n "$AMOUNT" && "$AMOUNT" != "null" ]]; then
      		TOTAL_AMOUNT=$(awk "BEGIN {print $TOTAL_AMOUNT + $AMOUNT}")
          fi
      done

      echo "Total amount of $DENOM across all pools: $TOTAL_AMOUNT"
''
