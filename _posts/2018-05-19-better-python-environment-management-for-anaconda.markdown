---
layout: post
title:  "Better Python Environment Management for Anaconda on Mac OSX"
author: Ethan Miller
date:   2018-05-19
categories: tutorials
tags:
- jupyter-notebooks
- data-science
- anaconda
- Python
---

Managing Python development environments can be confusing. Tools like **pyenv** and **virtualenv**,
while powerful, have a steep learning curve. I encountered this recently while trying to find
a sensible way to set up [Anaconda](https://www.anaconda.com/what-is-anaconda/) the popular
Python and R distribution for data science frequently used with Jupyter Notebooks.

The problem I experienced stemmed from the fact that  Anaconda has its own version of Python,
which needed to be set on my system path. The Anaconda installation guide instructs you
to place the following in your `.bashrc` or wherever you set up your system paths:

```
export PATH=/path/to/anaconda:$PATH
```

Unfortunately, when you set the path this way, your other default Python versions, including
those that you may be managing via pyenv are no longer linked. At least, that's what happened
on my system.

One fix is to alter the path setting above slightly so that the Anaconda path 
comes at the end of the system path. Then, for reasons, I've not totally grasped yet you can 
still run the `conda` command and your original Python paths are retained.

Fix #1, though, caused another problem: the ability to manage virtual environments using the
`conda create` command broke. I could create the virtual environment like so:

```
conda create -n test
```

But when I tried to activate it using `source activate test`, I got a message stating that `test`
was not a virtualenv. Running `conda info --env`, however, showed that the environment did in fact
exist. Alas more problems.

### The Solution

Having run up against these barriers, I finally came across a more elegant solution  that doesn't
require setting the Anaconda path at all, or at least not by default.

This solution involves the use of [direnv](https://direnv.net/), a powerful tool for setting Python environment details
based on a project directory. With direnv installed, if you navigate into a folder
containing a `.envrc` file, direnv will follow the directives in that configuration file in order
to setup the environment. And, direnv "integrates" well with other tools such as Anaconda.

So here's my solution:

1. Install `direnv`. This can be done with Homebrew: `brew install direnv`.    
2. Install Anaconda or Miniconda. I'll show you my method for installing Miniconda:

  ```
  wget http://repo.continuum.io/miniconda/Miniconda3-3.7.0-Linux-x86_64.sh -O ~/miniconda.sh
  bash ~/miniconda.sh -b -p $HOME/miniconda
  export PATH="$HOME/miniconda/bin:$PATH"
  ```

  Then so that you can still access the `conda` executable, add the miniconda path to your
  system path *at the end*, like so in wherever you set your paths:

  ```
  export PATH=$PATH:/path/to/miniconda
  ```

3. Add a function to your `~/.direnvrc` to integrate `direnv` with Anaconda:

```
layout_anaconda() {
  local ANACONDA_HOME="${HOME}/miniconda" # Make sure this points to path of your conda install
  PATH_add "$ANACONDA_HOME"/bin

  if [ -n "$1" ]; then
    # Explicit environment name from layout command.
    local env_name="$1"
    source activate ${env_name}
  elif (grep -q name: environment.yml); then
    # Detect environment name from `environment.yml` file in `.envrc` directory
    source activate `grep name: environment.yml | sed -e 's/name: //'`
  else
    (>&2 echo No environment specified);
    exit 1;
  fi;
}
```

4. With the `layout_anaconda()` function in place, we can now create a conda environment:

  ```
  conda create -n my-conda-env python=3.4.6
  ```

  This creates a virtualenv with the specified Python version.

5. Next, create (or edit) a `.envrc` file in some project directory and add the following line:

  ```
  layout anaconda my-conda-env
  ```

That's it. Now When you exit this file, you will probably be prompted with a message like

  > direnv: error .envrc is blocked. Run `direnv allow` to approve its content

  If you do get this message, issue the command `direnv allow` and at that point `direnv`
  should set your environment correctly.

### Verifying it Worked

With this integration setup, you can create as many conda environments as
you may need, and specify them in the `.envrc` file in your projects.

Then, when you move in and out of those project directories, direnv will automatically shift
your environment variables to match your settings in each of those environments.  

While you are in directories with an `.envrc` set up in this manner, your Python version should point to the 
conda Python path; when you aren't, your Python path should point to your default Python path.

To confirm this, you can enter the project directory where you set up the `.envrc` file and run `conda info --env`.
You should see an asterisk by the correct environment. You can also check your Python path by running `which python`.
It should spit out the anaconda Python path.

If you then leave that project directory, `direnv` should unload those environment settings so that if 
you run `which python` again, it will point to your default Python installation.

That's it. I hope this works for others.
