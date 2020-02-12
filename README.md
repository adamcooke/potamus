# Potamus

Potamus is a simple utility that helps with building consistent Docker images of applications.

The usual process for building images is to simply run `docker build` followed by `docker push`. However, in reality, you need to do other things.

Potamus mandates that you'll create an image with a tag that matches the Git commit ref of the code that exist in the image. For example, if your image is called `myapp`, when you build, you'll have an image `myorg/myapp:871c4832a8071aaa5fcaeaca1121dbe6962af218`. In addtion to your commit-tagged image, it also pushes a tag with the name of the branch that you're building from. For example, if you're on your `v1.0` branch you'll also find the image is tagged with `v1.0`.

## Installation

```
$ gem install potomus
```

## Usage

Create a `PotamusFile` in the root of your application alongside your `Dockerfile`.

```yaml
# At the most basic, you just need to specify the name
# of the image you wish to create.
image_name: apps/postal
```

Once you've added these, just run the build command:

```bash
$ cd path/to/app
$ potomus build

# If you wish to also push after building
$ potomus build --push

# If you just want to test your Dockerfile.
# When using test you don't need a clean repository or
# to have pushed the code. It will only be pushed using the
# `test` tag.
$ potomus build --test

# If you want to test and push your test
$ potomus build --test --push
```

## Additional configuration

Additional configuration can be specified in the `PotomusFile`.

* `remote_name` - the name of the authoritative remote for your repository (defaults to `origin`).

* `branch_for_latest` - when pushing for the named branch a tag named latest will also be created (defaults to `master`).
