#!/bin/bash

wge t http://deb.debian.org/debian/pool/non-free/f/fdk-aac/libfdk-aac-dev_2.0.3-1_arm64.deb

wget http://deb.debian.org/debian/pool/non-free/f/fdk-aac/libfdk-aac2t64_2.0.3-1_arm64.deb


sudo dpkg -i libfdk*

pi 5 install ffmpeg

git clone -b test/7.1.2/main --depth 1 https://github.com/jc-kynesim/rpi-ffmpeg.git && cd rpi-ffmpeg/ && \
./configure --prefix=/usr --extra-version=0+deb13u1+rpt2 --toolchain=hardened \
--incdir=/usr/include/aarch64-linux-gnu --libdir=/usr/lib/aarch64-linux-gnu \
--enable-gpl --enable-nonfree --enable-shared --disable-static \
--arch=aarch64 --cpu=cortex-a76 --extra-cflags="-mcpu=cortex-a76 -mtune=cortex-a76" --extra-ldflags="-latomic" --enable-neon \
--enable-gnutls --enable-libxml2 --enable-libudev --enable-v4l2-m2m --enable-sand --enable-v4l2-request \
--enable-libx264 --enable-libx265 --enable-libopus --enable-libfdk-aac --enable-libmp3lame \
--enable-libvorbis --enable-libvpx --enable-libdav1d --enable-libaom --enable-libwebp --enable-libzimg \
--enable-libass --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libharfbuzz \
--enable-libpulse --enable-libjack --enable-libssh --enable-libsrt --enable-libzmq \
--enable-opengl --enable-vulkan --enable-epoxy --enable-libdrm  --enable-vout-drm  --enable-sdl2 \
--disable-v4l2-request --disable-mmal --disable-omx --disable-libmfx --disable-libvpl \
--disable-libbluray --disable-libmysofa --disable-libcaca --disable-pocketsphinx --disable-libjxl \
--disable-chromaprint --disable-libdvdnav --disable-libdvdread --disable-libcodec2 --disable-libgsm --disable-libgme --disable-libopenmpt \
--disable-cuda --disable-cuvid --disable-nvenc --disable-nvdec --disable-ffnvcodec --disable-vaapi --disable-vdpau \
--disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages --disable-vfp --disable-thumb --enable-hardcoded-tables  && \
make -j$(nproc) && sudo make install

pi4 install ffmpeg

sudo apt build-dep ffmpeg -y && git clone -b test/7.1.2/main --depth 1 https://github.com/jc-kynesim/rpi-ffmpeg.git && cd rpi-ffmpeg/ && \
./configure --prefix=/usr --extra-version=0+deb13u1+rpt2 \
--toolchain=hardened --enable-gpl --enable-nonfree \
--enable-shared --disable-static --incdir=/usr/include/aarch64-linux-gnu --libdir=/usr/lib/aarch64-linux-gnu \
--disable-doc --disable-debug --disable-stripping \
--arch=aarch64 --cpu=cortex-a72 --extra-cflags="-mcpu=cortex-a72 -mtune=cortex-a72" --extra-ldflags="-latomic" \
--enable-neon --disable-vfp --disable-thumb --enable-epoxy --enable-v4l2-request \
--enable-libssh --enable-gnutls --enable-network \
--enable-v4l2-m2m --disable-v4l2-request --enable-libdrm --enable-libudev \
--enable-libx264 --enable-libx265 --enable-libvpx --enable-libdav1d \
--enable-libopus --enable-libfdk-aac --enable-libmp3lame --enable-libvorbis \
--enable-libpulse --enable-libxml2  \
--enable-libass --enable-libfreetype --enable-libfontconfig \
--enable-libwebp --enable-libzimg \
--enable-opengl --enable-sand --enable-vout-drm \
--disable-vaapi --disable-vdpau --disable-vulkan \
--disable-cuda --disable-cuvid --disable-nvenc --disable-nvdec --disable-ffnvcodec \
--disable-appkit --disable-avfoundation --disable-coreimage --disable-audiotoolbox \
--disable-videotoolbox --disable-amf --disable-d3d11va --disable-dxva2 \
--disable-mediafoundation --disable-libmfx --disable-libvpl --disable-libnpp \
--disable-mmal --disable-omx --disable-vfp --disable-thumb \
--disable-libcaca --disable-libbluray --disable-libmysofa --disable-pocketsphinx --disable-libjxl --enable-hardcoded-tables   && \
make -j$(nproc) && \
sudo make install

