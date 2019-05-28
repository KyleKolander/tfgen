# tfgen
Terraform preprocessor that allows for easily switching between AWS regions and profiles, and provides a work-around for the lack of interpolation in backend configuration.

Out-of-the-box, **_tfgen_** will replace the following placeholders, but one could easily add others as needed:
```
- [region]
- [profile]
- [app]
- [accountID]
```

### Prerequisites

- An [AWS](https://aws.amazon.com/) account.
- [Install](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and [configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) the AWS CLI.
- [Download](https://www.terraform.io/downloads.html) and install Terraform (Tested against version 0.12.0).
- A bash environment (e.g. [Git for Windows](https://gitforwindows.org/)).

### Run tfgen for preprocessing
A corresponding **_.tf_** file will be generated for each **_.tfgen_** file in the module.  Any placeholder text will be replaced accordingly.  Do not modify the **_.tf_** files, as they will be overwritten the next time you run **_tfgen_**.
```
./tfgen.sh us-east-2
```
Running **_tfgen_** without any arguments will print out the usage and clean up your module directory.  Note that the **_app_** argument defaults the name of the module directory.
```
$ ./tfgen.sh

Usage: ./tfgen.sh region [profile] [app]

  region      AWS Region.
  profile     AWS Profile in ~/.aws/credentials.    Default:  default
  app         Application name.                     Default:  tfgen

Cleaning up...

```

### Run Terraform
```
terraform init
terraform apply
```

### Example of Terraform backend configuration for S3
This isn't possible with Terraform alone.  Using the same module across different regions and accounts requires copy/paste or manual and error-prone editing.
```
./tfgen.sh us-east-2 kyle
```
**_.tfgen_**
```
terraform {
  backend "s3" {
    bucket         = "terraform-state-[accountID]-[region]"
    key            = "[app].tfstate"
    region         = "[region]"
    profile        = "[profile]"
    dynamodb_table = "terraform-state-lock-[accountID]-[region]"
  }
}
```
**_.tf_**
```
terraform {
  backend "s3" {
    bucket         = "terraform-state-redacted-us-east-2"
    key            = "tfgen.tfstate"
    region         = "us-east-2"
    profile        = "kyle"
    dynamodb_table = "terraform-state-lock-redacted-us-east-2"
  }
}
```

### Authors

* **Kyle Kolander**

### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details