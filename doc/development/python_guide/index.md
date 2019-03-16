# Python Development Guidelines

GitLab has a minimal usage of Python as a dependency for [reStructuredText][rst] markup rendering.

In the past we used to run it with Python 2, but now we require Python 3.

## Installation

There are several ways of installing python on your system. To be able to use the same version we use in production,
we suggest you use [pyenv][pyenv]. It works and behave similar to its counterpart in the ruby world: [rbenv][rbenv].

### Mac OS

To install `pyenv` on Mac OS, you can use [Homebrew][homebrew] with:

```bash
brew install pyenv
```

### Linux

To install `pyenv` on Linux, you can run the command below:

```bash
curl https://pyenv.run | bash
```

Alternatively you may find `pypenv` available as a system package via your distro package manager.

You can read more about it in : https://github.com/pyenv/pyenv-installer#prerequisites

### Shell integration

Pyenv installation will add required changes to Bash. If you use a different Shell environment
check for any additional steps required for it.

For Fish, you can install a plugin for [Fisherman][fisherman]:

```bash
fisher add fisherman/pyenv
```

Or for [Oh My Fish][omf]:

```bash
omf install pyenv
```

## Dependency management

While GitLab doesn't contain directly any Python script, because we depend on python to render [reStructuredText][rst] markup,
we need to keep track on dependencies on the main project level, so we can run that on our development machines.

There has been introduced recently an equivalent to the `Gemfile` and the [Bundler] project in python:
`Pipfile` and [Pipenv][pipenv].

You will now find a `Pipfile` with the dependencies on the root folder. To install them run:

```bash
pipenv install
```

By running this command it will install both the required Python version as well as required pip dependencies.

## Use instructions

To run any python code under the Pipenv environment, you need to first start a `virtualenv` based on the dependencies
of the application. With Pipenv, this is a simple as running:

```bash
pipenv shell
```

After running that command you can run GitLab on the same shell and it will be using the python and dependencies
installed from the `pipenv install` command.

[rst]: http://docutils.sourceforge.net/rst.html
[pyenv]: https://github.com/pyenv/pyenv
[rbenv]: https://github.com/rbenv/rbenv
[homebrew]: https://brew.sh/
[bundler]: https://bundler.io/
[pipenv]: https://pipenv.readthedocs.io/en/latest/
[fisherman]: https://github.com/fisherman/fisherman
[omf]: https://github.com/oh-my-fish/oh-my-fish
