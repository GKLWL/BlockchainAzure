param (
    [string]$file_path = "chain/blockchain_data"
)

function Initialize-Blockchain {
    # Create the chain directory if it doesn't exist
    if (-not (Test-Path -Path "chain")) {
        New-Item -ItemType Directory -Path "chain" | Out-Null
    }

    # Check if the blockchain file exists
    if (-not (Test-Path -Path $file_path)) {
        Write-Output "Blockchain file not found. Creating Initial Block..."

        # Calculate the timestamp
        $now = [DateTimeOffset]::Now.ToUnixTimeSeconds()

        $head_values = @{
            hash      = ""
            timestamp = $now
            case_id   = ""
            item_id   = 0
            state     = "INITIAL"
            length    = 14
        }
        $data_value = "Initial block"

        # Create a binary writer to write the initial block
        $fs = [System.IO.File]::Create($file_path)
        $writer = New-Object System.IO.BinaryWriter($fs)

        try {
            # Write header
            $writer.Write([System.Text.Encoding]::ASCII.GetBytes($head_values.hash.PadRight(20)))
            $writer.Write([BitConverter]::GetBytes([int64]$head_values.timestamp))
            $writer.Write([System.Text.Encoding]::ASCII.GetBytes($head_values.case_id.PadRight(16)))
            $writer.Write([BitConverter]::GetBytes([int32]$head_values.item_id))
            $writer.Write([System.Text.Encoding]::ASCII.GetBytes($head_values.state.PadRight(11)))
            $writer.Write([BitConverter]::GetBytes([int32]$head_values.length))

            # Write data
            $writer.Write([System.Text.Encoding]::ASCII.GetBytes($data_value.PadRight(14)))

            Write-Output "Blockchain initialized with Initial Block."
        } finally {
            $writer.Close()
            $fs.Close()
        }
        return
    }

    # Read and validate the initial block in the blockchain file
    $fs = [System.IO.File]::OpenRead($file_path)
    $reader = New-Object System.IO.BinaryReader($fs)

    try {
        # Read header
        $hash = [System.Text.Encoding]::ASCII.GetString($reader.ReadBytes(20)).Trim()
        $timestamp = [BitConverter]::ToUInt64($reader.ReadBytes(8), 0)
        $case_id = [System.Text.Encoding]::ASCII.GetString($reader.ReadBytes(16)).Trim()
        $item_id = [BitConverter]::ToUInt32($reader.ReadBytes(4), 0)
        $state = [System.Text.Encoding]::ASCII.GetString($reader.ReadBytes(11)).Trim()
        $length = [BitConverter]::ToUInt32($reader.ReadBytes(4), 0)

        # Read data
        $data = [System.Text.Encoding]::ASCII.GetString($reader.ReadBytes($length)).Trim()
    } catch {
        Write-Output "Error: Failed to read and validate the initial block."
        return
    } finally {
        $reader.Close()
        $fs.Close()
    }

    if ($state -eq "INITIAL") {
        Write-Output "Success: Blockchain file contains a valid Initial Block."
    } else {
        Write-Output "Error: Blockchain file does not contain a valid Initial Block."
    }
}

Initialize-Blockchain
