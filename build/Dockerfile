FROM alpine@sha256:5291449c3df73caf6ed85e649dec1b9e818b39a5d8c871e97afc13e9cd5e8fa8 AS build

RUN apk add --no-cache autoconf automake bash binutils build-base file git libtool libusb-dev linux-headers pax-utils perl pkgconf python3
ARG NUT_COMMIT=0e051f9f6853e9ae0087b388b70840c9651a5eed
WORKDIR /build
RUN git clone --depth 1 --branch v2.8.5 https://github.com/networkupstools/nut.git nut && cd nut && test "$(git rev-parse HEAD)" = "$NUT_COMMIT"
COPY patches/nut-2.8.5-tripplite-3028.patch /build/3028.patch
WORKDIR /build/nut
RUN git apply --check /build/3028.patch && git apply /build/3028.patch && \
    git add drivers/tripplite-hid.c && \
    git -c user.name='Synology 3028 build' -c user.email='build@example.invalid' commit -m 'tripplite-hid: scale USB product 3028 like SMART1500LCDT'
RUN ./autogen.sh
RUN ./configure --prefix=/opt/nut-2.8.5 --sysconfdir=/etc --with-confdir=/etc/ups --with-drivers=usbhid-ups --with-serial=no --with-usb=libusb-1.0 --with-snmp=no --with-neon=no --with-powerman=no --with-modbus=no --with-gpio=no --with-avahi=no --with-ipmi=no --with-freeipmi=no --with-macosx_ups=no --with-linux_i2c=no --with-upower=no --with-nut_monitor=no --with-pynut=no --with-nut-scanner=no --with-cgi=no --with-dev=no --with-docs=no --with-ssl=no --with-libsystemd=no --with-systemdsystemunitdir=no --with-systemdsystempresetdir=no --with-systemdshutdowndir=no --with-systemdtmpfilesdir=no --with-systemdsysusersdir=no --with-user=root --with-group=root --with-statepath=/run/ups_state --with-altpidpath=/run --with-pidpath=/run --with-drvpath=/opt/nut-2.8.5/bin --enable-shared-private-libs=no --enable-strip=no
RUN make -j2 -C drivers usbhid-ups
RUN set -eu; mkdir -p /out/bin /out/lib /out/build; git archive --format=tar.gz -o /out/build/nut-2.8.5-3028-source.tar.gz HEAD; if file drivers/usbhid-ups | grep -q 'ELF'; then cp -a drivers/usbhid-ups /out/bin/usbhid-ups; else cp -a drivers/.libs/usbhid-ups /out/bin/usbhid-ups; fi; cp -a /lib/ld-musl-x86_64.so.1 /out/lib/; ldd /out/bin/usbhid-ups > /out/build/ldd.txt; awk '/=> \/.*\// {print $3} /^\// {print $1}' /out/build/ldd.txt | sort -u | while read -r lib; do [ -f "$lib" ] || continue; case "$(basename "$lib")" in ld-musl-x86_64.so.1) continue;; esac; cp -aL "$lib" "/out/lib/$(basename "$lib")"; done; printf '%s\n' 'v2.8.5' > /out/build/source-tag.txt; printf '%s\n' "$NUT_COMMIT" > /out/build/source-commit.txt; git show --format= --binary HEAD > /out/build/patch-applied.diff; git rev-parse HEAD > /out/build/patched-source-commit.txt; gcc --version > /out/build/compiler.txt; pkg-config --modversion libusb-1.0 > /out/build/libusb-version.txt; /out/bin/usbhid-ups -V > /out/build/driver-version.txt 2>&1 || true; strings /out/bin/usbhid-ups | grep -E 'Generic HID|TrippLite HID' | sort -u > /out/build/subdriver-versions.txt || true; readelf -h -l -d /out/bin/usbhid-ups > /out/build/readelf.txt; cd /out; sha256sum bin/usbhid-ups lib/* build/* > SHA256SUMS
FROM scratch
COPY --from=build /out /
