param (
    [int]$vs_version = 2017,
    [string]$build_config = 'Release',
    [string]$build_dir = "",
    [string]$build_tests = "On",
    [string]$install_dir = "",

    [switch]$build,
    [switch]$test,
    [switch]$package
)

$HORACE_ROOT = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '/../..')
if ($build_dir -eq "") {
    $build_dir = Join-Path -Path $HORACE_ROOT -ChildPath 'build'
}
if ($install_dir -eq "") {
    $install_dir = Join-Path -Path $HORACE_ROOT -ChildPath 'install'
}

try {
    Write-Output "Creating build directory: $build_dir"
    New-Item -Path $build_dir -ItemType Directory -ErrorAction Stop | Out-Null
}
catch [System.IO.IOException] {
    Write-Warning $_.Exception.Message
    Write-Warning "This may not be a clean build."
}

$VS_VERSION_MAP = @{
    2015 = 'Visual Studio 14 2015';
    2017 = 'Visual Studio 15 2017';
    2019 = 'Visual Studio 16 2019';
}
$cmake_generator = $VS_VERSION_MAP[$vs_version]

Write-Output "$(cmake --version)"
Write-Output "Matlab $($(matlab -help | Select-String Version).ToString().trim())"
Write-Output "Visual Studio version: $cmake_generator"


function Invoke-Build() {
    Write-Output "`nRunning CMake configure step..."
    $cmake_cmd = "cmake -S $HORACE_ROOT -B $build_dir"
    $cmake_cmd += " -DCMAKE_INSTALL_PREFIX=""$install_dir"""
    if ($build_tests -eq "Off") {
        $cmake_cmd += " -DBUILD_TESTS=OFF"
    }
    else {
        $cmake_cmd += " -DBUILD_TESTS=ON"
    }

    if ($vs_version -eq 'VS2019') {
        $cmake_cmd += " -G ""$cmake_generator"" -A x64"
    }
    else {
        $cmake_cmd += " -G ""$cmake_generator Win64"""
    }

    Invoke-Expression $cmake_cmd
    if ($LASTEXITCODE -ne 0) {
        exit 1
    }

    Write-Output "`nRunning CMake build step..."
    cmake --build $build_dir --config $build_config
    if ($LASTEXITCODE -ne 0) {
        exit 1
    }
}

function Invoke-Test() {
    Write-Output "`nRunning test step..."
    Push-Location -Path $build_dir
    try {
        ctest -C $build_config -T Test
    }
    finally {
        Pop-Location
    }
    if ($LASTEXITCODE -ne 0) {
        exit 1
    }
}

function Invoke-Package() {
    Write-Output "`nRunning package step..."
    # cmake --build . --target install
}

if ($build -eq $true) {
    Invoke-Build
}

if ($test -eq $true) {
    Invoke-Test
}

if ($package -eq $true) {
    Invoke-Package
}
