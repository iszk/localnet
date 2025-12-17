#!/bin/bash

set -e

AUTH_KEY="PLEASE_SET_YOUR_AUTH_KEY_HERE"

tailscale up --authkey="$AUTH_KEY" --accept-routes --advertise-exit-node --advertise-routes="10.2.0.0/16"
