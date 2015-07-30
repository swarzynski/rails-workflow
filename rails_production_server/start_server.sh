#!/bin/bash
NAME_OF_BOX=rails-production-server

vboxmanage startvm "${NAME_OF_BOX}" --type headless
