# input files
LUA_FLES:= conf.lua main.lua $(wildcard normalpicross/*.lua)
ASSORTED_FILES:= README.md

# main actions
.PHONY: all
all:

# clean actions
.PHONY: clean allclean mrproper
clean:
	rm -rf build
allclean: clean
	rm -rf tools
mrproper: clean
	rm -rf out

# build target: raw love
.PHONY: love
all: love
love: out/normalpicross.love

.PHONY: run-love
run-love: out/normalpicross.love
	love out/normalpicross.love

out/normalpicross.love: $(LUA_FLES)
	mkdir -p out
	rm -f out/normalpicross.love
	zip out/normalpicross.love -r conf.lua main.lua normalpicross

# build target: windows
.PHONY: win win-zip
all: win win-zip
win: out/win/normalpicross.exe
win-zip: out/normalpicross-win64.zip

out/win/normalpicross.exe: tools/love-11.5-win64.zip out/normalpicross.love $(ASSORTED_FILES)
	rm -rf tools/love-11.5-win64
	rm -rf out/win
	mkdir -p out/win
	(cd tools && unzip love-11.5-win64.zip)
	cp tools/love-11.5-win64/*.dll tools/love-11.5-win64/license.txt out/win
	cp $(ASSORTED_FILES) out/win
	cat tools/love-11.5-win64/love.exe out/normalpicross.love > out/win/normalpicross.exe

out/normalpicross-win64.zip: out/win/normalpicross.exe
	zip -r out/normalpicross-win64.zip out/win

# build target: linux
.PHONY: linux linux-tgz
all: linux linux-tgz
linux: out/linux/normalpicross
linux-tgz: out/normalpicross-linux-x86_64.tar.gz

.PHONY: run-linux
run-linux: out/linux/normalpicross
	out/linux/normalpicross

out/linux/normalpicross: tools/love-11.5-x68_64.AppImage out/normalpicross.love $(ASSORTED_FILES)
	rm -rf out/linux
	mkdir -p out/linux
	(cd out/linux && ../../tools/love-11.5-x68_64.AppImage --appimage-extract)
	mv out/linux/squashfs-root/* out/linux/squashfs-root/.DirIcon out/linux && rmdir out/linux/squashfs-root
	cat out/linux/bin/love out/normalpicross.love > out/linux/bin/normalpicross
	chmod +x out/linux/bin/normalpicross
	rm out/linux/bin/love
	cp $(ASSORTED_FILES) out/linux
	ln -s normalpicross out/linux/bin/love
	ln -s bin/normalpicross out/linux

out/normalpicross-linux-x86_64.tar.gz: out/linux/normalpicross
	(cd out && tar czf normalpicross-linux-x86_64.tar.gz linux)

# build target: appimage
.PHONY: appimage appimage-tgz
all: appimage appimage-tgz
appimage: out/appimage/normalpicross.AppImage
appimage-tgz: out/normalpicross-linux-x86_64-appimage.tar.gz

run-appimage: out/appimage/normalpicross.AppImage
	out/appimage/normalpicross.AppImage

out/appimage/normalpicross.AppImage: out/linux/normalpicross tools/appimagetool-x68_6.AppImage $(ASSORTED_FILES)
	rm -rf out/appimage
	mkdir -p out/appimage
	cp $(ASSORTED_FILES) out/appimage
	tools/appimagetool-x68_6.AppImage out/linux out/appimage/normalpicross.AppImage

out/normalpicross-linux-x86_64-appimage.tar.gz: out/appimage/normalpicross.AppImage
	(cd out && tar czf normalpicross-linux-x86_64-appimage.tar.gz appimage)

# build target: web
.PHONY: web web-compat
web: out/web/index.html
web-compat: out/web-compat/index.html

run-web: out/web-compat/index.html
	npx serve out/web-compat

out/web/index.html: out/normalpicross.love tools/love.js/node_modules/.bin/love.js
	mkdir -p out
	tools/love.js/node_modules/.bin/love.js -t "Normal Picross" out/normalpicross.love out/web
out/web-compat/index.html: out/normalpicross.love tools/love.js/node_modules/.bin/love.js
	mkdir -p out
	tools/love.js/node_modules/.bin/love.js -c -t "Normal Picross" out/normalpicross.love out/web-compat

# intermediate steps
tools/love-11.5-win64.zip:
	mkdir -p tools
	curl -Lo tools/love-11.5-win64.zip 'https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip'

tools/love-11.5-x68_64.AppImage:
	mkdir -p tools && rm -f tools/love-11.5-x68_64.AppImage
	curl -Lo tools/love-11.5-x68_64.AppImage- 'https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage'
	install -m 755 tools/love-11.5-x68_64.AppImage- tools/love-11.5-x68_64.AppImage
	rm -f tools/love-11.5-x68_64.AppImage-

tools/appimagetool-x68_6.AppImage:
	mkdir -p tools && rm -f tools/appimagetool-x68_6.AppImage
	curl -Lo tools/appimagetool-x68_6.AppImage- https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
	install -m 755 tools/appimagetool-x68_6.AppImage- tools/appimagetool-x68_6.AppImage
	rm -f tools/appimagetool-x68_6.AppImage-

tools/love.js/node_modules/.bin/love.js:
	mkdir -p tools && rm -rf tools/love.js
	git clone https://github.com/Davidobot/love.js.git tools/love.js
	(cd tools/love.js && npm i)
	ln -s ../../index.js tools/love.js/node_modules/.bin/love.js
