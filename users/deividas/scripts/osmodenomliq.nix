{ pkgs }:

pkgs.writeShellScriptBin "osmodenomliq" ''
  # Check if at least one argument (DENOM) is provided
  if [[ -z "$1" ]]; then
  	echo "Usage: $0 <DENOM> [GRPC_ADDR]"
  	exit 1
  fi

  # Set DENOM from first argument
  DENOM="$1"

  # Set GRPC_ADDR from second argument or default to osmosis-grpc.publicnode.com:443
  GRPC_ADDR="''${2:-grpc.osmosis.zone:443}"

  echo "Using DENOM: $DENOM"
  echo "Using GRPC_ADDR: $GRPC_ADDR"

  # Get the list of pool IDs and addresses together
  POOLS_JSON=$(osmosisd query poolmanager list-pools-by-denom "$DENOM" --grpc-addr $GRPC_ADDR -o json)

  # Extract pool IDs and addresses as key-value pairs
  mapfile -t POOL_LIST < <(echo "$POOLS_JSON" | jq -r '.pools[] | "\(.id // .pool_id) \(.address // .contract_address)"')

  TOTAL_AMOUNT=0

  # Loop through each pool and extract information
  for POOL_ENTRY in "''${POOL_LIST[@]}"; do
      # Extract Pool ID and Address
      POOL_ID=$(echo "$POOL_ENTRY" | awk '{print $1}')
      POOL_ADDRESS=$(echo "$POOL_ENTRY" | awk '{print $2}')

      # Query balances for the pool address
      BALANCE_JSON=$(osmosisd query bank balances "$POOL_ADDRESS" --grpc-addr $GRPC_ADDR -o json 2>&1) # 2>&1 redirects stderr to stdout

      # Extract the amount for the specific denom
      AMOUNT=$(echo "$BALANCE_JSON" | jq -r --arg DENOM "$DENOM" '.balances[] | select(.denom == $DENOM) | .amount')

      echo "Pool ID: $POOL_ID, Address: $POOL_ADDRESS, Amount: $AMOUNT"

      # If amount exists, add it to total
      if [[ -n "$AMOUNT" && "$AMOUNT" != "null" ]]; then
  		TOTAL_AMOUNT=$(awk "BEGIN {print $TOTAL_AMOUNT + $AMOUNT}")
          # TOTAL_AMOUNT=$((TOTAL_AMOUNT + AMOUNT))
      fi
  done

  echo "Total amount of $DENOM across all pools: $TOTAL_AMOUNT"
''
