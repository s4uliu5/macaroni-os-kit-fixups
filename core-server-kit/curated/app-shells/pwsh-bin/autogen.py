#!/usr/bin/env python3

import json
from datetime import timedelta


def find_release(json_dict):
	releases = filter(
		lambda x: x["prerelease"] is False
		and x["draft"] is False,
		json_dict,
	)
	releases = list(releases)
	if not len(releases):
		return None
	return sorted(releases, key=lambda x: x["tag_name"])[-1]


async def generate(hub, **pkginfo):

	json_dict = await hub.pkgtools.fetch.get_page(
		"https://api.github.com/repos/PowerShell/PowerShell/releases", is_json=True, refresh_interval=timedelta(days=5)
	)

	# Try to use the latest release version, but fall back to latest nightly if none found:
	release = None
	dl_asset = None

	r = find_release(json_dict)
	if r:
		dl_assets = list(
			filter(
				lambda x: x["browser_download_url"].endswith("-linux-x64.tar.gz"),
				r["assets"],
			)
		)
		if len(dl_assets):
				release = r
				dl_asset = dl_assets[0]
	
	if release is None or dl_asset is None:
		raise hub.pkgtools.ebuild.BreezyError("Can't find a suitable release of PowerShell.")

	version = release["tag_name"][1:]  # strip leading 'v'

	url = dl_asset["browser_download_url"]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
