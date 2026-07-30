#!/system/bin/sh
# Preserve a custom recovery across an A/B OTA.
#
# Started by init when the Updater sets sys.updater.keep_recovery=1 (see keep_recovery.rc),
# which happens once update_engine has finished writing the target (inactive) slot and
# before the user reboots. At that point ro.boot.slot_suffix still names the running slot
# (the one holding the custom recovery), and the OTA has just put a stock recovery on the
# other slot. Copy the running slot's recovery onto the other slot so the custom recovery
# survives. Best-effort: any failure is harmless (the stock recovery simply remains).

suffix="$(getprop ro.boot.slot_suffix)"
case "$suffix" in
    _a) other=_b ;;
    _b) other=_a ;;
    *)
        # Non-A/B or unexpected slot: nothing to do.
        setprop sys.updater.keep_recovery 0
        exit 0
        ;;
esac

src="/dev/block/by-name/recovery${suffix}"
dst="/dev/block/by-name/recovery${other}"

if [ -e "$src" ] && [ -e "$dst" ]; then
    dd if="$src" of="$dst" bs=4M
fi

# Re-arm so the next update triggers a fresh copy.
setprop sys.updater.keep_recovery 0
