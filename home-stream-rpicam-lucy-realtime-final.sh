#!/bin/bash

sudo apt install pipewire-alsa rtkit

sudo nano /etc/pipewire/pipewire.conf.d/10-low-latency.conf
context.properties = {
    default.clock.rate          = 48000
    default.clock.quantum       = 512
    default.clock.min-quantum   = 512
    default.clock.max-quantum   = 512
}


sudo nano /etc/enviroment

PIPEWIRE_LATENCY=256/48000

sudo nano /etc/group
dialout:x:20:spook
fax:x:21:
voice:x:22:spook
cdrom:x:24:spook
floppy:x:25:
tape:x:26:
sudo:x:27:spook
audio:x:29:pulse,spook
plugdev:x:46:spook
staff:x:50:
games:x:60:spook
users:x:100:spook
nogroup:x:65534:
systemd-journal:x:999:
systemd-network:x:998:
crontab:x:997:
input:x:996:lightdm,spook
sgx:x:995:
clock:x:994:
kvm:x:993:
render:x:992:vnc,spook
spi:x:989:spook
i2c:x:987:spook
gpio:x:986:spook
pipewire:x:105:spook
pulse:x:106:spook
pulse-access:x:107:
lightdm:x:108:
scanner:x:109:saned
lpadmin:x:110:spook
ssl-cert:x:111:
saned:x:112:
colord:x:113:
rdma:x:114:
vnc:x:985:
feedbackd:x:115:
spook:x:1000:
pihole:x:1001:
_chrony:x:116:
rtkit:x:117:spook,pulse

sudo nano /etc/security/limits.d/99-realtime.conf 

spook  -  rtprio     99
spook  -  memlock    unlimited
spook  -  nice      -20
#*  -  rtprio     99
#*  -  memlock    unlimited


git clone https://github.com/spookyfirehorse/ffmpeg-and-mpv-for-rpi4.git
cd spookyfirehorse/ffmpeg-and-mpv-for-rpi4/build_kernel
chmod +x build_kernel

# pi 5 realtime kernel 6.12

sudo ./build-kernel -b default --branch rpi-6.12.y -c 7 -j 6 -u -d  

# pi 4 realtime kernel 6.18

sudo ./build-kernel -b default --branch rpi-6.18.y -c 6 -j 6 -u -d



# realtime kernel realtime audio config


 stdbuf -o0 -e0  chrt -f 90 taskset -c 0,1  rpicam-vid --flush   -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=high  --hdr=off --level 4.1 --framerate 25  --width 1280 --height 720   --av-sync=0 \
--autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
--audio-codec libopus --audio-samplerate 48000 --shutter 20000 --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json  \
--audio-channels 2 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 90 taskset -c 3  ffmpeg   -loglevel warning  -hide_banner -fflags nobuffer+genpts+flush_packets \
-hwaccel drm -hwaccel_output_format drm_prime -f mpegts  -i -  -metadata title='lucy' -c copy -copyts \
-fps_mode passthrough   -flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-rtsp_flags filter_src -tcp_nodelay 1  -rtsp_transport tcp -pkt_size 1316


# realtime

stdbuf -o0 -e0 chrt -f 90 taskset -c 0,1 rpicam-vid --flush --low-latency --verbose 0 \
--denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal \
--autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile high --level 4.2 --intra 25 -b 1500000 -n -o - 2>/dev/null | \
chrt -f 90 taskset -c 3 ffmpeg -y -loglevel warning -hwaccel drm \
-hwaccel_device /dev/dri/renderD128 \
-fflags +genpts+igndts+nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-thread_queue_size 16 -f h264 -r 25 -i - \
-thread_queue_size 16 -f pulse -fragment_size 480 -isync 0 -i default \
-c:v copy -metadata title='lucy' \
-c:a libopus -application lowdelay -ac 1 -vbr off -b:a 64k -frame_duration 5 -compression_level 0 \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport tcp -tcp_nodelay 1 -rtsp_flags filter_src -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316 \
rtsp://"user:pwd"@"localhost:8557"/mystream > /dev/null 2>&1

# normal quick

stdbuf -o0 -e0 chrt -f 50 taskset -c 0,1  rpicam-vid  --flush  -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=high  --hdr=off --level 4.1 --framerate 25  --width 1280 --height 720   --av-sync=0 \
--autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 --audio-codec libopus \
--audio-channels 2 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 50 taskset -c 3  ffmpeg -loglevel warning  -hide_banner -fflags nobuffer+genpts+flush_packets \
-hwaccel drm -hwaccel_output_format drm_prime -re  -i -  -metadata title='lucy' -c copy -copyts \
-fps_mode passthrough   -flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-muxdelay 0.1 -rtsp_flags filter_src -tcp_nodelay 1 -rtsp_transport tcp -pkt_size 1316  rtsp://"user:pwd"@"localhost:8557"/mystream



# -sws_flags fast_bilinear

```bash
stdbuf -o0 -e0 chrt -f 90 taskset -c 0,1  rpicam-vid --denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile high --level 4.0 --intra 25 -b 1500000 -n -o - | \
chrt -f 90 taskset -c 3 ffmpeg -y -fflags +genpts+igndts+nobuffer+flush_packets -loglevel warning -hwaccel drm \
-hwaccel_device /dev/dri/renderD128 \
-use_wallclock_as_timestamps 1 \
-thread_queue_size 16 -f h264 -r 25 -i - \
-thread_queue_size 32 -f pulse -fragment_size 480 -isync 0 -i default \
-c:v copy -metadata title='lucy' \  
-c:a libfdk_aac  -b:a 64k -ac 1 -vbr 0  -afterburner 1 \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport udp -rtpflags latm  -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 131
rtsp://"user:pwd"@"localhost:8557"/mystream
```

```bash
stdbuf -oL -eL  chrt -f 90 taskset -c 3  rpicam-vid --flush   -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=baseline  --hdr=off --level 4.0 --framerate 25  --width 1280 --height 720   --av-sync=-10000 \
--autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
--audio-codec libopus --audio-samplerate 48000 --shutter 20000 --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json  \
--audio-channels 2 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 90 taskset -c 1  ffmpeg   -loglevel warning  -hide_banner -fflags nobuffer+genpts+flush_packets \
-hwaccel drm -hwaccel_output_format drm_prime -thread_queue_size 1024 -r 25  -f mpegts  -i -  -metadata title='lucy' -c copy -copyts \
-fps_mode cfr   -flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-rtsp_flags filter_src -tcp_nodelay 1  -rtsp_transport tcp -pkt_size 1316  rtsp://"MshcUBHU8P:VPxfYXKRXw"@"localhost:8557"/mystream
```

