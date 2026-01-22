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

         nice -n -11  rpicam-vid    -b 1000000    --denoise cdn_off   --codec libav --libav-format mpegts  --low-latency 1   --profile=main --hdr=off \
        --level 4.1 --framerate 25  --width 1280 --height 720   --av-sync=0 --autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
        --audio-codec libfdk_aac    --audio-channels 1 --libav-audio 1 --audio-source pulse  --awb indoor \
         -t 0    -n  -o  - | ffmpeg  -hide_banner -fflags genpts+nobuffer -flags low_delay  \
        -hwaccel drm -hwaccel_output_format drm_prime -re  -i -  -metadata title='devil' -c  copy  -mpegts_copyts 1  -map 0:0 -map 0:1   \
       -f rtsp -buffer_size 4k  -muxdelay 0.1  -rtpflags latm  -rtsp_transport udp    rtsp://localhost:8554/mystream


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


on pi 3 container override untimed no-correct-pts not nessesary

###########################  


# pi 4 4h stable! micro usb ugreen and may all usb devices

      nice -n -11  rpicam-vid  -b 1000000  --denoise cdn_off --codec libav --libav-format mpegts --profile=main \
      --hdr=off --level 4.1 --framerate 25  --width 1280 --height 720 \
     --av-sync=20000  --autofocus-mode manual --autofocus-range normal   --autofocus-window  0.25,0.25,0.5,0.5  \
     --audio-codec libfdk_aac   --audio-channels 1 --libav-audio 1 \
     --audio-source pulse   --low-latency 1 -t 0 -n -o  - | ffmpeg  -hide_banner -fflags genpts+nobuffer -flags low_delay  \
     -hwaccel drm -hwaccel_output_format drm_prime -re  -rtbufsize 2M   -i -  -metadata title='lucy'  -c copy -f rtsp  -buffer_size 4k -rtpflags latm \
     -muxdelay 0.1   -rtsp_transport udp  rtsp://localhost:8554/mystream  

      nano .config/mpv/mpv.conf

      

      [cam]

      container-fps-override=25
      no-correct-pts
      untimed
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


#######################################################################################################################################


         

         mpv --profile=cam  rtsp://ip-rpi:8554/mystream
        


          
