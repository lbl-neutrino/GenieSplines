#!/usr/bin/env bash

gspladd -f spline1.xml,spline2.xml -o merged.xml

gspladd -d DIRECTORY_WITH_SPLINE_FILES_TO_MERGE -o merged.xml
