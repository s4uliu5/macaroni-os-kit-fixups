async def generate(hub, **pkginfo):
	for pv, unmasked in [ ("5.6", True), ("5.7", True), ("5.8", True), ("5.9", True), ("5.10", True) ]:
		url=f"https://linuxcontainers.org/downloads/lxd/lxd-{pv}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
			unmasked=unmasked
		)
		ebuild.push()

# vim: ts=4 sw=4 noet