rtsp streamig
sudo nano /etc/sysctl.d/98-rpi.conf

net.core.rmem_default=1000000

net.core.rmem_max=1000000

  https://github.com/aler9/mediamtx/releases
64 bit armv8

  wget https://github.com/bluenviron/mediamtx/releases/download/v1.15.4/mediamtx_v1.15.4_linux_arm64.tar.gz
armv7 32 bit

   wget  https://github.com/bluenviron/mediamtx/releases/download/v1.15.4/mediamtx_v1.15.4_linux_armv7.tar.gz
unzip

     tar -xf mediamtx_v1.15.4_linux_arm64v8.tar.gz
move it to

  sudo mv mediamtx /usr/local/bin/

  sudo mv mediamtx.yml /usr/local/etc/
this create mediamtx.service

sudo tee /etc/systemd/system/mediamtx.service >/dev/null << EOF
[Unit]
Wants=network.target
[Service]
ExecStart=/usr/local/bin/mediamtx /usr/local/etc/mediamtx.yml
[Install]
WantedBy=multi-user.target
EOF
and reload

sudo systemctl daemon-reload
enable

sudo systemctl enable mediamtx
start

sudo systemctl start mediamtx
upgrade

sudo mediamtx --upgrade
######################################

RTSP STREAMING WITH AUDIO FOR RPI CAMERAS

    sudo nano  /boot/firmware/config.txt
put this in

    camera_auto_detect=1 #on bookworm default
    #gpu_mem=256   #disable or delete not needed
    #start_x=1  #disable or delete
##########################################

very important
     sudo nano /etc/sysctl.d/98-rpi.conf

     net.core.rmem_default=1000000

     net.core.rmem_max=1000000

      sudo reboot
###############################################

alsa or pulse or pipewire mikrofon name
     pactl list sources 
or

     pactl list | grep -A2 'Source #' | grep 'Name: '  ##bookworm

     pactl list sources short  ## trixie

     for alsa   arecord -L
     
may it works with aac free codec also

all this exaples running for 24h stable sync

test rpi3 z2w armhf 24h stable av sync
  
  
       nice -n -11  rpicam-vid  --low-latency 1  -b 1000000  --codec libav --libav-format flv  --brightness 0.1 --contrast 1.0 --sharpness   1.0  \
     --profile=high --hdr=off --libav-video-codec h264_v4l2m2m --autofocus-mode manual --autofocus-range normal \
     --autofocus-window  0.25,0.25,0.5,0.5 --denoise cdn_off --libav-video-codec-opts bf=0 --intra 0  \
     --level 4.2 --framerate 24  --width 1536 --height 864   --audio-device==alsa_input.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.mono-fallback  --av-sync=0 \
     --audio-codec libfdk_aac  --audio-channels 1 --libav-audio 1 --audio-source pulse --audio-samplerate=48000  --audio-bitrate=128kbps   \
     -t 0  -n --inline -o  - | ffmpeg -r 23.97602398  -hide_banner -fflags nobuffer+genpts  -flags low_delay  \
     -hwaccel drm -hwaccel_output_format drm_prime -i -  -metadata title='Devil' \
     -c:v copy \
     -c:a -acodec libfdk_aac -eld_sbr 1  -vbr 0  -b:a 64k  -copytb 1 -threads $(nproc) -fps_mode:v cfr\
     -f rtsp -rtsp_transport udp  rtsp://localhost:8554"/mystream   

test rpi4 24 h test sync stable
  
     nice -n -11  rpicam-vid  --low-latency 1  -b 1000000 --autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5   --denoise cdn_off \ 
  --libav-video-codec-opts bf=0 --intra 0 --codec libav --libav-format flv  --brightness 0.1 --contrast 1.0 --sharpness   1.0 \
  --profile=high --hdr=off --libav-video-codec h264_v4l2m2m   --level 4.2 --framerate 24  --width 1536 --height 864 \
  --audio-device=alsa_input.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00229929-00.analog-stereo --av-sync=0  \
  --audio-codec libfdk_aac  --audio-channels 2 --libav-audio 1 --audio-source pulse --audio-samplerate=48000  --audio-bitrate=128kbps  \
  -t 0  -n --inline -o  - | ffmpeg   -hide_banner -fflags nobuffer+genpts  -flags low_delay \
  -hwaccel drm -hwaccel_output_format drm_prime -i -  -metadata title='Lucy' -threads $(nproc) \
  -c:v copy \
  -c:a -acodec libfdk_aac -eld_sbr 1  -vbr 0  -b:a 64k  -copytb 1  -fps_mode:v cfr  -af "rubberband=tempo=0.9999"  \
  -f rtsp -rtsp_transport udp rtsp://localhost:8554"/mystream
  
test 2 rpi4 -vcodec h264_v4l2m2m -acodec libfdk_aac !!! 10h test sync !!! --av-sync=10000 = 0,1 sec in my case ! stable

       nice -n -11  rpicam-vid  --low-latency 1  -b 1500000 --autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5   --denoise cdn_off  \
     --libav-video-codec-opts bf=0 --intra 0 --codec libav --libav-format flv  --brightness 0.1 --contrast 1.0 --sharpness   1.0 \
     --profile=high --hdr=off --libav-video-codec h264_v4l2m2m   --level 4.2 --framerate 24  --width 1536 --height 864 \
     --audio-device=alsa_input.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00229929-00.analog-stereo --av-sync=10000  \
     --audio-codec libfdk_aac  --audio-channels 2 --libav-audio 1 --audio-source pulse --audio-samplerate=48000  --audio-bitrate=128kbps  \
     -t 0  -n --inline -o  - | ffmpeg -ss 00:00:03   -hide_banner -fflags nobuffer+genpts  -flags low_delay \
     -hwaccel drm -hwaccel_output_format drm_prime -i -  -metadata title='Lucy' \
     -c:v h264_v4l2m2m  -b:v 1500k -num_output_buffers 32 -num_capture_buffers 16 -filter:v  fps=fps=source_fps:round=near \
     -c:a libfdk_aac -eld_sbr 1  -vbr 0  -b:a 64k  -copytb 1 -threads $(nproc) -fps_mode:v cfr    \
     -f rtsp -rtsp_transport udp rtsp://localhost:8554"/mystream
 
test -filter:v fps=fps=film:round=near:start_time=0 -fps_mode:v cfr
optios for libfdk
                    ffmpeg -h encoder=libfdk_aac
                    
                working
                
  -c:a libfdk_aac -eld_sbr 1
 -c:a libfdk_aac -eld_v2 1   
 -c:a  libfdk_aac -profile:a aac_he -b:a 32k
 -c:a  libfdk_aac -profile:a aac_he_v2 -b:a 32k
