#!/bin/bash
NAME_OF_BOX=rails_production_server

vboxmanage startvm "${NAME_OF_BOX}" --type headless
