I found out that if used correctly, with OpenMVS, COLMAP did not require a Cuda GPU for 3D reconstruction and provided better results.

Below are very rough instructions.

====Extract your footage from the video====

First by cutting the footage ...

	ffmpeg -ss 00:07:00 -i video.mp4 -c copy -t 00:01:08 shot-1.mp4

(where ss is the start time, t is the duration of _the clip you want to cut_)

... and then by extracting the images:

	ffmpeg -i shot1.mp4 -r 25 images/imageA-%3d.jpeg

====Run installation====

cd <thisdir>

./install-colmap.sh
./install-openmvs.sh

====Create a swap====

	sudo fallocate -l 150G /.swapfile
	sudo chmod 600 /.swapfile
	sudo mkswap /.swapfile
	sudo swapon /.swapfile

This swapfile will not survive reboots, which is OK for running a few reconstructions. However, the swap file will remain, taking up space on the system.
So once you have run all your reconstructions, you can delete the swap and swapfile by:

	sudo swapoff /.swapfile
	sudo rm /.swapfile

====Do some other stuff====

take a look at run.sh, and make sure you have your directory tree set up correctly with images in the right places etc.

====Run it====

cd <thisdir>
./run.sh

====Wait a long time====

(Could be days...)

====Results====

I got better results from COLMAP + OpenMVS than I did OpenSFM + OpenMVS. You will see that in run.sh, I have set the SiftExtraction.max_image_size to 1024.

This value theoretically matches the downscaling I used when I ran https://github.com/publicsite/OpenSfM_openMVS_pipeline_testPilot

A few notes ...

1) I have modified the OpenMVS patches to work on a more recent version of OpenMVS.

2) To explain the patches in openMVS ... they remove some stuff that has a non-free licence.

3) The code I provide here might not run 'out of the box' and may need tweaking.

4) Patches for openMVS are under the openMVS licence.

5) This stuff here is Copyright (c) J05HYYY , where that copyright can apply.

====To donate====

https://www.paypal.com/donate/?hosted_button_id=SZABYRV48SAXW