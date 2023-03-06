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

## Configuration

summon-s3 uses the [official AWS Go SDK (V2)](https://github.com/aws/aws-sdk-go-v2). It will use
the credentials file or environment variables [as they explain](https://aws.github.io/aws-sdk-go-v2/docs/configuring-sdk/#specifying-credentials).

## Contributing

We welcome contributions of all kinds to this repository. For instructions on how to get started and descriptions of our development workflows, please see our [contributing
guide][contrib].

[contrib]: CONTRIBUTING.md
