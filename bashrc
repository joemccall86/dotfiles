# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -f ~/liquidprompt/liquidprompt ]; then
	source ~/liquidprompt/liquidprompt
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/joe/.sdkman"
[[ -s "/home/joe/.sdkman/bin/sdkman-init.sh" ]] && source "/home/joe/.sdkman/bin/sdkman-init.sh"

export PATH=$HOME/.node/bin:$PATH

# Kubectl bash completion
type -t kubectl > /dev/null  &&  source <(kubectl completion bash)
type -t minikube > /dev/null && source <(minikube completion bash)

# Aliases
alias i3conf="vim ~/.config/i3/config"
