#!/usr/bin/env python3

import json
import re
from packaging import version

def get_latest_tag(json):
    return sorted(json, key=lambda tag: version.parse(tag["name"])).pop()


async def generate(hub, **pkginfo):

	github_user = "kdave"
	github_repo = pkginfo["name"]
	json_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)

	latest_tag = get_latest_tag(json_data)
	if latest_tag is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable tag of {repo}")

	tag = latest_tag["name"]
	final_name = f"{github_repo}-{tag}.tar.xz"
	url = f"https://www.kernel.org/pub/linux/kernel/people/{github_user}/{github_repo}/{final_name}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=tag.lstrip("v"),
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
