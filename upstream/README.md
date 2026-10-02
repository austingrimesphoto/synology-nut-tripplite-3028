# Upstream NUT contribution

NUT issue #2030 tracks Tripp Lite USB product ID `3028`. The physically validated change is `{ USB_DEVICE(TRIPPLITE_VENDORID, 0x3028), smart1500lcdt_scale },`. Submit the patch independently of the Synology layer and use DCO sign-off (`git commit -s`).


The scaling patch is only one half of the observed device quirk. The validated unit also needs explicit `usb_hid_rep_index=1` and `usb_hid_ep_in=2`. Upstream work should not close #2030 as fully solved unless interface auto-selection is addressed or the required options are documented.
