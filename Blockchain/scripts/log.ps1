param (
    [switch]$reverse,
    [int]$num_entries,
    [string]$case_id,
    [string[]]$item_id
)

function Log-Blockchain {
    $file_path = "chain/blockchain_data"

    if (-not (Test-Path -Path $file_path)) {
        Write-Error "Blockchain file not found: $file_path"
        return
    }

    $blocks = @()
    $fp = [System.IO.File]::OpenRead($file_path)
    $reader = New-Object System.IO.BinaryReader($fp)

    Write-Host "Reading blocks from the blockchain file..."
    Write-Host "File size: $($fp.Length) bytes"

    $first_block_size = 77
    $subsequent_block_size = 93
    $current_position = 0
    $block_count = 0

    try {
        while ($current_position -lt $reader.BaseStream.Length) {
            # Determine the block size: 77 bytes for the first block, 94 bytes for subsequent blocks
            $block_size = if ($block_count -eq 0) { $first_block_size } else { $subsequent_block_size }

            # Check if there are enough bytes remaining in the file for a complete block
            if (($reader.BaseStream.Length - $current_position) -lt $block_size) {
                Write-Host "End of file reached at position $current_position. Stopping."
                break
            }

            # Read the block
            $block_content = $reader.ReadBytes($block_size)
    

            # Parse block fields (replace with actual parsing logic if needed)
            if ($block_count -eq 0) {
                Write-Host "Reading first block (77 bytes)..."
            } else {
                Write-Host "Reading block $block_count (93 bytes)..."
            }

            # Parse fields from the block
            # Replace these example fields with actual logic to extract relevant data
            $hash = ($block_content[0..19] | ForEach-Object { $_.ToString("X2") }) -join ''
            $timestamp_bytes = $block_content[20..27]
            $timestamp = [BitConverter]::ToUInt64($timestamp_bytes, 0)
            $date_time = (Get-Date "1970-01-01 00:00:00").AddSeconds($timestamp)
            $case_id = if ($block_count -eq 0) { "FIRST_BLOCK" } else { [System.Text.Encoding]::ASCII.GetString($block_content[28..59]).Trim() }

            # Add block to the list
            $blocks += [PSCustomObject]@{
                BlockNumber = $block_count
                Hash        = $hash
                Timestamp   = $date_time
                Item      = $case_id
                Position    = $current_position
            }
            $current_position += $block_size

            $block_count++
        }
    } catch {
        Write-Error "Error reading block at position $($current_position): $_"
    } finally {
        # Ensure file and reader are closed
        $reader.Close()
        $fp.Close()
    }

    if ($blocks.Count -eq 0) {
        Write-Output "No blocks found."
        return
    }

    Write-Output $blocks
    
}

# Call the function with parameters
Log-Blockchain -reverse:$reverse -num_entries $num_entries -case_id $case_id -item_id $item_id
