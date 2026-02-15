##     RTSP STREAMING WITH AUDIO FOR RPI CAMERAS


  #   first install mediamtx 

  https://github.com/aler9/mediamtx/releases
  
64 bit armv8 rpi4 + 5

       wget https://github.com/bluenviron/mediamtx/releases/download/v1.15.4/mediamtx_v1.15.4_linux_arm64.tar.gz
       
armv7 32 bit rpi 3 zero2w

        wget  https://github.com/bluenviron/mediamtx/releases/download/v1.15.4/mediamtx_v1.15.4_linux_armv7.tar.gz
# unzip

          tar -xf mediamtx_v1.15.4_linux_arm64v8.tar.gz
          
# move it to

      sudo mv mediamtx /usr/local/bin/

      sudo mv mediamtx.yml /usr/local/etc/
      
# this create mediamtx.service

     sudo tee /etc/systemd/system/mediamtx.service >/dev/null << EOF
     [Unit]
     Wants=network.target
     [Service]
     ExecStart=/usr/local/bin/mediamtx /usr/local/etc/mediamtx.yml
     [Install]
     WantedBy=multi-user.target
     EOF
     
# and reload

        sudo systemctl daemon-reload
   
# enable

        sudo systemctl enable mediamtx

# start

        sudo systemctl start mediamtx
    
# upgrade

        sudo mediamtx --upgrade

    
######################################

RTSP STREAMING WITH AUDIO FOR RPI CAMERAS

       sudo nano  /boot/firmware/config.txt
    
# put this in

    camera_auto_detect=1 #on bookworm default
    #gpu_mem=256   #disable or delete not needed
    #start_x=1  #disable or delete
##########################################

#  very important

        sudo nano /etc/sysctl.d/98-rpi.conf

        net.core.rmem_default=1000000

        net.core.rmem_max=1000000

         sudo reboot
         
###############################################

# alsa or pulse or pipewire mikrofon name

     pactl list sources short
     
# or

     pactl list | grep -A2 'Source #' | grep 'Name: '  ##bookworm

     pactl list sources short  ## trixie

     for alsa   arecord -L
     

    sudo nano /boot/firmware/config.txt

       vc4.tv_norm=PAL   #which is 25 fps


       may you want to set to NTSC PA60 for framerate=3


      nano .config/mpv/mpv.conf

      [cam]

      #container-fps-override=25
      #no-correct-pts
      #untimed
      osc=no
      opengl-swapinterval=0
      profile=fast
      interpolation=no
      #rtsp-transport=tcp
      framedrop=decoder+vo
      no-resume-playback
      video-latency-hacks=yes
      pulse-latency-hacks=yes
      demuxer-lavf-o-add=fflags=+nobuffer
      stream-buffer-size=4k
      vd-lavc-threads=1
      fullscreen=yes

#######################################################################################################################################
## best for pi 4 pi 5 may all rpi

```bash
nice -n -11 stdbuf -oL -eL rpicam-vid --denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile baseline --intra 10 -b 1000000 -n -o - | \
nice -n -11 ffmpeg -y -fflags +genpts+igndts+nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-thread_queue_size 32 -f h264 -r 25 -i - \
-thread_queue_size 128 -f pulse -fragment_size 512 -isync 0 -i default \
-c:v copy \
-c:a libfdk_aac -profile:a aac_low -b:a 64k -ac 1 -vbr 0 \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport tcp -tcp_nodelay 1 -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316 -rtpflags latm \
rtsp://"spooky:password"@"localhost:8554"/mystream
```         

         

         mpv --profile=cam  rtsp://ip-rpi:8554/mystream
        

for all rpi

# for all

```bash
PULSE_LATENCY_MSEC=60 nice -n -11 stdbuf -oL -eL rpicam-vid \
--denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal \
--autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile baseline --intra 25 -b 1500000 -n -o - | \
PULSE_LATENCY_MSEC=60 nice -n -11 ffmpeg  -y \
-fflags +genpts+igndts+nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-thread_queue_size 128 -f h264 -r 25 -i - \
-thread_queue_size 256 -f pulse -fragment_size 512 -isync 0 -i default \
-c:v copy \
-c:a libfdk_aac -profile:a aac_low -b:a 64k -ac 1 -vbr 0 \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport tcp -tcp_nodelay 1 -muxdelay 0 \
-flags +low_delay -avioflags direct -pkt_size 1316 -rtpflags latm \
rtsp://"user:pwd"@"localhost:8554"/mystream
```
# realtime you must set other things like group and cmdline.txt usw

```bash
stdbuf -oL -eL chrt -f 90  rpicam-vid --flush --low-latency --verbose 0  \
--denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal \
--autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile high --level 4.2   --intra 25 -b 1500000 -n -o - 2>/dev/null  | \
PULSE_LATENCY_MSEC=10 chrt -f 90 taskset -c 3   ffmpeg  -y -loglevel warning  -hwaccel drm -hwaccel_device /dev/dri/renderD128  \
-fflags +genpts+igndts+nobuffer+flush_packets  \
-use_wallclock_as_timestamps 1  \
-thread_queue_size 16 -f h264 -r 25 -i - \
-fragment_size 480 -thread_queue_size 16 -f pulse   -isync 0 -i default \
-c:v copy -metadata title='lucy'  \
-c:a libopus -application lowdelay -ac 1  -vbr off -b:a 64k -frame_duration 5  -compression_level 0  \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport tcp -rtsp_flags filter_src -tcp_nodelay 1  -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316  \
rtsp://"user:pwd"@"localhost:8557"/mystream > /dev/null 2>&1
```




```bash
PULSE_LATENCY_MSEC=60 nice -n -11 stdbuf -oL -eL rpicam-vid --denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile baseline --intra 25 -b 1500000 -n -o - | \
nice -n -11 ffmpeg -y -fflags +genpts+igndts+nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-thread_queue_size 32 -f h264 -r 25 -i - \
-thread_queue_size 128 -f pulse -fragment_size 512 -isync 0 -i default \
-c:v copy -metadata title='lucy' \
-c:a libfdk_aac -b:a 64k -ac 1 -vbr 0  -afterburner 1   \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport udp -rtpflags latm   -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316 \
rtsp://"user:pwd"@"localhost:8557"/mystream
```

rpi 3 + z2w + all rpi`s with audio HAT ! min cpu ! min mem !

```bash
PULSE_LATENCY_MSEC=60 stdbuf -o0 -e0  chrt -f 90 taskset -c 0,1  rpicam-vid --flush   -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=baseline  --hdr=off --level 4.1 --framerate 25  --width 1280 --height 720   --av-sync=0 \
--autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
--audio-codec libopus --audio-samplerate 48000 --shutter 20000 --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json  \
--audio-channels 2 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 90 taskset -c 3  ffmpeg   -loglevel warning  -hide_banner -fflags nobuffer+genpts+flush_packets \
-hwaccel drm -hwaccel_output_format drm_prime -thread_queue_size 2048  -f mpegts  -i -  -metadata title='lucy' -c copy -copyts \
-fps_mode passthrough   -flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-rtsp_flags filter_src -tcp_nodelay 1  -rtsp_transport tcp -pkt_size 1316  rtsp://"user:pwd"@"localhost:8554"/mystream
```