apt source mpv
cd mpv
meson setup build
meson setup build \
--prefix=/usr \
--buildtype=release \
-Dlibmpv=true \
-Dwayland=enabled \
-Ddmabuf-wayland=enabled \
-Dpipewire=enabled \
-Dvulkan=enabled \
-Ddrm=enabled \
-Dgbm=enabled \
-Dvaapi=disabled \
-Dvdpau=disabled \
-Dcuda-hwaccel=disabled 
sudo meson install -C build


sudo apt install pipewire-alsa rtkit

change from low-latency to realtime 512 to 256

sudo rm -r /etc/pipewire
sudo mkdir /etc/pipewire
sudo mkdir /etc/pipewire/pipewire.conf.d/
sudo nano /etc/pipewire/pipewire.conf.d/10-low-latency.conf

context.properties = {
    default.clock.rate          = 48000
    default.clock.quantum       = 512
    default.clock.min-quantum   = 512
    default.clock.max-quantum   = 512
}


sudo nano /etc/enviroment

PIPEWIRE_LATENCY=512/48000

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


direct alsa to pipewire

nano .asoundrc

ctl.!default {
    type pipewire
}

pcm.!default {
    type pipewire
    mmap_emulation 1
}

nano .bashrc

alias alsamixer='alsamixer -c 0'
alias amixer='amixer -c 0'


nano .asoundrc

ctl.!default {
    type hw
    card 0
}

# --- DEFAULT PCM ---
pcm.!default {
    type asym
    playback.pcm "dmix_out"
    capture.pcm "dsnoop_in"
}

# --- WIEDERGABE-LAYER (dmix auf Karte 2) ---
pcm.dmix_out {
    type dmix
    ipc_key 1024
    ipc_key_add_uid false
    ipc_perm 0666
    slave {
        pcm "hw:0,0"
        format S16_LE
        rate 48000
        channels 2
        period_size 1024
        buffer_size 4096
    }
    bindings {
        0 0
        1 1
    }
}

# --- AUFNAHME-LAYER (dsnoop auf Karte 2) ---
pcm.dsnoop_in {
    type dsnoop
    ipc_key 2048
    ipc_key_add_uid false
    ipc_perm 0666
    slave {
        pcm "hw:0,0"
        format S16_LE
        rate 48000
        channels 2
        period_size 1024
        buffer_size 4096
    }
    bindings {
        0 0
        1 1
    }
}




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


# realtime rpicam-vid for video pipewire for audio -isync 0 -use_wallclock

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

# normal quick works on all kernels without realtime

stdbuf -o0 -e0 chrt -f 50 taskset -c 0,1  rpicam-vid  --flush  -b 1500000    --denoise cdn_off   --codec libav --libav-format mpegts \
--profile=main  --hdr=off --level 4.0 --framerate 25  --width 1280 --height 720   --av-sync=0 \
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

receiver mpv


nano .config/mpv/mpv.conf

[cam]
hwdec=auto 
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


mpv --profile=cam rtsp://

ripping dvd

ffmpeg -y -fflags +genpts+igndts+discardcorrupt -fix_sub_duration \
  -probesize 3400M -analyzeduration 3410M -ifo_palette default.IFO \
  -c:v mpeg2_v4l2m2m -i "$file" -ss 00:00:05 \
  -metadata title="${file%.*}" \
  -map 0:v? -map 0:a? -map 0:s? \
  -vf "deinterlace_v4l2m2m,scale_v4l2m2m=1280:720,setsar=1/1" \
  -pix_fmt yuv420p \
  -c:v h264_v4l2m2m -b:v 3M -maxrate 5M -bufsize 5M \
  -num_capture_buffers 128 -num_output_buffers 32 \
  -c:a libfdk_aac -b:a 128k -af "volume=1.5" \
  -c:s dvdsub \
  -movflags +faststart -avoid_negative_ts 1 -max_interleave_delta 0 \
  -f matroska "${file%.*}.mkv"
