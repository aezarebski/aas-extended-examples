
# This provides a shell running a jupyter lab server. To start the server run
# the following command
#
# $ nix-shell --command "jupyter lab"

let
  jupyter = import (builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "";
  }) {};

  ipython = jupyter.kernels.iPythonWith {
    name = "python";
    packages = p: with p; [ numpy
                            altair
                            statsmodels
                            pandas
                            matplotlib ];
  };

  jupyterEnvironment = jupyter.jupyterlabWith {
    kernels = [ ipython ];
  };
in
  jupyterEnvironment.env
