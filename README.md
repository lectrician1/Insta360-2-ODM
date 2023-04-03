# Insta360-2-ODM

This is a PowerShell script and guide to convert a GPS-tracked video recorded on a Insta360 camera like the ONE X2 into a GPS-tagged image sequence that OpenDroneMap can injest to generate photogrammetry models. 

Having a GPS-tagged image sequence decreases the processing time of the photogrammetry and increases the quality.

This script is useful for those who want to take advantage of Insta360's great cameras and generate 3D models of outdoor environments without a drone or in places where a drone is not allowed to fly.

This script can also be used for any type of video to convert a video with GPS data to an image sequence with GPS data. Just comment-out some of the lines of the script.

## Requirements
* PowerShell (if you want a bash script instead, if someone could translate this script and submit a PR, I'd be happy to accept it)
* ExifTool
* ffmpeg
* Insta360 Studio
* Insta360 mobile app

## Directions
1. Capture a GPS-tagged video with your Insta360 camera at the highest resolution and lowest framerate possible. For a ONE X2, this is 5.7K at 24fps. To capture GPS with your video, connect your camera to the Insta360 app on your phone and enable GPS by going to the 3 dots at the top right. Then click record on your phone. Your phone is the source of the GPS data, not the camera, so make sure both are connected to each other while filming. To reduce the amount of artifacts in the photogrammetry produced by ODM, record where there are few people and where the camera is above you on a bike helmet or invisible selfie stick.
2. Copy both sphere-halfs of the generated video to your computer and open them in Insta360 studio.
3. Export the video as a framed or 360 video. Use the default export settings (bitrate, encoding) provided by Insta360 Studio as they will produce the best results with the least compute time. Enable the remove grain with AI option.
4. Clone and open this reporitory in PowerShell.
5. Run the script with the paths of the original half-sphere video with `_00_` in its name (that's the one that contains the GPS data. The `_10_` video does not) and the exported video, along withe the framerate of the exported image sequence you would like to be produced.\
Command: `.\create_frames.ps1 <path to _00_ .insv> <path to exported video> <fps>`\
Example: `.\create_frames.ps1 "C:\Users\jayan\Pictures\Insta360 OneX2\VID_20230402_152431_00_005.insv" "C:\Users\jayan\Pictures\VID_20230402_152431_00_005.mp4" 3`\
On a bike I found 3 fps to generate the best results.
6. The frames will be outputted to a folder named FRAMES in the repository folder. Check the frames to make sure that they have the correct GPS data by clicking the file info button in the pictures viewer app on Windows or Mac.
7. Create a new task in WebODM and upload the frames.\
If your video includes parts of the sky, make sure to check sky-removal as a processing option.\
If you exported a 360 video, select equirectangular as the camera lense type. DO NOT crop an equirectangular video and use it as an input for ODM. Your model will turn out bent.
8. Start processing!

## Notes
* When an fps of more than 1 is used, sequential frames in groups of X (the FPS value) will share the same GPS point. This is because the output GPX file only has GPS points that have an accuracy of every second and it also only creates 10 trackpoints per second. I didn't want to bother syncing up the subtime frames with the trackpoints. It also doesn't really matter because ODM when processing the images is actually able to determine their exact positions. When you open the model viwer after processing and click "show cameras", you'll see that each frame is spaced equally apart and ODM was able to find each of their unique positions.
* Whenever geotagging 

## Sources
* https://www.trekview.org/blog/2021/turn-360-video-into-timelapse-images-part-2/ helped me the most.
* ExifTool forum