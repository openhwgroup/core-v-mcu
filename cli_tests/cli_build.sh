#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage ./cli_buld new_workspace"
    exit 1
fi
eclipse -nosplash --launcher.suppressErrors -application org.eclipse.cdt.managedbuilder.core.headlessbuild -data ~/$1 -import . -cleanBuild cli_test/Default
