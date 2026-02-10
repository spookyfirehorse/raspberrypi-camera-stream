#!/bin/bash
stdbuf -oL -eL chrt -f 90 taskset -c 0,1  rpicam-vid --flush --low-latency --verbose 0  \
--denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal \
--autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile high --level 4.2   --intra 25 -b 1500000 -n -o - 2>/dev/null  | \
PULSE_LATENCY_MSEC=10 chrt -f 90 taskset -c 3   ffmpeg -y -loglevel warning  -hwaccel drm -hwaccel_device /dev/dri/renderD128  \
-fflags +genpts+igndts+nobuffer+flush_packets  \
-use_wallclock_as_timestamps 1  \
-thread_queue_size 16 -f h264 -r 25 -i - \
-fragment_size 480 -thread_queue_size 16 -f pulse   -isync 0 -i default \
-c:v copy -metadata title='lucy'  \
-c:a libopus -application lowdelay -ac 1  -vbr off -b:a 64k -frame_duration 5  -compression_level 0  \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport tcp -rtsp_flags filter_src   -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316  \
rtsp://"MshcUBHU8P:VPxfYXKRXw"@"localhost:8557"/mystream > /dev/null 2>&1



# -sws_flags fast_bilinear


stdbuf -oL -eL chrt -f 90 taskset -c 0,1  rpicam-vid --denoise cdn_off -t 0 --width 1280 --height 720 --framerate 25 \
--autofocus-mode manual --autofocus-range normal --autofocus-window 0.25,0.25,0.5,0.5 \
--libav-video-codec h264_v4l2m2m --libav-format h264 --codec libav --inline \
--awb indoor --profile high --level 4.0 --intra 25 -b 1500000 -n -o - | \
PULSE_LATENCY_MSEC=10 chrt -f 90 taskset -c 3 ffmpeg -y -fflags +genpts+igndts+nobuffer+flush_packets \
-use_wallclock_as_timestamps 1 \
-thread_queue_size 16 -f h264 -r 25 -i - \
-thread_queue_size 32 -f pulse -fragment_size 480 -isync 0 -i default \
-c:v copy -metadata title='lucy' \
-c:a libfdk_aac  -b:a 64k -ac 1 -vbr 0  -afterburner 1   \
-map 0:v:0 -map 1:a:0 \
-f rtsp -rtsp_transport udp -rtpflags latm   -muxdelay 0 -flags +low_delay -avioflags direct -pkt_size 1316 \
rtsp://"MshcUBHU8P:VPxfYXKRXw"@"localhost:8557"/mystream



