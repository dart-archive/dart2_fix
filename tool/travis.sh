#!/bin/bash

# Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Provision packages.
pub get

# Ensure the code analyzes cleanly.
dartanalyzer --fatal-warnings .

# Run the unit tests.
pub run test
