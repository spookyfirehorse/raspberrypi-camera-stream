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
     
# may it works with aac free codec also --audio-codec aac

# rpi 3 zero2w

    nice -n -11  rpicam-vid  --low-latency 1  -b 1000000 --denoise cdn_off --codec libav --libav-format flv --profile=high --hdr=off \
    --awb indoor --level 4.2 --framerate 30  --width 1296 --height 972 \
    --audio-codec libfdk_aac --audio-bitrate=96kbps  --audio-channels 1 --libav-audio 1 --audio-source pulse  --intra 0 \
    -t 0 --flush 0   -n  -o  - | ffmpeg  -hide_banner -fflags genpts \
    -hwaccel drm -hwaccel_output_format drm_prime -i -  -metadata title='MOON' -vcodec copy -copyts -acodec libfdk_aac  -b:a 96k \
    -max_muxing_queue_size 9999 -bufsize 2M  -af "rubberband=tempo=0.999" \
   -f rtsp -rtsp_transport udp rtsp://localhost:8557"/mystream

# rpi4
   
      nice -n -11  rpicam-vid  --brightness 0.1 --contrast 1.0 --sharpness   1.0  --hdr=off --denoise cdn_off   \
      --width 1536 --height 864 --autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
      --low-latency 1   -b 1000000  --codec libav --libav-format flv   --profile=main --level 4.1 --intra 0  --av-sync=0 \
      --audio-codec libfdk_aac --audio-bitrate=96kbps  --audio-channels 2 --libav-audio 1 --audio-source pulse \
      -t 0  -n  -o - |  ffmpeg   -hide_banner -fflags genpts -hwaccel drm -hwaccel_output_format drm_prime  -i -  -metadata title='lucy' \
      -c:v  h264_v4l2m2m   -b:v 1M  -maxrate 1M -minrate 1M  -bufsize 2000k -fps_mode:v cfr -filter:v  fps=fps=ntsc:round=zero \
      -threads $(nproc)  -c:a libfdk_aac -profile:a aac_he  -b:a 96k -vbr 0 -max_muxing_queue_size 9999 -flush_packets 0 \
      -f rtsp -rtsp_transport udp  rtsp://localhost:8557"/mystream


# rpi 4 less cpu les mem

          -af "rubberband=tempo=0.9999" yes one 9 more like the rpi3 



        nice -n -11  rpicam-vid   --low-latency   -b 1000000    --denoise cdn_off   --codec libav --libav-format flv     --profile=main --hdr=off  \
        --level 4.1 --framerate 24  --width 1536 --height 864   --av-sync=0 --autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
        --audio-codec libfdk_aac --audio-bitrate=96kbps  --audio-channels 2 --libav-audio 1 --audio-source pulse  --intra 0    \
        -t 0 --flush 0   -n   -o  - | ffmpeg  -hide_banner -fflags genpts   \
        -hwaccel drm -hwaccel_output_format drm_prime -i -  -metadata title='lucy'  -vcodec copy -copyts -acodec libfdk_aac -b:a 96k \
        -max_muxing_queue_size 9999 -bufsize 2M  -af "rubberband=tempo=0.9999"   \
        -f rtsp -rtsp_transport udp  rtsp://localhost:8554"/mystream


        -t 0 --flush 0   -n --inline -o  - | ffmpeg  -hide_banner  -fflags nobuffer+discardcorrupt+genpts  -flags low_delay  \
       -hwaccel drm -hwaccel_output_format drm_prime -i -  -metadata title='Devil'  -codec copy -copyts  -map 0:0 -map 0:1 -f rtsp -rtsp_transport udp 
