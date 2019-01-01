Param(
    [string]$ComputerName
)
Function Start-PwshTest
{
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        HelpMessage="LogMessage:")]
	    [string] $ComputerName
    )

    Function Run-WinTests($runParams)
    {
        [psobject]$spoolerService = get-service -Computername testpc1 | select Name, Status | where{$_.Name -match "spooler"}
    
        $connTestGood = Test-Connection -ComputerName testpc1 -Count 1 -Quiet
        $connTestBad = Test-Connection -Computername testpc2 -Count 1 -Quiet

        [psobject]$outObj = @{
            Date = $runParams.ts
            Architecture = $runParams.os
            ComputerName = $runParams.ComputerName
            FunctionName = $runParams.functionName
            SpoolerObj = @{
                Name = $spoolerService.Name
                Status = $spoolerService.Status
            }
            GoodConnTest = $connTestGood
            BadConnTest = $connTestBad
        }
        if(Test-Path -Path c:\temp\pwshouttest.txt)
        {
            Remove-Item C:\temp\pwshouttest.txt -Force
        }
        $outObj | out-file c:\temp\pwshouttest.txt
        return $outObj
    }

    Function Run-LinTests($runParams)
    {
        $procCheck = get-process | select ProcessName, Id, CPU | where{$_.ProcessName -match "slack"} 

        [psobject]$outObj = @{
            Date = $runParams.ts
            Architecture = $runParams.os
            ComputerName = $runParams.ComputerName
            FunctionName = $runParams.functionName
            SlackProc = @{
                ProcessName = $procCheck.ProcessName[0]
                ID = $procCheck.Id[0]
                CPU = $procCheck.CPU[0]
            }
        }
        if(Test-Path -Path /home/noobish/pwshouttest.txt)
        {
            Remove-Item /home/noobish/pwshouttest.txt
        }
        $outObj | out-file /home/noobish/pwshouttest.txt
        return $outObj
    }

    $functionName = $MyInvocation.MyCommand.Name 
    $date = Get-date
    [string]$ts = $date.ToString("MM-dd-yyyy-HH:MM:ss")
    $winpath = "*:/*"                                                                                           
    $linpath = "/*"                                                                                             
    if(test-path -path $winpath)
    {
        $os = "Windows/x64-x86"
        $runObj = @{
            ts = $ts
            os = $os
            ComputerName = $ComputerName
            FunctionName = $functionName
        }
        write-host "windows"
        $output = Run-WinTests $runObj
    }                                                          
    elseif(test-path -path $linpath)
    {
        $os = "x64/Linux/Unix"
        $runObj = @{
            ts = $ts
            os = $os
            ComputerName = $ComputerName
            FunctionName = $functionName
        }
        write-host "lindows"
        $output = Run-LinTests $runObj
    }   


    $body = @{
        os_arch = $os
        script_name = $functionName
        host_name = $ComputerName
    }
    
    $Uri = "http://localhost:3000/runlog"
    Invoke-WebRequest -Uri $Uri -Body $body -Method POST

    return $output | ConvertTo-JSON
}
Start-PwshTest -Computername $ComputerName
