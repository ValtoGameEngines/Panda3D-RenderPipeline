@echo off

REM Adjust the path to match your PyQt4 installation
REM SET PYQTPATH="E:\ProgrammeTemp\PyQT\Lib\site-packages\PyQt4"
SET PYQTPATH="C:\Projekte\PythonInc\PyQt4"

python "%PYQTPATH%\uic\pyuic.py" main_window.ui -o main_window_generated.py
"%PYQTPATH%\pyrcc4.exe" resources.qrc -o resources_rc.py

pause