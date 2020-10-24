# swiftlambda
AWS Lambda Swift functions made easy

# Installation
## Using [Homebrew](https://brew.sh)
```
brew tap melonamin/formulae
brew install swiftlambda 
```

## Download pre-built  binary
You can also install swiftlambda by downloading from the [latest GitHub release](https://github.com/melonamin/swiftlambda/releases).

## Compiling from source
```
git clone https://github.com/melonamin/swiftlambda && cd swiftlambda && make clean && make install
```

# Usage
```
➜ swiftLambda
OVERVIEW: AWS Lambda Swift functions made easy

USAGE: swiftlambda <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  new                     New AWS Lambda Swift template.
  build                   Build and package Swift code for AWS Lambda deployment.
  deploy                  Deploy new AWS Lambda function.

  See 'swiftlambda help <subcommand>' for detailed help.

```

## New
Creates a boilerplate Swift package for AWS Lambda function.

```
~ swiftLambda new --help
OVERVIEW: New AWS Lambda Swift template.

USAGE: swiftlambda new --name <name> [--out <out>]

OPTIONS:
  -n, --name <name>       Name. 
  -o, --out <out>         Filepath. (default: current directory)
  --version               Show the version.
  -h, --help              Show help information.
```

Inlcludes:
* dependency to [swift-aws-lambda-runtime](https://github.com/swift-server/swift-aws-lambda-runtime)
* basic handler function

## Build 
Build Swift package in linux environment using Docker.

```
~ swiftLambda build --help
OVERVIEW: Build and package Swift code for AWS Lambda deployment.

USAGE: swiftlambda build [--source <source>]

OPTIONS:
  -s, --source <source>   Filepath to Swift Package directory. (default: current directory)
  --version               Show the version.
  -h, --help              Show help information.
```

## Deploy
Prepares an AWS Lambda package(zip archive) and uploads it to AWS, can create new or update existing lambda  functions

```
~ swiftLambda deploy --help
OVERVIEW: Deploy new AWS Lambda function.

USAGE: swiftlambda deploy [--source <source>] --name <name> [--role <role>] [--update]

OPTIONS:
  -s, --source <source>   Filepath to Swift Package directory. (default: current directory)
  -n, --name <name>       AWS Lambda name. 
  -r, --role <role>       AWS Lambda execution role. 
  -u, --update            Update existing function. 
  --version               Show the version.
  -h, --help              Show help information.
```
