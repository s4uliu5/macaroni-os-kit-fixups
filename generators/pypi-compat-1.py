#!/usr/bin/python3

# This generator is designed to generate two ebuilds, one a foo-compat ebuild that provides python2.7 compatibility,
# and the other a foo ebuild that provides python3 compatibility. But the foo ebuild will 'advertise' python2.7
# compatibility as well, and if enabled, it will RDEPEND on foo-compat.
#
# This will allow packages that still expect foo to work with python2.7 to continue to be able to depend upon foo.
# Everything should still work.
#
# When upgrading from an older 'classic' ebuild that has python2.7 compatibility, first the foo ebuild will be
# merged, which will jettison 2.7 support, but immediately afterwards, foo-compat will be merged if needed and
# 2.7 compatibility will be back.

import glob
import os
import toml

GLOBAL_DEFAULTS = {"cat": "dev-python", "refresh_interval": None, "python_compat": "python3+"}


async def add_ebuild(hub, json_dict=None, compat_ebuild=False, has_compat_ebuild=False, **pkginfo):
	"""
	has_compat_ebuild is a boolean that lets us know, when we're creating the non-compat ebuild --
	will we be creating a compat ebuild also? Because we do special filtering on python_compat
	in this case.
	"""
	local_pkginfo = pkginfo.copy()
	assert "python_compat" in local_pkginfo, f"python_compat is not defined in {local_pkginfo}"
	local_pkginfo["compat_ebuild"] = compat_ebuild
	hub.pkgtools.pyhelper.pypi_metadata_init(local_pkginfo, json_dict)
	hub.pkgtools.pyhelper.expand_pydeps(local_pkginfo, compat_mode=True, compat_ebuild=compat_ebuild)
	if compat_ebuild:
		local_pkginfo["python_compat"] = "python2_7"
		if isinstance(local_pkginfo["compat"], str):
			# assume compat is just the compat version
			hub.pkgtools.model.log.debug(f"For compat ebuild, setting version to {local_pkginfo['compat']}")
			local_pkginfo["version"] = local_pkginfo["compat"]
		else:
			# assume we are overriding more things
			local_pkginfo.update(local_pkginfo["compat"])
		local_pkginfo["name"] = local_pkginfo["name"] + "-compat"
		if "du_pep517" in local_pkginfo:
			# It doesn't make sense to enable new PEP 517 support for python2.7-compat ebuilds:
			del local_pkginfo["du_pep517"]
		# TODO: this doesn't work if we want to filter to make sure we have a compatible version -- we can't directly pick it.
		artifact_url = hub.pkgtools.pyhelper.pypi_get_artifact_url(local_pkginfo, json_dict, has_python="2.7", strict=True)
	else:
		if has_compat_ebuild:
			compat_split = local_pkginfo["python_compat"].split()
			new_compat_split = []
			for compat_item in compat_split:
				if compat_item == "python2+":
					# Since we're making a compat ebuild, we really don't want our main ebuild to advertise py2 compat.
					new_compat_split.append("python3+")
				else:
					new_compat_split.append(compat_item)
			local_pkginfo["python_compat"] = " ".join(new_compat_split)
		if "version" in local_pkginfo and local_pkginfo["version"] != "latest":
			version_specified = True
		else:
			version_specified = False
			# get latest version
			local_pkginfo["version"] = json_dict["info"]["version"]
		if "requires_python_override" in local_pkginfo:
			# Allow YAML to override bogus upstream pypi requires_python settings:
			requires_python_override = local_pkginfo["requires_python_override"]
		else:
			# Use upstream values:
			requires_python_override = None
		python_kit = hub.release_yaml.get_primary_kit(name="python-kit")
		has_python = python_kit.settings["has_python"]
		artifact_url = hub.pkgtools.pyhelper.pypi_get_artifact_url(local_pkginfo, json_dict, strict=version_specified, has_python=has_python,
						requires_python_override=requires_python_override)
	# fixup $S automatically -- this seems to follow the name in the archive:

	under_name = pkginfo["name"].replace("-", "_")
	over_name = pkginfo["name"].replace("_", "-")
	local_pkginfo["s_pkg_name"] = pkginfo["pypi_name"]

	hub.pkgtools.pyhelper.pypi_normalize_version(local_pkginfo)

	artifacts = [hub.pkgtools.ebuild.Artifact(url=artifact_url)]
	await artifacts[0].fetch()
	artifacts[0].extract()
	main_dir = glob.glob(os.path.join(artifacts[0].extract_path, "*"))
	if len(main_dir) != 1:
		raise ValueError("Found more than one directory inside python module")
	main_dir = main_dir[0]
	main_base = os.path.basename(main_dir)

	# deal with fact that "-" and "_" are treated as equivalent by pypi:
	if not main_base.startswith(pkginfo["name"]):
		if main_base.startswith(under_name):
			local_pkginfo["s_pkg_name"] = under_name
		elif main_base.startswith(over_name):
			local_pkginfo["s_pkg_name"] = over_name

	assert (
		artifact_url is not None
	), f"Artifact URL could not be found in {pkginfo['name']} {local_pkginfo['version']}. This can indicate a PyPi package without a 'source' distribution."
	local_pkginfo["template_path"] = os.path.normpath(os.path.join(os.path.dirname(__file__), "templates"))

	if not compat_ebuild and "du_pep517" in local_pkginfo and local_pkginfo["du_pep517"] == "generator":

		setup_path = glob.glob(os.path.join(artifacts[0].extract_path, "*", "setup.py"))
		if len(setup_path):
			has_setup = True
		else:
			has_setup = False
		pyproject_path = glob.glob(os.path.join(artifacts[0].extract_path, "*", "pyproject.toml"))
		if len(pyproject_path):
			has_pyproject = True
		else:
			has_pyproject = False
		if has_setup and not has_pyproject:
			del local_pkginfo["du_pep517"]
		elif not has_setup and has_pyproject:
			with open(pyproject_path[0], "r") as f:
				toml_data = toml.load(f)
				if "build-system" not in toml_data:
					raise ValueError("Cannot find build system in pyproject.toml data")
				if "requires" not in toml_data["build-system"]:
					raise ValueError("Cannot find build-system/requires in pyproject.toml data")

				for req in toml_data["build-system"]["requires"]:
					if req.startswith("flit_core"):
						local_pkginfo["du_pep517"] = "flit"
						break
					elif req.startswith("hatchling"):
						local_pkginfo["du_pep517"] = "hatchling"
					elif req.startswith("setuptools_scm"):
						local_pkginfo["du_pep517"] = "setuptools"
						if "depend" not in local_pkginfo:
							local_pkginfo["depend"] = ""
						local_pkginfo["depend"] += 'dev-python/setuptools_scm[${PYTHON_USEDEP}]\n'
					elif req.startswith("setuptools"):
						local_pkginfo["du_pep517"] = "setuptools"
				if local_pkginfo["du_pep517"] == "generator":
					raise ValueError(f"{local_pkginfo['name']}: Could not auto-detect build system in pyproject.toml.")
				else:
					hub.pkgtools.model.log.info(f"{local_pkginfo['name']}: Auto-detected build system: {local_pkginfo['du_pep517']}")
	if "cargo" in local_pkginfo["inherit"] and not compat_ebuild:
		if "cargo_path" in local_pkginfo:
			cargo_path = "*/"+local_pkginfo["cargo_path"]
		else:
			cargo_path = "*"
		cargo_artifacts = await hub.pkgtools.rust.generate_crates_from_artifact(artifacts[0], cargo_path)
		local_pkginfo["crates"] = cargo_artifacts["crates"]
		artifacts = [*artifacts, *cargo_artifacts["crates_artifacts"]]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**local_pkginfo,
		artifacts=artifacts,
		template="pypi-compat-1.tmpl"
	)
	ebuild.push()


async def generate(hub, **pkginfo):
	pypi_name = hub.pkgtools.pyhelper.pypi_normalize_name(pkginfo)
	json_dict = await hub.pkgtools.fetch.get_page(
		f"https://pypi.org/pypi/{pypi_name}/json", refresh_interval=pkginfo["refresh_interval"], is_json=True
	)
	do_compat_ebuild = "compat" in pkginfo and pkginfo["compat"]
	await add_ebuild(hub, json_dict, compat_ebuild=False, has_compat_ebuild=do_compat_ebuild, **pkginfo)
	if do_compat_ebuild:
		await add_ebuild(hub, json_dict, compat_ebuild=True, **pkginfo)


# vim: ts=4 sw=4 noet
