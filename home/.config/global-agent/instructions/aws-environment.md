## AWS Authentication

At times you will call `tng` or `tngctl`, and reach the following output:

```text
tng - WARNING: Invalid AWS_ENVIRONMENT value 'None' (valid values are [integration3, uat, production, operations]). I will assume the environment is UAT. Some commands will not work until you authenticate with 'aws-environment'.
```

DO NOT TRY TO MANUALLY SET AWS_ENVIRONMENT.

To resolve this, run `aws-environment uat dev`. This loads the AWS credentials into the current shell session.

If you need to load credentials in a one-liner, run:

```bash
source <(tng auth aws ar uat dev); <command>
```

`tng` writes the `export NAME=value` lines to stdout (plus occasional straggler log lines, which source harmlessly accepts as bare assignments). Note macOS `/bin/bash` is 3.2, where `source <(...)` silently no-ops — run this in zsh or a modern bash.

Important:
- Do not run `aws-environment production dev`.
- Do not run `aws-environment uat platform`.


