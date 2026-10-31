# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# 42-admin-metrics
using Amaquet, JSON, Random

uri = get(ENV, "AMAQUET_URI", "amaquet://127.0.0.1:13378")
api_key = get(ENV, "AMAQUET_API_KEY", nothing)

a = AdminClient(
    get(ENV, "AMAQUET_ADMIN_URL", "http://127.0.0.1:13379");
    bearer_token = get(ENV, "AMAQUET_ADMIN_TOKEN", nothing),
)

println(Amaquet.get_metrics(a))
