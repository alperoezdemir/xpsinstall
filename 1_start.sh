#!/bin/sh
loadkeys de
iwctl station wlan0 connect C-Style-5G
gdisk /dev/nvme0n1