# MSP Build Server Setup

1. Install Xcode

2. Install GitHub Desktop

3. Sign into GitHub on GitHub Desktop

4. Clone https://github.com/MacSourcePorts/MSPBuildSystem into `~/Documents/GitHub/MacSourcePorts/MSPBuildSystem`

5. Switch MSPBuildSystem to "buildserver" branch.

6. Copy over "signing_values.local" and the ".p8" file from an existing build server into the "common" subfolder of MSPBuildSystem. If you don't have this you'll need to recreate them using the help in the sign_and_notarize.sh file

7. Download and install these three certificates from Apple. Without them the developer certificate isn't trusted

    https://www.apple.com/certificateauthority/AppleWWDRCAG3.ce
    https://www.apple.com/certificateauthority/AppleWWDRCAG4.cer
    https://www.apple.com/certificateauthority/DeveloperIDG2CA.cer

8. Export the `"Developer ID Application: Your Name (XXXXXXXXX)"` certificate and private key pair from a working machine into a .p12 file and import it on the new build server. 
    If you don't have this you'll need to create one with your paid Apple Developer account.
    When done correctly you will see the key nested under the certificate in Keychain Access and labeled as valid. If it's labeled as invalid odds are it's the three root certificates from above at fault.

9. Install Appparency. Not required for building but very easy to use with regards to figuring out if the signing/notarizing worked.

    https://www.mothersruin.com/software/Apparency/

10. Install CMake. Open GUI once to get past Gatekeeper prompt

    https://cmake.org/download/#latest

11. Run command to get command line support

    `sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install`

12. Install create-dmg (latest release is fine)

	https://github.com/create-dmg/create-dmg

13. Install Python

	https://www.python.org/downloads/

14. Use pip3 (comes with Python) to install needed things

	`pip3 install meson ninja packaging lit SCons cogapp generate-iconset`

15. Install pkg-config

```
    https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
    
    CFLAGS="-Wno-int-conversion" CXXFLAGS="-Wno-int-conversion" LDFLAGS="-framework CoreFoundation -framework Carbon" ./configure --with-internal-glib
    make
    sudo make install
```

16. Install m4

```
	http://ftp.gnu.org/gnu/m4/m4-latest.tar.xz

	make
	sudo make install
```

17. Install autoconf

```
	http://ftpmirror.gnu.org/autoconf/autoconf-latest.tar.gz

	make
	sudo make install
```

18. Install automake

```
	https://ftp.gnu.org/gnu/automake/automake-1.18.1.tar.xz

	make
	sudo make install
```

19. Install gnu-sed (some things we do are beyond macOS's built-in sed)

```
	https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz

	./configure --disable-dependency-tracking --program-prefix=g
	make
	sudo make install
```
	
20. Install fmod SDK

	https://www.fmod.com/download
	`fmodstudioapi20308mac-installer.dmg`
	
	Drag the FMOD Programmers API folder to /Applications

21. Install Vulkan SDK

	https://sdk.lunarg.com/sdk/download/1.4.313.0/mac/vulkansdk-macos-1.4.313.0.zip
	
22. Install ISPC

	https://github.com/ispc/ispc/releases/tag/v1.28.1
	
23. Install git-lfs

	https://github.com/git-lfs/git-lfs/releases 

24. Install the libraries (script to come)

25. Install Buildbot

```
	pip3 install 'buildbot[bundle]'
	pip3 install 'buildbot[tls]'
```

26. Get secret files from another box (or just use the username and app-specific password from gmail or whatnot and put them in text files)

	`smtpUser` (username for sending email)

	`smtpPassword` (password for sending email)

    `githubToken` (gh token for daikatana repo)
	
    `daikatanaUrl` (url of daikatana repo)

	Put them in `~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/buildmaster/secrets/`
	
	(may need to make that directory)
	
	Then run chmod on them to make them "secret" as per buildbot's demands:
	
	`chmod 400 ~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/buildmaster/secrets/*`

28. Run the upgrade tool on the buildmaster database. Not sure why we need to do this but whatever

	`buildbot upgrade-master ~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/buildmaster`

29. Start the buildbot buildmaster

	in `~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/`

    `buildbot start buildmaster`

30. Start the buildbot worker

	in `~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/`

	`buildbot-worker start worker1`
	
31. Open up `~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/` and ensure `buildbotURL` is set to http://localhost:8010 (or whatever URL you want to hit, machine name if outside local machine)

22. Go to http://localhost:8010 in a browser (or whatever URL you want to hit, machine name if outside local machine)
