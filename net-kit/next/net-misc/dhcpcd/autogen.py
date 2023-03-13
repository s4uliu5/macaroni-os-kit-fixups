#!/usr/bin/env python3

from packaging import version
from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	url = f"https://roy.marples.name/downloads/dhcpcd"
	html_data = await hub.pkgtools.fetch.get_page(url)
	soup = BeautifulSoup(html_data, "html.parser")
	archives = {}
	for link in soup.find_all("a"):
		href = link.get("href")
		if href is not None and href.endswith(".tar.xz"):
			ver = href.split(".tar")[0].split("/")[-1].replace("dhcpcd-","")
			if ver.upper().isupper():
				continue
			archives.update({ver:href})
	latest_version = sorted(archives, key=lambda x: version.parse(x)).pop()
	url = 'https://roy.marples.name'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url+archives[latest_version])],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet