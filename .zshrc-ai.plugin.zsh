# © 2025 David BASTIEN
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Install it with:
# echo "source ~/.zshrc-ai.plugin.zsh" >> ~/.zshrc

# Default key binding is Alt+i
(( ! ${+ZSH_AI_CMD_KEY} )) && typeset -g ZSH_AI_CMD_KEY='^[i'
# default Ollama model will Mistral Nemo (use about 8.5GB of GPU VRAM)
(( ! ${+ZSH_OLLAMA_MODEL} )) && typeset -g ZSH_OLLAMA_MODEL='mistral-nemo:latest'
# default ollama server host
(( ! ${+ZSH_OLLAMA_URL} )) && typeset -g ZSH_OLLAMA_URL='http://localhost:11434'
# debug with `export ZSH_AI_DEBUG=true` and `cat /tmp/myzshrc-ai-plugin.log
(( ! ${+ZSH_AI_DEBUG} )) && typeset -g ZSH_AI_DEBUG=false

check_requirements() {
  # Check if curl is installed
  if ! (( $+commands[curl] )); then
    echo
    echo "🚨: Curl is NOT installed! On Linux, try:"
    echo "sudo apt install curl -y"
    return 1;
  fi
  # Check if jq is installed
  if ! (( $+commands[jq] )); then
    echo
    echo "🚨: jq is NOT installed! On Linux, try:"
    echo "sudo apt install jq -y"
    return 1;
  fi
  # Check if ollama is installed
  if ! (( $+commands[ollama] )); then
    echo
    echo "🚨: Ollama server is NOT installed! On Linux, try:"
    echo "curl -fsSL https://ollama.com/install.sh | sh"
    return 1;
  fi
  # Check if ollama needed model is already pulled.
  if ! ollama list | grep -q $ZSH_OLLAMA_MODEL; then
    echo
    echo "🚨: AI model is NOT installed! Pulled it with:"
    echo "ollama pull ${ZSH_OLLAMA_MODEL}"
    return 1;
  fi
  # Check if ollama is running...
  if ! (( $(pgrep -f ollama | wc -l ) > 0 )); then
    echo
    echo "🚨: Ollama server is NOT running! Launching it with:"
    echo "ollama serve"
    return 1;
  fi
}

# You MAY explain the command by writing a short line after the comment symbol # .
# Make sure input is escaped correctly if needed so.
read -r -d '' MYZSH_SYSTEM_PROMPT <<- EOM
  You are a helpful AI assistant.
  Your task is to either complete a shell command or provide a new shell command that you think the user is trying to type.
  Only respond with either a completion or a new shell command, not both.
  Do NOT write any leading or trailing characters except if required for the completion to work.
  Your response MUST be able to run in the user's shell.
  Do NOT return anything else other than a shell command.
  You CANNOT explain the command.
  Do NOT interact with the user in natural language!
  If you write a comment or an explanation, use a short sentence and it must start with the comment symbol #.
EOM

case "$(uname -s)" in
    Linux*)
        USER_SYSTEM_INFO="The operating system is $(uname -s) on a $(uname -m) platform. "
        ;;
    Darwin*)
        USER_SYSTEM_INFO="The operating system is MacOS. "
        ;;
    *)
        USER_SYSTEM_INFO="The operating system is unknown. "
        ;;
esac

USER_CONTEXT_INFO="Context: You are user $(whoami) with id ${EUID} in directory $(pwd).
Your shell is $(echo $SHELL) and your terminal is $(echo $TERM).
${USER_SYSTEM_INFO}"

myzsh_ollama_ai_commands() {
  check_requirements
  if [ $? -eq 1 ]; then
    return 1
  fi

  MYZSH_USER_QUERY=$BUFFER

  local MYZSH_SYSTEM_FULL_PROMPT=$(echo "${MYZSH_SYSTEM_PROMPT} ${USER_CONTEXT_INFO}" | tr -d '\n')

  _zsh_autosuggest_clear
  zle -R "🤖: Asking AI overlord...."

  MYZSH_OLLAMA_REQUEST_BODY='{
    "model": "'${ZSH_OLLAMA_MODEL}'",
    "messages": [
      {
        "role": "system",
        "content": "'${MYZSH_SYSTEM_FULL_PROMPT}'"
      },
      {
        "role": "user",
        "content": "'${MYZSH_USER_QUERY}'"
      }
    ],
    "stream": false
  }'

  response=$(curl --silent "${ZSH_OLLAMA_URL}/api/chat" -H "Content-Type: application/json" -d "${MYZSH_OLLAMA_REQUEST_BODY}")
  # Debug
  if [[ "${ZSH_AI_DEBUG}" == 'true' ]]; then
    touch /tmp/myzshrc-ai-plugin.log
    echo "$(date '+%Y-%m-%d %H:%M:%S');INPUT: ${MYZSH_USER_QUERY};ANSWER: ${response}" >> /tmp/myzshrc-ai-plugin.log 2>&1
  fi

  MYZSH_AI_RESPONSE=$(echo "$response" | tr -d '\n\r' | tr -d '\0' | jq -r '.message.content')

  # reset user input
  BUFFER=""
  CURSOR=0
  zle -U "${MYZSH_AI_RESPONSE}"
}

autoload -U myzsh_ollama_ai_commands
zle -N myzsh_ollama_ai_commands
bindkey $ZSH_AI_CMD_KEY myzsh_ollama_ai_commands

# References:
# https://github.com/ollama/ollama
# https://github.com/ollama/ollama/blob/main/docs/api.md#api
# https://ollama.com/library/mistral:7b
# https://ollama.com/library/mixtral:8x7b
# https://ollama.com/library/codestral
# https://docs.mistral.ai/