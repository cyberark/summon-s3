# summon-s3

AWS S3 provider for [Summon](https://cyberark.github.io/summon).

Provides access to secrets stored in Amazon S3.

## Usage

[Set summon-s3 as your Summon provider](https://github.com/cyberark/summon#flags).

Give summon a path to an object in S3 and it will fetch it for you and
print the value to stdout.

```bash
summon --provider summon-s3 \
--yaml 'MONGOPASS: !var myorg-creds/aws/dev/mongodb-password' \
printenv MONGOPASS
8h9psadf89sdahfp98
```

`myorg-credentials` is the bucket name.

## Using summon-s3 with Conjur OSS 

Are you using this project with [Conjur OSS](https://github.com/cyberark/conjur)? Then we 
**strongly** recommend choosing the version of this project to use from the latest [Conjur OSS 
suite release](https://docs.conjur.org/Latest/en/Content/Overview/Conjur-OSS-Suite-Overview.html). 
Conjur maintainers perform additional testing on the suite release versions to ensure 
compatibility. When possible, upgrade your Conjur version to match the 
[latest suite release](https://docs.conjur.org/Latest/en/Content/ReleaseNotes/ConjurOSS-suite-RN.htm); 
when using integrations, choose the latest suite release that matches your Conjur version. For any 
questions, please contact us on [Discourse](https://discuss.cyberarkcommons.org/c/conjur/5).

## Configuration

summon-s3 uses the [official AWS Go SDK](https://github.com/aws/aws-sdk-go). It will use
the credentials file or environment variables [as they explain](https://github.com/aws/aws-sdk-go#configuring-credentials).

## Contributing

We welcome contributions of all kinds to this repository. For instructions on how to get started and descriptions of our development workflows, please see our [contributing
guide][contrib].

[contrib]: CONTRIBUTING.md
