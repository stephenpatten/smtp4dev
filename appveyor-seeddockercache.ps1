$headers = @{
    "Authorization" = "Bearer $($env:APPVEYORAPIKEY)"
    "Content-type" = "application/json"
  }

write-host "Seeding docker cache from previous jobs: $($env:APPVEYOR_JOB_NAME)"
$project = Invoke-RestMethod -Uri "https://ci.appveyor.com/api/projects/rnwood/smtp4dev/history?recordsnumber=50" -Headers $headers  -Method Get

foreach($build in $project.builds) {
    $builddetail = Invoke-RestMethod -Uri "https://ci.appveyor.com/api/projects/rnwood/smtp4dev/build/$($build.version)" -Headers $headers  -Method Get
    $jobid = [string] ($builddetail.build.jobs | where-object { $_.name  -eq $env:APPVEYOR_JOB_NAME} | select-object -First 1 -ExpandProperty jobId)

    if ($jobid) {
        $artifact = @(Invoke-RestMethod -Uri "https://ci.appveyor.com/api/buildjobs/$jobid/artifacts" -Headers $headers)[0]
        
        if ($artifact) {
            write-host "Using $($artifact.fileName)"
            Invoke-WebRequest -OutFile $artifact.fileName -Uri "https://ci.appveyor.com/api/buildjobs/$jobid/artifacts/$($artifact.fileName)"
            docker load -i "$($artifact.fileName)"
            break;
        } else {
            write-host "Build $($build.version) job $jobid has no artifacts"
        }
    } else {
        write-host "Build $($build.version) has no matching job"
    }
}