# Artifactory Resource
The Artifactory resource lets you integrate your pipeline jobs with maven repositories in Artifactory.

This integration allows:

- To deploy artifacts and poms generated by your build
- To publish build information
- To retreive artifacts in a repository
- To trigger jobs when a new version of an artifact is available
## Source Configuration
* `host`: *Required.* The fully qualified domain name including the context root.
* `api_key`: *Required.* The API key of a user with sufficient read and write privileges on the repositories you wish to use
* `repository_id`: *Required.* The repository 
* `group_id`: *Required.* The maven groupId of your artifact
* `artifact_id`: *Required.* The maven artifactId of your artifact
* `skip_check`: *Optinal.* In CI/CD context you may no need to check because version are added by put. (it keeps the history clean)
* `sort_version_stategy`: *Optinal.* define how artefact are sorted to create concourse resourec history (default: maven, availible: maven, created)
### Example
Resource Type Configuration:
``` yaml
resource_types: 
  - 
    name: artifactory
    source: 
      repository: emeraldsquad/artifactory-resource
      type: docker-image
```
Resource configuration for an artifact:
``` yaml
resources: 
  - 
    name: my-artifact
    type: artifactory
    source: 
      api_key: <API KEY>
      artifact_id: wonderful-artifact
      group_id: emerald.squad
      host: "https://emerald.squad.com/artifactory"
      repository_id: repo-local
```
Retreiving artifacts:

``` yaml
- get: my-artifact
```

``` yaml
- get: my-artifact
  params: 
    qualifiers: [sources,javadoc]
```
Pushing local commits to the repo:
``` yaml
- put: my-artifact
  params:
    path: artifacts
```
Publish build information: _(only use required param)_
``` yaml
- put: my-artifact
  params:
    path: artifacts
    build_publish:
      build_name: wonderful-artifact-build
```
Publish build information: _(use all optional params)_
``` yaml
- put: my-artifact
  params:
    path: artifacts
    build_publish:
      build_name: wonderful-artifact-build
      build_number: wonderful-artifact-build/build
      add_git: git-resource-name
      env_include: "BUILD_*;ATC_*"
      env_exclude: "*API_KEY*"
```
## Behavior
### `check`: Check for new artifacts.

The resource searches for folders under `http(s)://<host>/<repository_id>/<group_id>/<artifact_id>`.

By default, It expects to get a list of valid maven versions (See https://cwiki.apache.org/confluence/display/MAVENOLD/Versioning for details). All subsequent versions of the given ref are returned. If no version is provided, the resource returns only the latest. (default `sort_version_stategy: maven`)

If `sort_version_stategy: created`, the version are return base on the last created artefact first.

### `in`: Download the artifacts at the given ref.
Download the artifacts of the given ref to the destination. It will return the same given ref as version.
#### Parameters
* `qualifiers`: *Optional.* The artifacts classifiers ex: [source,javadoc]. If specified, the resource will only retreive the qualified artifacts.
### `out`: Push the artifacts to the repository.
Push the artifacts from the given path to the Artifactory maven repository. The resource will push every files presents in the folder specified in the **path** parameter. The version parameter is optionnal but the resource expect at least a version file containing a version in the format `<timestamp>-<git hash>`. You can easily generate a version of this format from your pipeline using the shell `echo "$(date +'%s')-$(git rev-parse --short HEAD)" > version`.

The artefact est expected to follow this formating: `${artifact_id}-${version}[-classifier].packaging${NC}`. The option `package_artifact` auto format the artefict name.
#### Parameters
* `path`: *(required)* The path of the files to push to the repository.
* `version`: *(optional)* The path to a version file. Defaults to `<path parameter>/version`.
* `package_artifact`: *(optional)* The script will make sure your files comply with the spec
  * `bin` : *(required)* Regex to define wich artifact to package as `${artifact_id}-${version}.packaging`
  * `evidences`: *(optional)* Regex to define wich artifact to package as `${artifact_id}-${version}[-classifier].packaging` all artefact that do not match that regex will be removed
* `build_publish`: *(optional)* Publish build info.
  * `build_name` : *(required)* The build name.
  * `build_number` : *(optional)*  The path to a build file. defaults to `<path parameter>/build` if it exist, otherwise defaults to concourse-ci `BUILD_ID` variable.
  * `add_git`: *(optional)* The git resource name. Collect VCS details from git and add them to a build.
  * `add_git_issue_config_file`: *(optional)* TPath to a configuration file, used for collecting tracked project issues and adding them to the build-info.. (see [Artifactory Collecting Build Information](https://www.jfrog.com/confluence/display/CLI/CLI+for+JFrog+Artifactory#CLIforJFrogArtifactory-CollectingBuildInformation])
  * `env_include` : *(optional)* List of patterns in the form of `"value1;value2;..."` Only environment variables match those patterns will be included. Default: `*`
  * `env_exclude` : *(optional)* List of case insensitive patterns in the form of `"value1;value2;..."`. Environment variables match those patterns will be excluded. Default: `*password*;*secret*;*key*;*token*`
