#!/usr/bin/env bash
#set -e

echo "***************************************"
echo "Initialize Codespaces"
echo "***************************************"
echo ""

REPOROOT=$( cd -- "$(dirname $( dirname -- "${BASH_SOURCE[0]}" ))" &> /dev/null && pwd )

if [ ! -d "$HOME/update-golang" ]; then
    echo "$HOME/update-golang does not exist, creating..."
    pushd ~/
    git clone https://github.com/udhos/update-golang
    cd update-golang
    sudo ./update-golang.sh
    popd
fi

echo "Update pip"
python3 -m pip install --upgrade pip

echo "Update npm..."
sudo npm install -g --force npm@latest
npm --version


echo "Install latest AWS CDK"
sudo npm install -g --force cdk@latest
cdk --version

pip3 install --user policy_sentry
echo 'eval "$(_POLICY_SENTRY_COMPLETE=source_zsh policy_sentry)"' >> ~/.zshrc

echo "Install commitizen"
sudo npm install -g commitizen@latest
echo "Install cz-customizable"
sudo npm install -g cz-customizable
echo "Configure cz-customizable"
echo '{ "path": "cz-customizable" }' > ~/.czrc

echo "Create $REPOROOT/.cz-config.js"
sudo tee "$REPOROOT/.cz-config.js" > /dev/null <<EOF
module.exports = {
  types: [
    { value: 'feat', name: 'feat:     A new feature' },
    { value: 'fix', name: 'fix: h as default 
chsh -s $(which zsh)     A bug fix' },
    { value: 'docs', name: 'docs:     Documentation only changes' },
    {
      value: 'style',
      name:
        'style:    Changes that do not affect the meaning of the code\n            (white-space, formatting, missing semi-colons, etc)',
    },
    {
      value: 'refactor',
      name: 'refactor: A code change that neither fixes a bug nor adds a feature',
    },
    {
      value: 'perf',
      name: 'perf:     A code change that improves performance',
    },
    { value: 'test', name: 'test:     Adding missing tests' },
    {
      value: 'chore',
      name:
        'chore:    Changes to the build process or auxiliary tools\n            and libraries such as documentation generation',
    },
    { value: 'revert', name: 'revert:   Revert to a commit' },
    { value: 'WIP', name: 'WIP:      Work in progress' },
  ],
  scopes: [{ name: 'codespaces' }],
  allowTicketNumber: false,
  isTicketNumberRequired: false,
  ticketNumberPrefix: 'TICKET-',
  ticketNumberRegExp: '\\d{1,5}',
  // it needs to match the value for field type. Eg.: 'fix'
  /*
  scopeOverrides: {
    fix: [
      {name: 'merge'},
      {name: 'style'},
      {name: 'e2eTest'},
      {name: 'unitTest'}
    ]
  },
  */
  // override the messages, defaults are as follows
  messages: {
    type: "Select the type of change that you're committing:",
    scope: '\nDenote the SCOPE of this change (optional):',
    // used if allowCustomScopes is true
    customScope: 'Denote the SCOPE of this change:',
    subject: 'Write a SHORT, IMPERATIVE tense description of the change:\n',
    body: 'Provide a LONGER description of the change (optional). Use "|" to break new line:\n',
    breaking: 'List any BREAKING CHANGES (optional):\n',
    footer: 'List any ISSUES CLOSED by this change (optional). E.g.: #31, #34:\n',
    confirmCommit: 'Are you sure you want to proceed with the commit above?',
  },
  allowCustomScopes: true,
  allowBreakingChanges: ['feat', 'fix'],
  // skip any questions you want
  skipQuestions: ['body'],
  // limit subject length
  subjectLimit: 100,
  // breaklineChar: '|', // It is supported for fields body and footer.
  // footerPrefix : 'ISSUES CLOSED:'
  // askForBreakingChangeFirst : true, // default is false
};
EOF

echo "Configure oh my zsh"
# find and replace plugins
# plugins=(docker git github golang gpg-agent jfrog keychain ssh-agent timewarrior zsh-autosuggestions zsh-syntax-highlighting)
if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

sed -i 's/plugins=(git)/plugins=(git docker github golang jfrog zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
# zsh
# omz update > /dev/null

echo ""
echo "***************************************"
echo "Codespaces initialization done"
echo "***************************************"
echo ""
