# Uncomment as necessary
# export YOUTUBE_DEV_KEY="$(pass Tokens/Youtube/secret_key)"
# export AWS_ACCESS_KEY_ID="$(pass Tokens/Amazon/key_id)"
# export AWS_SECRET_ACCESS_KEY="$(pass Tokens/Amazon/secret_key)"
# export AWS_STORAGE_BUCKET_NAME="$(pass Tokens/Amazon/bucket_name)"
# export DJANGO_SECRET="$(pass Tokens/Django/secret_key)"
# export DJANGO_DEBUG_VALUE="$(pass Tokens/Django/debug_value)"
export GOPATH="$HOME/.go"
export PATH="$HOME/code/scripts:$HOME/code/utils:$HOME/.local/bin:$HOME/.spicetify:$GOPATH/bin:$HOME/.cargo/bin:$PATH"
export QT_QPA_PLATFORMTHEME="qt5ct" # on X11
#export QT_QPA_PLATFORMTHEME="wayland"
export KRITA_NO_STYLE_OVERRIDE=1
export EDITOR="nvim"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
