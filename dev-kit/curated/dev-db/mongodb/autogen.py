#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	github_user = "mongodb"
	github_repo = "mongo"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags?per_page=100", is_json=True
	) + await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags?per_page=100&page=2", is_json=True
	)

	python_compat = "python3+"
	versions = []
	urls = []
	minor = None
	for tag in json_list:
		v = re.match(r"r((\d+).(\d+).\d+\b)(?!-)", tag["name"])
		if v is None:
			continue

		# skipping odd (not stable) minor versions
		if int(v[3]) % 2 != 0:
			minor = None
			continue

		if minor is not None:
			continue

		major, minor = v[2], v[3]
		if f"{major}.{minor}" not in ["3.6", "4.0", "4.2", "4.4"]:
			continue

		versions.append(v[1])
		urls.append(tag["tarball_url"])

	for version in versions:
		shortver = ".".join(version.split(".")[0:2])
		final_name = f'{pkginfo["name"]}-{version}.tar.gz'
		url = urls[versions.index(version)]
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			python_compat=python_compat,
			github_user=github_user,
			github_repo=github_repo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
			template=f'{pkginfo["name"]}-{shortver}.tmpl',
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
