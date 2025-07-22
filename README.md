# starship-job-operator
Kubernetes operator that allows you to define a plugin (Job) that will run when a starship job is popped from the starship job service queue.

## CRDs

*What is a StarshipPlugin?*  
Your plugin is a kubernetes [batchv1.Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/).

*How does my StarshipPlugin take input?*  
Your plugin takes input by reading from the file `/var/starshipplugin/input.json` which gets mounted as a volume into all containers of all pods for the job.

*How do I know if my StarshipPlugin ran successfully?*  
Once your plugin's job has a condition of `Complete` or `Failed` the last 4KiB of logs are then reported to starship services' job service along with the job service job status of `SUCCESS` or `FAIL`.

*What resources are created by a StarshipPlugin?*  
Once a StarshipPlugin (sp) is created in your desired Namespace you will then see new Deployment resource created in the starship-plugin-system Namespace with the naming convention `<sp namespace>-<sp name>`. This deployment will have 1 or more Pod replicas dedicated to listening for new starship jobs to invoke your sp on-demand. Once you create a starship job via starship apis you will then see a Job resource created in your sp's Namespace named after the job id of your starship job.

*What does a StarshipPlugin CRD look like?*  
Check out below!
```yaml
apiVersion: plugins.scm.starbucks.com/v1
kind: StarshipPlugin
metadata:
  name: <string>
  namespace: <string>
spec:
  starship:
    routes:
    - domain: <string>
      route: <string>
    config:
      secretRef:
        name: <string>
        namespace: <string>
      secretKey: <string>
  parallelism: <int>
  pollingInterval: <int>
  jobTemplate: <batchv1.JobTemplateSpec>
```

## Install
To install the operator download the below file from the desired github release. Then apply it via kubectl.
```bash
kubectl create -f starship-job-operator.yaml
```

## Uninstall
To uninstall the operator download the below file from the desired github release. Then delete it via kubectl.
```bash
kubectl delete -f starship-job-operator.yaml
```

## API

##### `v1.StarshipPlugin`

Name | Description | Schema |
--- | --- | --- |
**starship**<br>*required* | starship services data | [v1.Starship](#v1starship) |
**parallelism**<br>*optional* | max number of jobs that will run simultaneously for all given starship routes (default: 1) | int |
**pollingInterval**<br>*optional* | number of seconds in between starship job service polls (default: 10) | int |
**jobTemplate**<br>*required* | job template for your starship plugin | [k8s.io.api.batch.v1.JobTemplateSpec](https://pkg.go.dev/k8s.io/api/batch/v1#JobTemplateSpec) |

##### `v1.Starship`

Name | Description | Schema |
--- | --- | --- |
**routes**<br>*required* | starship routes that will trigger your plugin | < [v1.StarshipRoute](#v1starshiproute) > array |
**config**<br>*required* | starship configuration data | [v1.KeyedSecret](#v1keyedsecret) |

##### `v1.StarshipRoute`

Name | Description | Schema |
--- | --- | --- |
**route**<br>*required* | starship job service route | string |
**domain**<br>*required* | starship job service domain | string |

##### `v1.KeyedSecret`

Name | Description | Schema |
--- | --- | --- |
**secretRef**<br>*required* | reference to your starship config secret to authenticate to starship services | [k8s.io.api.core.v1.SecretReference](https://pkg.go.dev/k8s.io/api/core/v1#SecretReference) |
**secretKey**<br>*required* | the key in the kubernetes secret that your starship config is located under | string |
