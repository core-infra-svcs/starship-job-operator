# starship-job-operator
Kubernetes operator that allows you to define a plugin (container) that will run when a starship job is popped from the starship job service queue.

## CRDs

*What is a StarshipPlugin?*  
Your plugin is a single container.

*How does my StarshipPlugin take input?*  
Your plugin takes input by reading from the file `/var/starshipplugin/input.json` which gets mounted into your container as a volume.

*How do I know if my StarshipPlugin ran successfully?*  
Once your plugin's pod reaches the pod phase `Succeeded` or `Failed` the last 4KiB of logs are then reported to starship services' job service along with the job service job status of `SUCCESS` or `FAIL`.

*What does a StarshipPlugin CRD look like?*  
Check out below!
```yaml
apiVersion: plugins.scm.starbucks.com/v1beta1
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
  maxPods: <int>
  pollingInterval: <int>
  imagePullSecrets: <[]corev1.LocalObjectReference>
  container: <corev1.Container>
  volumes: <[]corev1.Volume>
```

## Install
To install the operator download the below file from the desired github release. Then apply it via kubectl.
```bash
kubectl apply -f starship-job-operator.yaml
```

## Uninstall
To uninstall the operator download the below file from the desired github release. Then delete it via kubectl.
```bash
kubectl delete -f starship-job-operator.yaml
```

## API

##### `v1beta1.StarshipPlugin`

Name | Description | Schema |
--- | --- | --- |
**starship**<br>*required* | starship services data | [v1beta1.Starship](#v1beta1starship) |
**maxPods**<br>*optional* | max number of pods that will run simultaneously for all given starship routes (default: 1) | int |
**pollingInterval**<br>*optional* | number of seconds in between starship job service polls (default: 10) | int |
**imagePullSecrets**<br>*optional* | list of references to secrets to use for pulling the container image for your StarshipPlugin | < [k8s.io.api.core.v1.LocalObjectReference](https://pkg.go.dev/k8s.io/api/core/v1#LocalObjectReference) > array |
**container**<br>*required* | plugin code that will read input from `/var/starshipplugin/input.json` | [k8s.io.api.core.v1.Container](https://pkg.go.dev/k8s.io/api/core/v1#Container) |
**volumes**<br>*optional* | volumes that can be mounted to your plugin container | < [k8s.io.api.core.v1.Volume](https://pkg.go.dev/k8s.io/api/core/v1#Volume) > array |

##### `v1beta1.Starship`

Name | Description | Schema |
--- | --- | --- |
**routes**<br>*required* | starship routes that will trigger your plugin | < [v1beta1.StarshipRoute](#v1beta1starshiproute) > array |
**config**<br>*required* | starship configuration data | [v1beta1.KeyedSecret](#v1beta1keyedsecret) |

##### `v1beta1.StarshipRoute`

Name | Description | Schema |
--- | --- | --- |
**route**<br>*required* | starship job service route | string |
**domain**<br>*required* | starship job service domain | string |

##### `v1beta1.KeyedSecret`

Name | Description | Schema |
--- | --- | --- |
**secretRef**<br>*required* | reference to your starship config secret to authenticate to starship services | [k8s.io.api.core.v1.SecretReference](https://pkg.go.dev/k8s.io/api/core/v1#SecretReference) |
**secretKey**<br>*required* | the key in the kubernetes secret that your starship config is located under | string |
