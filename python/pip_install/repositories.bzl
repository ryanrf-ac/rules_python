""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

_RULE_DEPS = [
    (
        "pypi__pip",
        "https://files.pythonhosted.org/packages/fe/ef/60d7ba03b5c442309ef42e7d69959f73aacccd0d86008362a681c4698e83/pip-21.0.1-py3-none-any.whl",
        "37fd50e056e2aed635dec96594606f0286640489b0db0ce7607f7e51890372d5",
    ),
    (
        "pypi__pkginfo",
        "https://files.pythonhosted.org/packages/4f/3c/535287349af1b117e082f8e77feca52fbe2fdf61ef1e6da6bcc2a72a3a79/pkginfo-1.6.1-py2.py3-none-any.whl",
        "ce14d7296c673dc4c61c759a0b6c14bae34e34eb819c0017bb6ca5b7292c56e9",
    ),
    (
        "pypi__setuptools",
        "https://files.pythonhosted.org/packages/9e/d4/b99a960314121a003e9f39c61dfde01a1010bb47661e193a7722f7f32d52/setuptools-54.2.0-py3-none-any.whl",
        "b726461910b9ba30f077880c228bea22121aec50b172edf39eb7ff026c054a11",
    ),
    (
        "pypi__wheel",
        "https://files.pythonhosted.org/packages/65/63/39d04c74222770ed1589c0eaba06c05891801219272420b40311cd60c880/wheel-0.36.2-py2.py3-none-any.whl",
        "78b5b185f0e5763c26ca1e324373aadd49182ca90e825f7853f4b2509215dc0e",
    ),
]

_GENERIC_WHEEL = """\
package(default_visibility = ["//visibility:public"])

load("@rules_python//python:defs.bzl", "py_library")

py_library(
    name = "lib",
    srcs = glob(["**/*.py"]),
    data = glob(["**/*"], exclude=["**/*.py", "**/* *", "BUILD", "WORKSPACE"]),
    # This makes this directory a top-level in the python import
    # search path for anything that depends on this.
    imports = ["."],
)
"""

# Collate all the repository names so they can be easily consumed
all_requirements = [name for (name, _, _) in _RULE_DEPS]

def requirement(pkg):
    return "@pypi__" + pkg + "//:lib"

def pip_install_dependencies():
    """
    Fetch dependencies these rules depend on. Workspaces that use the pip_install rule can call this.

    (However we call it from pip_install, making it optional for users to do so.)
    """
    for (name, url, sha256) in _RULE_DEPS:
        maybe(
            http_archive,
            name,
            url = url,
            sha256 = sha256,
            type = "zip",
            build_file_content = _GENERIC_WHEEL,
        )
