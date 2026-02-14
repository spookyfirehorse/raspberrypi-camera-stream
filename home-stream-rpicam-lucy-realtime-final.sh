#!/bin/bash

PULSE_LATENCY_MSEC=5 stdbuf -o0 -e0  chrt -f 90 taskset -c 0,1  rpicam-vid --flush   -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=high  --hdr=off --level 4.1 --framerate 25  --width 1280 --height 720   --av-sync=0 \
--autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 \
--audio-codec libopus --audio-samplerate 48000 --shutter 20000 --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json  \
--audio-channels 2 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 90 taskset -c 3  ffmpeg   -loglevel warning  -hide_banner -fflags nobuffer+genpts+flush_packets \
-hwaccel drm -hwaccel_output_format drm_prime -f mpegts  -i -  -metadata title='lucy' -c copy -copyts \
-fps_mode passthrough   -flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-rtsp_flags filter_src -tcp_nodelay 1  -rtsp_transport tcp -pkt_size 1316



stdbuf -o0 -e0 chrt -f 90 taskset -c 0,1 rpicam-vid --flush --low-latency --verbose 0 \
--denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal \
--autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile high --level 4.2 --intra 25 -b 1500000 -n -o - 2>/dev/null | \
PULSE_LATENCY_MSEC=10 chrt -f 90 taskset -c 3 ffmpeg -y -loglevel warning -hwaccel drm \
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


stdbuf -o0 -e0 chrt -f 90 taskset -c 0,1  rpicam-vid  --flush  -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=high  --hdr=off --level 4.1 --framerate 25  --width 1280 --height 720   --av-sync=0 \
--autofocus-mode manual --autofocus-range normal --autofocus-window  0.25,0.25,0.5,0.5 --audio-codec libopus \
--audio-channels 2 --libav-audio 1 --audio-source pulse  --awb indoor -t 0 --intra 25 \
--inline  -n  -o  - | chrt -f 90 taskset -c 3  ffmpeg -loglevel warning  -hide_banner -fflags nobuffer+genpts+flush_packets \
-hwaccel drm -hwaccel_output_format drm_prime -re  -i -  -metadata title='lucy' -c copy -copyts \
-fps_mode passthrough   -flags low_delay -avioflags direct -map 0:0 -map 0:1 -muxdelay 0  -f rtsp -buffer_size 4k \
-muxdelay 0.1 -rtsp_flags filter_src -tcp_nodelay 1 -rtsp_transport tcp -pkt_size 1316  rtsp://"user:pwd"@"localhost:8557"/mystream



# -sws_flags fast_bilinear

```bash
stdbuf -o0 -e0 chrt -f 90 taskset -c 0,1  rpicam-vid --denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile high --level 4.0 --intra 25 -b 1500000 -n -o - | \
PULSE_LATENCY_MSEC=10 chrt -f 90 taskset -c 3 ffmpeg -y -fflags +genpts+igndts+nobuffer+flush_packets -loglevel warning -hwaccel drm \
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


