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


       may you want to set to NTSC PA60 for framerate=30

##  rpi 3  and pi z2w  trixie audio default usb micro u-green

         nice -n -11 rpicam-vid \
  -b 1000000 \
  --denoise cdn_off \
  --awb indoor \
  --codec libav \
  --libav-format mpegts \
  --profile main \
  --hdr off \
  --level 4.1 \
  --framerate 25 \
  --width 1280 \
  --height 720 \
  --autofocus-mode manual \
  --autofocus-range normal \
  --autofocus-window 0.25,0.25,0.5,0.5 \
  --audio-codec libfdk_aac \
  --audio-channels 1 \
  --libav-audio 1 \
  --audio-source pulse \
  --audio-samplerate 48000 \
  --inline \
  -t 0 \
  -n \
  -o - | \
ffmpeg -f mpegts -fflags +genpts+nobuffer+flush_packets \
  -i - \
  -c copy \
  -metadata title='lucy' \
  -f rtsp \
  -rtsp_transport tcp -muxdelay 0 -rtpflags latm -tcp_nodelay 1  \
  -flags low_delay -avioflags direct \
  rtsp://localhost:8554/mystream


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


         mpv --profile=cam rtsp://ip:8554

###########################    

## pi4 

       nice  -n -11 rpicam-vid \
        -b 1000000 \
        --denoise cdn_off \
        --awb indoor \
        --codec libav --libav-format mpegts --profile baseline  --hdr off --level 4.1 \
        --framerate 25 --width 1280 --height 720 \
        --autofocus-mode manual --autofocus-range normal  --autofocus-window 0.25,0.25,0.5,0.5 \
        --audio-codec libfdk_aac \
        --audio-channels 1 \
         --libav-audio 1 \
         --audio-source pulse \
         --audio-samplerate 48000 \
          --inline \
          -t 0 \
          -n \
          -o - | \
         ffmpeg -fflags +genpts+nobuffer+flush_packets \
         -f mpegts \
         -i - \
         -c:v copy \
         -c:a libfdk_aac \
         -af "asetrate=48000*0.9999,aresample=48000:async=1:min_hard_comp=0.1" \
         -metadata title='lucy' \
         -f rtsp \
         -rtsp_transport tcp \
        -muxdelay 0 \
        -rtpflags latm \
        -flags low_delay -avioflags direct -tcp_nodelay 1 \
         rtsp://localhost:8554/mystream


      




#######################################################################################################################################
## best for pi 4


         nice -n -11 rpicam-vid -t 0 --denoise cdn_off  --profile baseline  --hdr off --level 4.1 \
         --awb indoor  --width 1280 --height 720 --framerate 25 --codec h264 --inline --flush -n -o - | ffmpeg -y  -f h264 -fflags nobuffer+flush_packets -r 25 -i -  -f pulse -i default \
         -c:v h264_v4l2m2m -b:v 1500k -g 50   -c:a libfdk_aac -b:a 128k -ac 1  -af "aresample=async=1:first_pts=0"   -map 0:v:0 -map 1:a:0   -fps_mode cfr   -f rtsp -rtsp_transport tcp  \
         -muxdelay 0.1 -tcp_nodelay 1   -flags low_delay   -avioflags direct   rtsp://localhost:8554/mystream


         

         mpv --profile=cam  rtsp://ip-rpi:8554/mystream
        


          
