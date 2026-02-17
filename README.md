##     RTSP STREAMING WITH AUDIO FOR RPI CAMERAS


```bash
sudo nano /boot/firmware/cmdline.txt 
```
```bash
console=serial0,115200 console=tty1 root=PARTUUID=37b5fcd6-02 rootfstype=ext4 fsck.repair=yes rootwait  net.ifnames=0 isolcpus=3
```


isoliert 3 cpu for rpicam-vid isolcpus=3



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

# dont set it lower because audio comes in stream  to late 


```bash
sudo nano /etc/enviroment
```

```bash
PIPEWIRE_LATENCY=1024/48000
```

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



  #   install mediamtx 

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

# pulse or pipewire mikrofon name

     pactl list sources short
     

# for alsa

      arecord -L
     


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
vd-lavc-o=mpegts
```

     

#######################################################################################################################################
## best for pi 4 pi 5 may all rpi example imx camera ovm --width 1296 --height 972

```bash
rpicam-vid --list-cameras
```

```bash
rpicam-vid --list-cameras
Available cameras
-----------------
0 : imx708 [4608x2592 10-bit] (/base/soc/i2c0mux/i2c@1/imx708@1a)
    Modes: 'SBGGR10_CSI2P' : 1536x864 [30.00 fps - (65535, 65535)/65535x65535 crop]
                             2304x1296 [30.00 fps - (65535, 65535)/65535x65535 crop]
                             4608x2592 [30.00 fps - (65535, 65535)/65535x65535 crop]

```

# this is for av-sync audio drifft over 10 h

# sync stable over 24 h all rpi all kernels realtime low-latency

```bash
chrt -f 50 stdbuf -o0 -e0 taskset -c 3 rpicam-vid --denoise cdn_off -t 0 --width 1536 --height 864 --framerate 25 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline   \
--awb indoor --profile main --intra 10 -b 1500000 -n -o - | \
chrt -f 50 taskset -c 1 ffmpeg -y -fflags +genpts+igndts+nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-thread_queue_size 128 -f h264 -r 25 -i - \
-thread_queue_size 128 -f pulse -fragment_size 1024 -isync 0 -i default \
-c:v copy -copyts -start_at_zero \
-c:a libfdk_aac -profile:a aac_low -b:a 64k -ac 1 -vbr 0 \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport tcp -tcp_nodelay 1 -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316 -rtpflags latm \
rtsp://"spooky:password"@"localhost:8554"/mystream
```         

```bash         
mpv --profile=cam  rtsp://ip-rpi:8554/mystream
```        

for all rpi

####################################################################################################################################################

# min cpu stable

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
# dont set it lower because audio comes in stream  to late 


```bash
sudo nano /etc/enviroment
```

```bash
PIPEWIRE_LATENCY=1024/48000
```

# lower cpu

```bash
stdbuf -o0 -e0  chrt -f 50 taskset -c 3  rpicam-vid --flush   -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=main  --hdr=off --level 4.0 --framerate 25  --width 1536 --height 864   --av-sync=0 \
--autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
--audio-codec libopus --audio-samplerate 48000 --shutter 20000 --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json  \
--audio-channels 1 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 50 taskset -c 0  ffmpeg   -loglevel warning  -hide_banner -fflags nobuffer+genpts+flush_packets \
-hwaccel drm -hwaccel_output_format drm_prime -thread_queue_size 1024 -r 25  -f mpegts  -i -  -metadata title='lucy' -c copy -copyts -start_at_zero  \
-fps_mode cfr   -flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-rtsp_flags filter_src -tcp_nodelay 1  -rtsp_transport tcp -pkt_size 1316  rtsp://"user:pwd"@"localhost:8554"/mystream > /dev/null 2>&1
```



#######################################################################################################
