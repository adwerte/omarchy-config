<#
.SYNOPSIS
Sends the Helix selection to a Copilot session running in psmux.

.DESCRIPTION
Helix's :pipe-to command writes the active selection to this script's standard
input. An optional prompt provided through Helix's command line is sent before
the selection. The completed message is sent literally to the configured psmux
target, followed by Enter to submit the prompt.

.PARAMETER AdditionalPrompt
Optional instructions supplied through Helix's :pipe-to command. All remaining
words are included, so quotation marks are not required.

.EXAMPLE
Select text, press Ctrl-P, and enter:
pipe-to powershell.exe -NoProfile -ExecutionPolicy Bypass -File %%AppData%%\helix\send-selection-to-copilot.ps1 -AdditionalPrompt "Explain this code"
#>
param(
    [string]$AdditionalPrompt
)

try {
    $Target = "copilot"
    $Message = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrEmpty($Message)) {
        throw "No selected text was received. Select text in Helix before invoking this command."
    }

    $additionalPromptText = (@($AdditionalPrompt) + @($args) -join " ").Trim()
    if (-not [string]::IsNullOrWhiteSpace($additionalPromptText)) {
        $Message = "$additionalPromptText`n`n$Message"
    }

    psmux send-keys -t $Target -l -- $Message
    if ($LASTEXITCODE -ne 0){
        throw "Unable to send mesasge to psmux"
    }
    psmux send-keys -t $Target Enter
    if ($LASTEXITCODE -ne 0){
        throw "Unable to send mesasge to psmux"
    }




}
catch {
    Write-Error "Unable to send the Helix selection to Copilot: $($_.Exception.Message)"
    exit 1
}
