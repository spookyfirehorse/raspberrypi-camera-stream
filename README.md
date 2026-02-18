##     RTSP STREAMING WITH AUDIO FOR RPI CAMERAS

# pi 5 -c 7 realtime kernel 6.12 example

```bash
git clone https://github.com/spookyfirehorse/ffmpeg-and-mpv-for-rpi4.git
cd spookyfirehorse/ffmpeg-and-mpv-for-rpi4/build_kernel
chmod +x build_kernel
```

```bash
sudo ./build-kernel -b default --branch rpi-6.12.y -c 7 -j 6 -u -d  
```

#  pi 4  -c 6  realtime kernel 6.18 example 

```bash
sudo ./build-kernel -b default --branch rpi-6.18.y -c 6 -j 6 -u -d
```
```bash
sudo nano /etc/group
```
```bash
sudo:x:27:spook
audio:x:29:spook
render:x:992:vnc,spook
_ssh:x:101:spook
spi:x:989:spook
i2c:x:987:spook
gpio:x:986:spook
pipewire:x:105:spook
pulse:x:106:spook
rtkit:x:117:spook
```


# this is for usb microfon and audio hat

```bash
sudo apt install pipewire-alsa -y
sudo apt purge pulseaudio* -y
sudo rm -r /etc/pulse
```


```bash
nano .asoundrc
```
```bash
ctl.!default {
    type pipewire
}

pcm.!default {
    type plug
    slave {
        pcm "pwire"
        format S16_LE
        rate 48000
    }
}

pcm.pwire {
    type pipewire
    mmap_emulation 1
}
```



```bash
sudo nano /boot/firmware/cmdline.txt 
```
```bash
console=serial0,115200 console=tty1 root=PARTUUID=37b5fcd6-02 rootfstype=ext4 fsck.repair=yes rootwait  net.ifnames=0 isolcpus=2,3 nohz_full=2,3 rcu_nocbs=2,3
```


# isoliert 3 cpu for rpicam-vid isolcpus=3



```bash
sudo apt install pipewire-alsa rtkit
```


```bash
sudo rm -r /etc/pipewire
sudo mkdir /etc/pipewire
sudo mkdir /etc/pipewire/pipewire.conf.d/
sudo nano /etc/pipewire/pipewire.conf.d/10-low-latency.conf
```

```bash
context.properties = {
    default.clock.rate          = 48000
    default.clock.quantum       = 1024
    default.clock.min-quantum   = 1024
    default.clock.max-quantum   = 1024
}
```
```bash
sudo nano    /etc/pipewire/pipewire-pulse.conf.d/99-rpicam-s16.conf 
```

```bash
pulse.rules = [
    {
        matches = [ { application.process.binary = "rpicam-vid" } ]
        actions = {
            update-props = {
                # Dies zwingt die Schnittstelle auf 16-Bit
                pulse.default.format = "S16LE"
                pulse.fix.format = "S16LE"
                audio.format = "S16LE"

                # Latenz-Fix für S16LE (1024 Samples)
                pulse.attr.fragsize = "4096"
                node.force-quantum = 1024
            }
        }
    }
]
```
```bash
sudo mkdir -p /etc/wireplumber/wireplumber.conf.d/
```

```bash
 sudo nano  /etc/wireplumber/wireplumber.conf.d/50-alsa-s16le.conf
```
```bash
monitor.alsa.rules = [
  {
    matches = [
      {
        # Matcht alle Ausgänge
        node.name = "~alsa_output.*"
      },
      { 
        # Matcht alle Eingänge
        node.name = "~alsa_input.*"
      }
    ]
    actions = {
      update-props = {
        # Erzwingt S16LE für beide oben genannten Gruppen
        audio.format = "S16LE"
      }
    }
  }
]
```

# dont set it lower exept realtime kernel


```bash
sudo nano /etc/enviroment
```

```bash
PIPEWIRE_LATENCY=1024/48000
```
```bash
sudo nano /etc/security/limits.d/99-realtime.conf 
```

```bash
spook  -  rtprio     99
spook  -  memlock    unlimited
spook  -  nice      -20
#*  -  rtprio     99
#*  -  memlock    unlimited
```


```bash
wpctl status
```
```bash
pw-top
```




  #   install mediamtx 

  https://github.com/aler9/mediamtx/releases
  
64 bit armv8 rpi4 + 5

       wget https://github.com/bluenviron/mediamtx/releases/download/v1.15.4/mediamtx_v1.15.4_linux_arm64.tar.gz
       
armv7 32 bit rpi 3 zero2w

        wget  https://github.com/bluenviron/mediamtx/releases/download/v1.15.4/mediamtx_v1.15.4_linux_armv7.tar.gz
# unzip

          tar -xf mediamtx_v1.15.4_linux_arm64v8.tar.gz
          
# move it to

      
      
```bash
sudo mv mediamtx.yml /usr/local/etc/
sudo mv mediamtx /usr/local/bin/
```

# this create mediamtx.service

