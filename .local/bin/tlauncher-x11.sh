#!/bin/bash
export DISPLAY=:1
export GDK_BACKEND=x11
export SDL_VIDEODRIVER=x11
export GLFW_PLATFORM=x11
export WLR_BACKEND=x11
export XDG_SESSION_TYPE=x11
xhost +local:
/usr/games/tlauncher/lib/jvm/jre/bin/java -Dfile.encoding=UTF8 -jar /usr/games/tlauncher/starter-core.jar
