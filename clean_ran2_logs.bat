@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
echo 🔍 查詢顯示名稱為「亂2 online TW」的程式路徑...
echo ============================================

set "gamefolder="
for /f "delims=" %%A in ('reg query "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /s ^| findstr /i "亂2 online TW" ^| findstr /i "General\\Game.exe.FriendlyAppName"') do (
    set "line=%%A"
    rem 移除開頭的空白
    set "line=!line:    =!"
    rem 找到 .FriendlyAppName 的位置並截取之前的部分
    for /f "tokens=1 delims=." %%B in ("!line!") do (
        set "exepath=%%B.exe"
        rem 取得資料夾路徑
        for %%P in ("!exepath!") do (
            set "gamefolder=%%~dpP"
            echo 🔍 找到程式資料夾：!gamefolder!
        )
    )
)

if "!gamefolder!"=="" (
    echo ❌ 未找到遊戲安裝路徑
    pause
    exit /b
)

echo.
echo 📁 檔案查詢與統計
echo ==========================================

rem 查詢錯誤報告檔案
echo 🔍 查詢錯誤報告檔案 (GameTW_error_report_*.zip)...
set "errorzip_count=0"
set "errorzip_size=0"
if exist "!gamefolder!GameTW_error_report_*.zip" (
    for %%F in ("!gamefolder!GameTW_error_report_*.zip") do (
        set /a errorzip_count+=1
        set "filesize=%%~zF"
        set /a errorzip_size+=!filesize!
        echo   📄 %%~nxF - !filesize! bytes
    )
) else (
    echo   ℹ️  未找到錯誤報告檔案
)

rem 查詢日誌檔案
echo.
echo 🔍 查詢日誌檔案 (log.*.txt)...
set "logfile_count=0"
set "logfile_size=0"
set "errorspath=!gamefolder!Errors\"
if exist "!errorspath!" (
    if exist "!errorspath!log.*.txt" (
        for %%F in ("!errorspath!log.*.txt") do (
            set /a logfile_count+=1
            set "filesize=%%~zF"
            set /a logfile_size+=!filesize!
            echo   📄 %%~nxF - !filesize! bytes
        )
    ) else (
        echo   ℹ️  未找到日誌檔案
    )
) else (
    echo   ⚠️  Errors 資料夾不存在
)

rem 統計總計
echo.
echo 📊 統計總計
echo ==========================================
echo 🗂️  錯誤報告檔案: !errorzip_count! 個，總大小: !errorzip_size! bytes
echo 📝 日誌檔案: !logfile_count! 個，總大小: !logfile_size! bytes
set /a total_size=!errorzip_size!+!logfile_size!
set /a total_count=!errorzip_count!+!logfile_count!
echo 📋 總計: !total_count! 個檔案，總大小: !total_size! bytes

rem 轉換為 KB/MB 顯示
if !total_size! gtr 1048576 (
    set /a size_mb=!total_size!/1048576
    echo    💾 約 !size_mb! MB
) else if !total_size! gtr 1024 (
    set /a size_kb=!total_size!/1024
    echo    💾 約 !size_kb! KB
)

echo.
echo 🗑️  檔案刪除確認
echo ==========================================
if !total_count! gtr 0 (
    echo 找到 !total_count! 個檔案，總大小 !total_size! bytes
    echo.
    set /p "confirm=是否要刪除這些檔案？(Y/N): "
    
    if /i "!confirm!"=="Y" (
        echo.
        echo 🔄 正在刪除檔案...
        set "deleted_count=0"
        
        rem 刪除錯誤報告檔案
        if !errorzip_count! gtr 0 (
            echo 📦 刪除錯誤報告檔案...
            for %%F in ("!gamefolder!GameTW_error_report_*.zip") do (
                echo   🗑️  刪除: %%~nxF
                del "%%F" >nul 2>&1
                if !errorlevel! equ 0 (
                    set /a deleted_count+=1
                    echo      ✅ 刪除成功
                ) else (
                    echo      ❌ 刪除失敗
                )
            )
        )
        
        rem 刪除日誌檔案
        if !logfile_count! gtr 0 (
            echo 📝 刪除日誌檔案...
            for %%F in ("!errorspath!log.*.txt") do (
                echo   🗑️  刪除: %%~nxF
                del "%%F" >nul 2>&1
                if !errorlevel! equ 0 (
                    set /a deleted_count+=1
                    echo      ✅ 刪除成功
                ) else (
                    echo      ❌ 刪除失敗
                )
            )
        )
        
        echo.
        echo 🎉 刪除完成！共刪除 !deleted_count! 個檔案
        
    ) else if /i "!confirm!"=="N" (
        echo ℹ️  已取消刪除操作
    ) else (
        echo ⚠️  無效的選擇，已取消刪除操作
    )
) else (
    echo ℹ️  沒有找到任何檔案，無需刪除
)

echo.
pause