```bash
sudo tee /etc/systemd/system/mediamtx.service >/dev/null << EOF
[Unit]
Wants=network.target
[Service]
ExecStart=/usr/local/bin/mediamtx /usr/local/etc/mediamtx.yml
[Install]
WantedBy=multi-user.target
EOF
```
     
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

```bash
sudo nano  /boot/firmware/config.txt
```
    
# put this in

```bash
camera_auto_detect=1 #on bookworm default
#gpu_mem=256   #disable or delete not needed
#start_x=1  #disable or delete
vc4.tv_norm=PAL   #which is 25 fps
```
##########################################

#  very important

```bash
sudo nano /etc/sysctl.d/98-rpi.conf
```

```bash
net.core.rmem_default=1000000
net.core.rmem_max=1000000
```
   
         sudo reboot
         
###############################################




```bash
nano .config/mpv/mpv.conf
```

```bash
[cam]
container-fps-override=25
no-correct-pts
untimed
#hwdec=auto-copy
no-resume-playback
osc=no
opengl-swapinterval=0
profile=fast
vo-vaapi-scaling=fast
interpolation=no
#rtsp-transport=udp
framedrop=decoder+vo
#video-sync=display-resample
#ao=alsa
#audio-samplerate=44100
#audio-format=s16
volume=100
video-latency-hacks=yes
pulse-latency-hacks=yes
demuxer-lavf-o-add=fflags=+nobuffer+genpts
stream-buffer-size=4k
vd-lavc-threads=1
fullscreen=yes
#ovc=matroska
demuxer=lavf
demuxer-lavf-probesize=32
demuxer-lavf-analyzeduration=0
#demuxer-lavf-buffersize=300
#gpu-dumb-mode=yes
ytdl=no
hr-seek=no
#frames=0
demuxer-readahead-secs=0
cache=no
#demuxer-lavf-o=rtsp_transport=udp
dither=no
scale=bilinear
demuxer-lavf-o=rtsp_transport=tcp
framedrop=no
#speed=1.0001
stream-buffer-size=4k
network-timeout=100
#demuxer-lavf-format=mpegts
```

####################################################################################################################################################



###############################################################################################################
# low cpu very quick camera imx708

```bash
stdbuf -o0 -e0  chrt -f 50 taskset -c 3  rpicam-vid --flush   -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=main  --hdr=off --level 4.0 --framerate 25  --width 1536 --height 864   --av-sync=0 \
--autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
--audio-codec libopus --audio-samplerate 48000 --shutter 20000 --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json  \
--audio-channels 2 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 45 taskset -c 2  ffmpeg   -loglevel warning  -hide_banner \ 
-fflags nobuffer+genpts+flush_packets -isync 0 -copyts -start_at_zero  \
-hwaccel drm -hwaccel_output_format drm_prime  -fpsprobesize 0  -f mpegts  -i -  -metadata title='lucy' -c copy -copyts -start_at_zero  \
-flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-rtsp_flags filter_src   -tcp_nodelay 1  -rtsp_transport tcp -pkt_size 1316  rtsp://"localhost:8554"/mystream > /dev/null 2>&1
```
# camera ov5647

```bash
stdbuf -o0 -e0  chrt -f 50 taskset -c 3  rpicam-vid --flush   -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=main  --hdr=off --level 4.0 --framerate 25 --width 1296 --height 972   --av-sync=0 \
--audio-codec libopus --audio-samplerate 48000 --shutter 20000 --tuning-file  /usr/share/libcamera/ipa/rpi/vc4/ov5647.json  \
--audio-channels 2 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 45 taskset -c 2  ffmpeg   -loglevel warning  -hide_banner \
-fflags nobuffer+genpts+flush_packets -isync 0 -copyts -start_at_zero  \
-hwaccel drm -hwaccel_output_format drm_prime  -fpsprobesize 0   -f mpegts  -i -  -metadata title='lucy' -c copy -copyts   \
-flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-rtsp_flags filter_src   -tcp_nodelay 1  -rtsp_transport tcp -pkt_size 1316  rtsp://
```

##############################################################################

# sync stable over 24 h all rpi with or without audiodrifft more cpu but zero2w also working

```bash
nice -11 stdbuf -oL -eL taskset -c 3 rpicam-vid --denoise cdn_off -t 0 --width 1536 --height 864 --framerate 25 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline   \
--awb indoor --profile main --intra 10 -b 1500000 -n -o - | \
nice -11 taskset -c 2 ffmpeg -y -fflags +genpts+igndts+nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-thread_queue_size 128 -f h264 -r 25 -i - \
-thread_queue_size 128 -f pulse -fragment_size 1024 -isync 0 -copyts -start_at_zero -i default \
-c:v copy   \
-c:a-c:a libopus -b:a 64k -ac 1 -vbr on -compression_level 10 -application lowdelay \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport tcp -tcp_nodelay 1 -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316 -rtpflags latm \
rtsp://"localhost:8554"/mystream
```

#######################################################################################################
