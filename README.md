##     RTSP STREAMING WITH AUDIO FOR RPI CAMERAS


```bash
git clone https://github.com/spookyfirehorse/ffmpeg-and-mpv-for-rpi4.git
cd spookyfirehorse/ffmpeg-and-mpv-for-rpi4/build_kernel
chmod +x build_kernel
```
# pi 5 -c 7 realtime kernel 6.18 example

```bash
sudo ./build-kernel -b default --branch rpi-6.18.y -c 7 -j 6 -u -d  
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
pcm.!default {
    type pipewire
}

ctl.!default {
    type pipewire
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
 PIPEWIRE_LATENCY="1024/48000" stdbuf -o0 -e0 chrt -f 45 taskset -c 3 \
rpicam-vid -b 1000000 --denoise cdn_off --codec libav --libav-format mpegts \
--profile=main --hdr=off --level 4.1 --width 1536 --height 864 --av-sync=0 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --audio-codec libopus --audio-samplerate 48000 \
--shutter 20000 --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json \
--audio-channels 2 --libav-audio 1 --audio-source alsa --audio-device pipewire \
--awb indoor -t 0 --intra 30 --inline -n -o - | \
PIPEWIRE_LATENCY="1024/48000" chrt -f 45 taskset -c 2 ffmpeg \
-loglevel warning -hide_banner -fflags +nobuffer+genpts -f mpegts -isync 0 \
-i - -metadata title='kali' -c copy -flags low_delay -avioflags direct \
-map 0:v -map 0:a -muxdelay 0.01 -f rtsp -buffer_size 512 \
-rtsp_flags filter_src -tcp_nodelay 1 -rtsp_transport tcp -pkt_size 1316 rtsp://localhost:8554/mystream > /dev/null 2>&1
```


       PIPEWIRE_LATENCY="2048/48000"

```
# camera ov5647

```bash
PULSE_LATENCY_MSEC=43 stdbuf -o0 -e0 nice -n 11  taskset -c 3  rpicam-vid --flush   -b 1000000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=main  --hdr=off --level 4.0  --width 1296 --height 972   --av-sync=0 --libav-video-codec h264_v4l2m2m  \
--audio-codec libopus --audio-samplerate 48000 --shutter 20000 --tuning-file  /usr/share/libcamera/ipa/rpi/vc4/ov5647.json  \
--audio-channels 2 --libav-audio 1 --audio-source alsa --audio-device pipewire  --awb indoor -t 0 --intra 30 \
--inline  -n  -o  - | nice -n 10  taskset -c 1  ffmpeg   -loglevel warning  -hide_banner \
-fflags nobuffer+flush_packets    \
 -vcodec h264_v4l2m2m    -f mpegts -isync 0  -i -  -metadata title='moon' -c copy    \
-flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0.01  -f rtsp  \
-rtsp_flags filter_src   -tcp_nodelay 1  -rtsp_transport tcp -pkt_size 1316 -buffer_size 512   rtsp://localhost:8554/mystream  > /dev/null 2>&1

```
     PIPEWIRE_LATENCY="2048/48000"
     
##############################################################################

# sync stable over 24 h all rpi with or without audiodrifft more cpu but zero2w also working

```bash
PULSE_LATENCY_MSEC=43 nice -11 stdbuf -o0 -e0 taskset -c 3 rpicam-vid --denoise cdn_off -t 0 --width 1536 --height 864 --framerate 25 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile main --intra 10 -b 1500000 -n -o - | \
nice -11 taskset -c 2 ffmpeg -y -fflags +nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-f h264 -r 25 -i - \
-f pulse  -copyts  -isync 0 -i default \
-c:v copy \
-c:a libopus -b:a 64k -ac 1 -vbr on -compression_level 10 -application lowdelay \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport tcp -tcp_nodelay 1 -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316 -rtpflags latm \
rtsp://localhost:8554/mystream

```
      PIPEWIRE_LATENCY="2048/48000"
      
#######################################################################################################

#libfdk-aac

```bash
PIPEWIRE_LATENCY="256/48000" \
nice -n -11 stdbuf -oL -eL rpicam-vid --denoise cdn_off -t 0 --width 1280 --height 720 --framerate 30 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile main --intra 30 -b 1500000 -n -o - | \
PIPEWIRE_LATENCY="256/48000" \
nice -n -11 ffmpeg -y -fflags +genpts+nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-f h264 -r 30 -i - \
-f alsa  -isync 0 -i pipewire \
-c:v copy -metadata title='devil' \
-c:a libfdk_aac -profile:a aac_low -flags +global_header  -b:a 64k -ar 44100   -b:a 64k -ac 1 -vbr 0  -afterburner 1   \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport udp  -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316 -buffer_size 512  \
rtsp://
```

```bash
sudo nano /etc/udev/rules.d/99-network-irq.rules
ACTION=="add", SUBSYSTEM=="net", NAME=="eth0", RUN+="/bin/sh -c 'for irq in $(grep eth0 /proc/interrupts | cut -d: -f1); do echo 3 > /proc/irq/$irq/smp_affinity; done'"
```
```bash
echo 3 | sudo tee /proc/irq/28/smp_affinity
echo 3 | sudo tee /proc/irq/29/smp_affinity
```


```bash
ACTION=="add", SUBSYSTEM=="net", NAME=="eth0", RUN+="/bin/sh -c 'for irq in $(grep eth0 /proc/interrupts | cut -d: -f1); do echo 3 > /proc/irq/$irq/smp_affinity; done'"
console=serial0,115200 console=tty1 root=PARTUUID=90702f99-02 rootfstype=ext4 fsck.repair=yes rootwait cfg80211.ieee80211_regdom=AT isolcpus=2,3 nohz_full=2,3 rcu_nocbs=2,3 irqaffinity=0,1
```
