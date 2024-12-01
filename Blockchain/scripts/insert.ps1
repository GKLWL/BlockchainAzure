param (
    [string]$c # Case ID
)

function Insert-Item {
    param (
        [string]$c
    )

    [string] $i = "100"

    $file_path = "chain/blockchain_data"

    if (-not (Test-Path -Path $file_path)) {
        Write-Error "Error: Blockchain file not found."
        return $false
    }

    $case_id = $c.PadRight(32).Substring(0, 32) # Ensure case_id is exactly 32 bytes
    $prev_hash = [byte[]]@(0) * 20
    $prev_id = @()

    $fs = [System.IO.File]::OpenRead($file_path)
    $reader = New-Object System.IO.BinaryReader($fs)

    while ($fs.Position -lt $fs.Length) {
        # Determine the block size to read
        if ($fs.Position -eq 0) {
            $block_size = 64
        } else {
            $block_size = 79
        }

        # Read the block
        $head_content = $reader.ReadBytes($block_size)

        if ($head_content.Length -lt $block_size) {
            continue
        }

        # Parse block header fields
        $curr_block_head = if ($fs.Position -eq 64) {
            [PSCustomObject]@{
                hash      = $head_content[0..19]
                timestamp = [BitConverter]::ToUInt64($head_content, 20)
                case_id   = [System.Text.Encoding]::ASCII.GetString($head_content[28..43]).Trim() # 16 bytes for initial block case ID
                item_id   = [BitConverter]::ToUInt32($head_content, 44)
                state     = [System.Text.Encoding]::ASCII.GetString($head_content[48..58]).Trim()
                length    = [BitConverter]::ToUInt32($head_content, 59)
            }
        } else {
            try{
                [PSCustomObject]@{
                    hash      = $head_content[0..19]
                    timestamp = [BitConverter]::ToUInt64($head_content, 20)
                    case_id   = [System.Text.Encoding]::ASCII.GetString($head_content[28..59]).Trim() # 32 bytes for subsequent blocks case ID
                    item_id   = [BitConverter]::ToUInt32($head_content, 60)
                    state     = [System.Text.Encoding]::ASCII.GetString($head_content[64..74]).Trim()
                    length    = [BitConverter]::ToUInt32($head_content, 75)
                }
            } catch {
            continue
            }
        }

        try {
            # Read block data
            $data_content = $reader.ReadBytes([int32]$curr_block_head.length)
            $prev_hash = [System.Security.Cryptography.SHA1]::Create().ComputeHash($head_content + $data_content)
        } catch {
            Write-Error "Error: Failed to read block data. Skipping block..."
            continue
        }

        $prev_id += $curr_block_head.item_id
    }

    $reader.Close()
    $fs.Close()

    if (-not $i) {
        $i = ($prev_id | Measure-Object).Count + 1
        Write-Host "Generated unique item ID: $i" -ForegroundColor Cyan
    }

    if ($prev_id -contains [int32]$i) {
        Write-Error "Error: Duplicate Entry."
        return $false
    }

    $now = [DateTimeOffset]::Now.ToUnixTimeSeconds()

    # Construct block header (79 bytes)
    $head_values = @(
        $prev_hash, # 20 bytes
        [BitConverter]::GetBytes([int64]$now), # 8 bytes
        [System.Text.Encoding]::ASCII.GetBytes($case_id), # 32 bytes
        [BitConverter]::GetBytes([int32]$i), # 4 bytes
        [System.Text.Encoding]::ASCII.GetBytes("CHECKEDIN".PadRight(11).Substring(0, 11)), # 11 bytes
        [BitConverter]::GetBytes([int32]14) # 4 bytes (indicates data size = 14 bytes)
    )

    $head_bytes = New-Object System.Collections.Generic.List[byte]
    foreach ($val in $head_values) {
        $head_bytes.AddRange($val)
    }
    $head_values_combined = $head_bytes.ToArray()

    # Validate header size (79 bytes)
    if ($head_values_combined.Length -ne 79) {
        Write-Error "Header size mismatch: Expected 79 bytes, got $($head_values_combined.Length) bytes."
        return $false
    }

    # Construct block data (14 bytes)
    $data_value = [System.Text.Encoding]::ASCII.GetBytes("Checked-in item".PadRight(14).Substring(0, 14))

    # Validate total block size
    $total_written = $head_values_combined.Length + $data_value.Length
    if ($total_written -ne 93) {
        Write-Error "Block size mismatch: Expected 93 bytes, got $total_written bytes."
        return $false
    }

    # Append the block to the blockchain file
    $fs = [System.IO.File]::Open($file_path, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write)
    $writer = New-Object System.IO.BinaryWriter($fs)

    # Write exactly 79 bytes (header) + 14 bytes (data) = 93 bytes
    $writer.Write($head_values_combined) # Write 79 bytes (header)
    $writer.Write($data_value)          # Write 14 bytes (data)

    $writer.Close()
    $fs.Close()

    # Output success message
    Write-Output "Added item: $i"
    Write-Output "`tItem: $c"
    Write-Output "`tStatus: CHECKEDIN"
    Write-Output "`tTime of action (raw timestamp): $now"
    Write-Output "`tTime of action (formatted): $([DateTimeOffset]::FromUnixTimeSeconds($now).ToString("yyyy-MM-ddTHH:mm:ssZ"))"

    return $true
}

Insert-Item -c $c
