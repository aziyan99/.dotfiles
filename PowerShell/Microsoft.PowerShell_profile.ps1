Write-Host "( .-.)"

function Get-GitBranch {
  $gitDir = (Resolve-Path -Path ".git" -ErrorAction SilentlyContinue)
    if($gitDir){
      if(Get-Command git -ErrorAction SilentlyContinue){
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
          if($branch){
            $status = git status --porcelain
            if($status){
                $branch += "*"
            }
            return "$branch"
          }
      }
    }
  return "-1"
}

function prompt {
  $currentPath = Get-Location
    $currentDirectory = Split-Path $currentPath -Leaf
    $gitBranch = Get-GitBranch

    $resetColor = "`e[0m"
    $gitBranchColor = "`e[32m"  # Green color

    if($gitBranch -ne "-1"){
      "$currentDirectory ($gitBranchColor$gitBranch$resetColor)> "
    }else{
      "$currentDirectory> "
    }
}

