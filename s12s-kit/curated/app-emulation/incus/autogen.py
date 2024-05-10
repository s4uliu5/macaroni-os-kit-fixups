from packaging.specifiers import SpecifierSet
from packaging.version import Version

async def generate(hub, **pkginfo):
	supported_releases = {
		'pre-lts': '<1.0.0',
		'lts': '>=6.0.0,<6.1',
		'post-lts': '>=6.1',
	}
	github_user = "lxc"
	github_repo = "incus"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	handled_releases=[]

	for rel in json_list:
		if len(supported_releases) == 0:
			break

		version = tar_version = ""
		tag = rel["tag_name"][1:]

		v1 = Version(tag)
		for k, v in supported_releases.items():
			selector = SpecifierSet(v)
			if v1 in selector:
				v = Version(tag)
				tar_version = tag
				version = tag
				if v.micro == 0 and k != "lts":
					tar_version = "%s.%s" % (v.major, v.minor)

				handled_releases.append([version, tar_version])
				del supported_releases[k]
				break

	artifacts = []
	for version_tar_version in handled_releases:

		[pv, tar_version] = version_tar_version

		url=f"https://github.com/lxc/incus/releases/download/v{pv}/incus-{tar_version}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			tar_version=tar_version,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
		)
		ebuild.push()
