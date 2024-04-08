async def generate(hub, **pkginfo):

	for pv, unmasked in [
		("5.17", True),
		("5.18", True),
		("5.19", True),
		("5.20", True),
	]:
		url=f"https://github.com/canonical/lxd/releases/download/lxd-{pv}/lxd-{pv}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
			unmasked=unmasked
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
